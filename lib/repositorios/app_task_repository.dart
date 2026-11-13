
import '../datos/tareas_api.dart';
import '../datos/tareas_db.dart';
import '../modelos/tarea.dart';
import 'task_repository.dart';

class AppTaskRepository implements TaskRepository {
  AppTaskRepository(
    this._db, {
    TareasApi? api,
  }) : _api = api;

  final TareasDb _db;
  final TareasApi? _api;

  @override
  Future<List<Tarea>> obtenerTareas() {
    return _db.todas();
  }

  @override
  Future<Tarea> agregar(Tarea tarea) {
    return _db.insertar(tarea);
  }

  @override
  Future<void> actualizar(Tarea tarea) {
    return _db.actualizar(tarea);
  }

  @override
  Future<void> eliminar(int id) {
    return _db.eliminar(id);
  }

  Future<List<Tarea>> obtenerTareasRemotas() async {
    final api = _api;

    if (api == null) {
      throw StateError('La API REST no está configurada.');
    }

    return api.obtenerTareas();
  }

  Future<Tarea> agregarLocalmente(Tarea tarea) {
    return agregar(tarea);
  }
}
