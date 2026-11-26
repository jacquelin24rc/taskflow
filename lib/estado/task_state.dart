class TareaEstado {
  final int id;
  final String titulo;
  final String meta;
  final String prioridad;
  final bool completada;

  const TareaEstado({
    required this.id,
    required this.titulo,
    required this.meta,
    required this.prioridad,
    this.completada = false,
  });

  TareaEstado copyWith({
    int? id,
    String? titulo,
    String? meta,
    String? prioridad,
    bool? completada,
  }) {
    return TareaEstado(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      meta: meta ?? this.meta,
      prioridad: prioridad ?? this.prioridad,
      completada: completada ?? this.completada,
    );
  }
}

class TaskState {
  final List<TareaEstado> tareas;
  final String filtroActivo;

  const TaskState({required this.tareas, this.filtroActivo = 'todas'});

  TaskState copyWith({List<TareaEstado>? tareas, String? filtroActivo}) {
    return TaskState(
      tareas: tareas ?? this.tareas,
      filtroActivo: filtroActivo ?? this.filtroActivo,
    );
  }
}
