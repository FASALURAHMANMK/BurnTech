import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vector_tile/vector_tile.dart'; // Dart parser for Mapbox vector tiles
import 'package:archive/archive.dart';
import 'mbtiles_provider.dart'; // Your provider that supplies a Future<Database>

/// A custom TileProvider that loads vector (PBF) tiles from an MBTiles database.
class MBTilesTileProvider extends TileProvider {
  final Database db;
  MBTilesTileProvider(this.db);

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MBTilesImageProvider(
      db,
      coordinates.x,
      coordinates.y,
      coordinates.z,
    );
  }
}
bool isGzipped(Uint8List data) {
  return data.length >= 2 && data[0] == 0x1F && data[1] == 0x8B;
}

/// Decompresses gzipped data if needed.
Uint8List decompressTileData(Uint8List tileData) {
  if (isGzipped(tileData)) {
    // Decode the bytes using the GZipDecoder from the archive package.
    final List<int> decompressed = GZipDecoder().decodeBytes(tileData);
    return Uint8List.fromList(decompressed);
  } else {
    return tileData;
  }
}

/// An ImageProvider that loads vector tile images from the MBTiles database,
/// decodes the PBF vector data, and renders it to an image.
class MBTilesImageProvider extends ImageProvider<MBTilesImageProvider> {
  final Database db;
  final int x;
  final int y;
  final int z;

  MBTilesImageProvider(this.db, this.x, this.y, this.z);

  @override
  Future<MBTilesImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<MBTilesImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(
    MBTilesImageProvider key,
    Future<ui.Codec> Function(
      ui.ImmutableBuffer buffer, {
      bool allowUpscaling,
      int? cacheHeight,
      int? cacheWidth,
    }
    ) decode,
  ) {
    // We ignore the provided decode function because we are rendering our own image.
    return OneFrameImageStreamCompleter(_loadAsync(key));
  }

  Future<ImageInfo> _loadAsync(MBTilesImageProvider key) async {
    // MBTiles files using the TMS scheme require converting the Y coordinate.
    int tmsY = ((1 << z) - 1) - y;

    // Query the 'tiles' table for the matching tile.
    final List<Map<String, dynamic>> result = await db.query(
      'tiles',
      columns: ['tile_data'],
      where: 'zoom_level = ? AND tile_column = ? AND tile_row = ?',
      whereArgs: [z, x, tmsY],
    );

    if (result.isNotEmpty) {
      final Uint8List tileData = result.first['tile_data'] as Uint8List;
      // Render the vector tile data into an image.
      final ui.Image image = await renderVectorTile(tileData);
      return ImageInfo(image: image);
    } else {
      // If no tile is found, create a blank image with an error indicator.
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint paint = Paint()..color = Colors.grey;
      canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);
      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(256, 256);
      return ImageInfo(image: image);
    }
  }

  @override
  bool operator ==(Object other) {
    return other is MBTilesImageProvider &&
        other.x == x &&
        other.y == y &&
        other.z == z;
  }

  @override
  int get hashCode => Object.hash(x, y, z);
}

/// Renders vector (PBF) tile data into a 256x256 raster image.
///
/// This function decodes the PBF vector tile using the
/// `vector_tile` package and then paints a simple representation
/// of the features. In a production app, you’d likely use a more sophisticated
/// styling and geometry handling.
Future<ui.Image> renderVectorTile(Uint8List pbfData) async {
  const int tileSize = 256;
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  // Fill the background with white.
  final Paint bgPaint = Paint()..color = Colors.white;
  canvas.drawRect(
    Rect.fromLTWH(0, 0, tileSize.toDouble(), tileSize.toDouble()),
    bgPaint,
  );

  // Decompress data if needed.
  final Uint8List decompressedData = decompressTileData(pbfData);

  // Decode the vector tile using the decompressed data.
  final VectorTile vectorTile = VectorTile.fromBytes(bytes: decompressedData);

  // Iterate over each layer in the tile.
  for (final layer in vectorTile.layers) {
    final int extent = layer.extent; // typically 4096

    // Iterate over each feature in the layer.
    for (final feature in layer.features) {
      // Choose a simple style based on the geometry type.
      Paint paint;
      if (feature.type == 3) {
        // Polygon
        paint = Paint()
          ..color = Colors.green.withOpacity(0.5)
          ..style = PaintingStyle.fill;
      } else if (feature.type == 2) {
        // LineString
        paint = Paint()
          ..color = Colors.blue
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
      } else if (feature.type == 1) {
        // Point
        paint = Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill;
      } else {
        // Unknown geometry type; skip rendering.
        continue;
      }

      // Ensure feature.geometry is iterable.
      final dynamic geom = feature.geometry;
      if (geom == null || geom is! Iterable) continue;
      final Iterable<dynamic> rings = geom;

      for (final ringDynamic in rings) {
        // Attempt to cast each ring to List<Point<int>>.
        final List<Point<int>> ring = ringDynamic is List<Point<int>>
            ? ringDynamic
            : (ringDynamic as List).cast<Point<int>>();

        if (ring.isEmpty) continue;

        // For non-point features, build a path.
        final ui.Path path = ui.Path();
        for (int i = 0; i < ring.length; i++) {
          final double xCoord = (ring[i].x / extent) * tileSize;
          final double yCoord = (ring[i].y / extent) * tileSize;
          if (i == 0) {
            path.moveTo(xCoord, yCoord);
          } else {
            path.lineTo(xCoord, yCoord);
          }
        }

        if (feature.type == 3) {
          // For polygons, close the path and fill.
          path.close();
          canvas.drawPath(path, paint);
        } else if (feature.type == 2) {
          // For lines, stroke the path.
          canvas.drawPath(path, paint);
        } else if (feature.type == 1) {
          // For point features, draw a small circle at each coordinate.
          for (final Point<int> pt in ring) {
            final double xCoord = (pt.x / extent) * tileSize;
            final double yCoord = (pt.y / extent) * tileSize;
            canvas.drawCircle(Offset(xCoord, yCoord), 3.0, paint);
          }
        }
      }
    }
  }

  final ui.Picture picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(tileSize, tileSize);
  return image;
}

/// The screen that displays the MBTiles map.
class MBTilesMapScreen extends StatelessWidget {
  const MBTilesMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the MBTilesProvider from the Provider tree.
    final mbtilesProvider = Provider.of<MBTilesProvider>(context, listen: false);
    return FutureBuilder<Database>(
      future: mbtilesProvider.database,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while waiting for the database.
          return Scaffold(
            appBar: AppBar(title: const Text('MBTiles Map')),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          // Display any error encountered.
          return Scaffold(
            appBar: AppBar(title: const Text('MBTiles Map')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          // Once the database is available, display the map.
          final Database db = snapshot.data!;
          return Scaffold(
            appBar: AppBar(title: const Text('MBTiles Map')),
            body: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(0, 0),
                initialZoom: 2,
              ),
              children: [
                TileLayer(
                  // Use the custom MBTilesTileProvider.
                  tileProvider: MBTilesTileProvider(db),
                  // The urlTemplate isn’t used since we provide tiles manually.
                  urlTemplate: '',
                ),
              ],
            ),
          );
        }
      },
    );
  }
}