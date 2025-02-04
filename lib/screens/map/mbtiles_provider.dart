  import 'dart:io';

  import 'package:flutter/foundation.dart';
  import 'package:http/http.dart' as http;
  import 'package:path/path.dart';
  import 'package:path_provider/path_provider.dart';
  import 'package:sqflite/sqflite.dart';

  class MBTilesProvider with ChangeNotifier {
    Database? _database;
    Future<Database> get database async {
      if (_database != null) return _database!;
      _database = await _initMBTiles();
      return _database!;
    }

    Future<Database> _initMBTiles() async {
      Directory documentsDir = await getApplicationDocumentsDirectory();
      String dbPath = join(documentsDir.path, 'BRC24_Vector.mbtiles');
      if (!await File(dbPath).exists()) {
        await _downloadMBTiles(dbPath);
      }

      Database db = await openDatabase(dbPath, readOnly: true);
      return db;
    }

    Future<void> _downloadMBTiles(String dbPath) async {
      const url =
          'https://bm-innovate.s3.amazonaws.com/2024/GIS/MBTiles/BRC24_Vector.mbtiles';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        File file = File(dbPath);
        await file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('Failed to download MBTiles file');
      }
    }
  }
