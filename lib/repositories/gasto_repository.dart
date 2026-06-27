import '../models/gasto_models.dart';
import '../settings/database_connection.dart';

class GastoRepository {
  final tableName = 'gasto';
  final database = DatabaseConnection();

  Future<int> create(GastoModels data) async {
    final db = await database.db;
    return await db.insert(tableName, data.toMap());
  }

  Future<int> edit(GastoModels data) async {
    final db = await database.db;
    return await db.update(
      tableName,
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database.db;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<GastoModels>> getAll() async {
    final db = await database.db;
    final response = await db.query(tableName, orderBy: 'id DESC');
    return response.map((e) => GastoModels.fromMap(e)).toList();
  }

  Future<double> totalGastos() async {
    final db = await database.db;
    final response = await db.rawQuery('SELECT SUM(precio) as total FROM $tableName');
    final total = response.first['total'];
    if (total == null) return 0;
    return (total as num).toDouble();
  }
}
