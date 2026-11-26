import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos/tarea.dart';
import 'tarea_mapper.dart';
import 'task_repository_provider.dart';
import 'task_state.dart';

class TaskNotifier extends Notifier<TaskState> {
  @override
  TaskState build() {
    return const TaskState(tareas: []);
  }

  Future<void> cargarTareas() async {
    final repositorio = await ref.read(taskRepositoryProvider.future);

    final tareas = await repositorio.obtenerTareas();

    state = state.copyWith(tareas: tareas.map(TareaMapper.aEstado).toList());
  }

  Future<void> agregarTarea(Tarea nuevaTarea) async {
    final repositorio = await ref.read(taskRepositoryProvider.future);

    final tareaGuardada = await repositorio.agregar(nuevaTarea);

    state = state.copyWith(
      tareas: [...state.tareas, TareaMapper.aEstado(tareaGuardada)],
    );
  }

  Future<void> alternarCompletada(int id) async {
    final repositorio = await ref.read(taskRepositoryProvider.future);

    final tareas = await repositorio.obtenerTareas();

    for (final tarea in tareas) {
      if (tarea.id == id) {
        tarea.completada = !tarea.completada;

        await repositorio.actualizar(tarea);
        break;
      }
    }

    await cargarTareas();
  }

  Future<void> eliminarTarea(int id) async {
    final repositorio = await ref.read(taskRepositoryProvider.future);

    await repositorio.eliminar(id);

    await cargarTareas();
  }

  void cambiarFiltro(String nuevoFiltro) {
    state = state.copyWith(filtroActivo: nuevoFiltro);
  }
}

final taskProvider = NotifierProvider<TaskNotifier, TaskState>(
  TaskNotifier.new,
);

final taskByIdProvider = Provider.family<TareaEstado?, int>((ref, id) {
  final taskState = ref.watch(taskProvider);

  for (final tarea in taskState.tareas) {
    if (tarea.id == id) {
      return tarea;
    }
  }

  return null;
});
