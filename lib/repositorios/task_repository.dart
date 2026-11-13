
import '../modelos/tarea.dart';

abstract class TaskRepository {
  Future<List<Tarea>> obtenerTareas();

  Future<Tarea> agregar(Tarea tarea);

  Future<void> actualizar(Tarea tarea);

  Future<void> eliminar(int id);
}
