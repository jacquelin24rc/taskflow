import 'tarea.dart';

abstract class TaskRepository {
  Stream<List<Tarea>> observarTareas();

  Future<String> agregar(Tarea tarea);

  Future<void> actualizar(Tarea tarea);

  Future<void> eliminar(String id);
}
