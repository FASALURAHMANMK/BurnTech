  import 'dart:ui' as ui;
  import 'dart:math';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_map/flutter_map.dart';
  import 'package:latlong2/latlong.dart';
  import 'package:provider/provider.dart';
  import 'package:sqflite/sqflite.dart';
  import 'package:vector_tile/vector_tile.dart';
  import 'package:archive/archive.dart';
  import 'mbtiles_provider.dart';

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

  Uint8List decompressTileData(Uint8List tileData) {
    if (isGzipped(tileData)) {
      final List<int> decompressed = GZipDecoder().decodeBytes(tileData);
      return Uint8List.fromList(decompressed);
    } else {
      return tileData;
    }
  }

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
      }) decode,
    ) {
      return OneFrameImageStreamCompleter(_loadAsync(key));
    }

    Future<ImageInfo> _loadAsync(MBTilesImageProvider key) async {
      int tmsY = ((1 << z) - 1) - y;

      final List<Map<String, dynamic>> result = await db.query(
        'tiles',
        columns: ['tile_data'],
        where: 'zoom_level = ? AND tile_column = ? AND tile_row = ?',
        whereArgs: [z, x, tmsY],
      );

      if (result.isNotEmpty) {
        final Uint8List tileData = result.first['tile_data'] as Uint8List;
        final ui.Image image = await renderVectorTile(tileData);
        return ImageInfo(image: image);
      } else {
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

  Future<ui.Image> renderVectorTile(Uint8List pbfData) async {
    const int tileSize = 256;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final Paint bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, tileSize.toDouble(), tileSize.toDouble()),
      bgPaint,
    );

    final Uint8List decompressedData = decompressTileData(pbfData);

    final VectorTile vectorTile = VectorTile.fromBytes(bytes: decompressedData);

    for (final layer in vectorTile.layers) {
      final int extent = layer.extent;

      for (final feature in layer.features) {
        Paint paint;
        if (feature.type == 3) {
          paint = Paint()
            ..color = Colors.green.withOpacity(0.5)
            ..style = PaintingStyle.fill;
        } else if (feature.type == 2) {
          paint = Paint()
            ..color = Colors.blue
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;
        } else if (feature.type == 1) {
          paint = Paint()
            ..color = Colors.red
            ..style = PaintingStyle.fill;
        } else {
          continue;
        }

        final dynamic geom = feature.geometry;
        if (geom == null || geom is! Iterable) continue;
        final Iterable<dynamic> rings = geom;

        for (final ringDynamic in rings) {
          final List<Point<int>> ring = ringDynamic is List<Point<int>>
              ? ringDynamic
              : (ringDynamic as List).cast<Point<int>>();

          if (ring.isEmpty) continue;
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
            path.close();
            canvas.drawPath(path, paint);
          } else if (feature.type == 2) {
            canvas.drawPath(path, paint);
          } else if (feature.type == 1) {
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

  class MBTilesMapScreen extends StatelessWidget {
    const MBTilesMapScreen({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      final mbtilesProvider =
          Provider.of<MBTilesProvider>(context, listen: false);
      return FutureBuilder<Database>(
        future: mbtilesProvider.database,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: const Text('MBTiles Map')),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('MBTiles Map')),
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
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
                    tileProvider: MBTilesTileProvider(db),
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
