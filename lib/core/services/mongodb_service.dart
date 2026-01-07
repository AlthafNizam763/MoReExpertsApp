import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:developer';

class MongoDBService {
  static final MongoDBService _instance = MongoDBService._internal();
  factory MongoDBService() => _instance;
  MongoDBService._internal();

  Db? _db;
  bool _isConnected = false;

  Db? get db => _db;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    final uri = dotenv.env['MONGODB_URI'];
    final dbName = dotenv.env['MONGODB_DB'];

    if (uri == null || dbName == null) {
      log('MongoDB URI or DB name not found in environment variables');
      return;
    }

    try {
      _db = await Db.create(uri);
      await _db!.open();
      _isConnected = true;
      log('Successfully connected to MongoDB: $dbName');
    } catch (e) {
      log('Error connecting to MongoDB: $e');
      _isConnected = false;
    }
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _isConnected = false;
      log('MongoDB connection closed');
    }
  }

  DbCollection collection(String collectionName) {
    if (!_isConnected || _db == null) {
      throw Exception('MongoDB is not connected. Call connect() first.');
    }
    return _db!.collection(collectionName);
  }
}
