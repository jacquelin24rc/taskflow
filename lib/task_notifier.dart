import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_state.dart';

class TaskNotifier extends Notifier<TaskState> {
  @override
  TaskState build() {
    return const TaskState(
      tareas: [
        TareaEstado(
          id: 1,
          titulo:
              'Completar el laboratorio de Flutter sobre layouts y composición visual',
          meta: '21 ago · Universidad',
          prioridad: 'Alta',
        ),
        TareaEstado(
          id: 2,
          titulo:
              'Ordenar todos los apuntes y actividades pendientes de la universidad',
          meta: '22 ago · Universidad',
          prioridad: 'Media',
        ),
        TareaEstado(
          id: 3,
          titulo:
              'Leer 20 minutos todos los días para mantener el hábito de lectura',
          meta: '21 ago · Hábito',
          prioridad: 'Media',
        ),
        TareaEstado(
          id: 4,
          titulo:
              'Hacer ejercicio diariamente para mantener una rutina saludable',
          meta: '21 ago · Hábito',
          prioridad: 'Baja',
        ),
      ],
    );
  }

  void agregarTarea(TareaEstado nuevaTarea) {
    state = state.copyWith(
      tareas: [...state.tareas, nuevaTarea],
    );
  }

  void alternarCompletada(int id) {
    final nuevasTareas = state.tareas.map((tarea) {
      if (tarea.id == id) {
        return tarea.copyWith(
          completada: !tarea.completada,
        );
      }
      return tarea;
    }).toList();

    state = state.copyWith(
      tareas: nuevasTareas,
    );
  }

  void eliminarTarea(int id) {
    final nuevasTareas =
        state.tareas.where((tarea) => tarea.id != id).toList();

    state = state.copyWith(
      tareas: nuevasTareas,
    );
  }

  void cambiarFiltro(String nuevoFiltro) {
    state = state.copyWith(
      filtroActivo: nuevoFiltro,
    );
  }
}

final taskProvider = NotifierProvider<TaskNotifier, TaskState>(
  TaskNotifier.new,
);