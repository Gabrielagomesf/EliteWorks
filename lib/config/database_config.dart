import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DatabaseConfig {
  static Db? _db;
  static bool _initialized = false;
  static bool _initializing = false;

  static Future<void> initialize() async {
    // Se já está inicializado e a conexão existe, verificar se está aberta
    if (_initialized && _db != null) {
      try {
        // Tentar uma operação simples para verificar se está conectado
        await _db!.collection('users').count();
        return;
      } catch (e) {
        // Se falhar, a conexão está fechada, então recriar
        _db = null;
        _initialized = false;
      }
    }

    // Se já está inicializando, aguardar
    if (_initializing) {
      // Aguardar até que a inicialização termine
      int attempts = 0;
      while (_initializing && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      if (_initialized && _db != null) {
        try {
          await _db!.collection('users').count();
          return;
        } catch (e) {
          _db = null;
          _initialized = false;
        }
      }
    }

    _initializing = true;

    try {
      await dotenv.load(fileName: ".env");
      final connectionString = dotenv.env['MONGODB_CONNECTION_STRING'];

      if (connectionString == null || connectionString.isEmpty) {
        throw Exception('MongoDB connection string não encontrada no .env');
      }

      // Fechar conexão antiga se existir
      if (_db != null) {
        try {
          await _db!.close();
        } catch (e) {
          // Ignorar erros ao fechar conexão antiga
        }
        _db = null;
      }

      // Criar nova conexão
      _db = await Db.create(connectionString);
      await _db!.open();
      _initialized = true;
    } catch (e) {
      _db = null;
      _initialized = false;
      _initializing = false;
      // Se der erro, tentar novamente uma vez após um delay
      await Future.delayed(const Duration(seconds: 1));
      _initializing = true;
      try {
        _db = await Db.create(dotenv.env['MONGODB_CONNECTION_STRING']!);
        await _db!.open();
        _initialized = true;
      } catch (e2) {
        _db = null;
        _initialized = false;
        rethrow;
      } finally {
        _initializing = false;
      }
    } finally {
      _initializing = false;
    }
  }

  static Db get database {
    if (_db == null) {
      throw Exception('Database não inicializada. Chame DatabaseConfig.initialize() primeiro.');
    }
    return _db!;
  }

  static DbCollection getCollection(String collectionName) {
    return database.collection(collectionName);
  }

  static Future<void> close() async {
    await _db?.close();
    _initialized = false;
  }

  static bool get isInitialized => _initialized;
}

