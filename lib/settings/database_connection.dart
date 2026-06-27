import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseConnection {
  static final DatabaseConnection instance = DatabaseConnection.internal();
  factory DatabaseConnection() => instance;
  DatabaseConnection.internal();

  static Database? database;

  Future<Database> get db async {
    if (database != null) return database!;
    database = await inicializarDb();
    return database!;
  }

  Future<Database> inicializarDb() async {
    final rutaDb = await getDatabasesPath();
    final rutaFinal = join(rutaDb, 'facturacion_cerdos.db');

    return await openDatabase(
      rutaFinal,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE gasto (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tipo TEXT NOT NULL,
          detalle TEXT,
          fecha TEXT NOT NULL,
          precio REAL NOT NULL
        )
        ''');

        await db.execute('''
        CREATE TABLE venta (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cliente TEXT NOT NULL,
          producto TEXT NOT NULL,
          fecha TEXT NOT NULL,
          precio REAL NOT NULL
        )
        ''');
      },
    );
  }
}
