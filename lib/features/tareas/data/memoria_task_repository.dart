import 'dart:async';

import '../domain/tarea.dart';
import '../domain/task_repository.dart';

class MemoriaTaskRepository implements TaskRepository {
  final List<Tarea> _tareas = [];
  final _cambios = StreamController<List<Tarea>>.broadcast();

  int _siguienteId = 1;

  void _notificarCambios() {
    _cambios.add(List<Tarea>.unmodifiable(_tareas));
  }

  @override
  Stream<List<Tarea>> observarTareas() async* {
    yield List<Tarea>.unmodifiable(_tareas);
    yield* _cambios.stream;
  }

  @override
  Future<String> agregar(Tarea tarea) async {
    final id = 'tarea-${_siguienteId++}';

    final nuevaTarea = Tarea(
      id: id,
      titulo: tarea.titulo,
      descripcion: tarea.descripcion,
      completada: tarea.completada,
      prioridad: tarea.prioridad,
      fechaLimite: tarea.fechaLimite,
      categoria: tarea.categoria,
    );

    _tareas.add(nuevaTarea);
    _notificarCambios();

    return id;
  }

  @override
  Future<void> actualizar(Tarea tarea) async {
    final indice = _tareas.indexWhere((elemento) => elemento.id == tarea.id);

    if (indice == -1) {
      throw StateError('La tarea no existe.');
    }

    _tareas[indice] = tarea;
    _notificarCambios();
  }

  @override
  Future<void> eliminar(String id) async {
    _tareas.removeWhere((tarea) => tarea.id == id);
    _notificarCambios();
  }

  Future<void> dispose() async {
    await _cambios.close();
  }
}
