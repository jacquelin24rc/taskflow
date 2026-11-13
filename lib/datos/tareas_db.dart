
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../modelos/tarea.dart';

class TareasDb {
  TareasDb._(this._db);

  final Database _db;

  static Future<TareasDb> abrir() async {
    final ruta = join(
      await getDatabasesPath(),
      'taskflow.db',
    );

    final db = await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tareas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            descripcion TEXT NOT NULL DEFAULT '',
            fecha_limite TEXT NOT NULL,
            completada INTEGER NOT NULL DEFAULT 0,
            categoria TEXT NOT NULL DEFAULT 'General',
            prioridad INTEGER NOT NULL DEFAULT 2,
            recordatorio INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );

    return TareasDb._(db);
  }

  // READ: consultar todas las tareas.
  Future<List<Tarea>> todas() async {
    final filas = await _db.query(
      'tareas',
      orderBy: 'fecha_limite ASC',
    );

    return filas.map(Tarea.fromMap).toList();
  }

  // CREATE: guardar una tarea nueva.
  Future<Tarea> insertar(Tarea tarea) async {
    final datos = tarea.toMap();
    datos.remove('id');

    tarea.id = await _db.insert(
      'tareas',
      datos,
    );

    return tarea;
  }

  // UPDATE: actualizar una tarea existente.
  Future<void> actualizar(Tarea tarea) async {
    await _db.update(
      'tareas',
      tarea.toMap(),
      where: 'id = ?',
      whereArgs: [tarea.id],
    );
  }

  // DELETE: eliminar una tarea.
  Future<void> eliminar(int id) async {
    await _db.delete(
      'tareas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Guardar varias tareas en una sola operación.
  Future<void> insertarVarias(List<Tarea> tareas) async {
    final lote = _db.batch();

    for (final tarea in tareas) {
      final datos = tarea.toMap();
      datos.remove('id');

      lote.insert('tareas', datos);
    }

    await lote.commit(noResult: true);
  }
}
