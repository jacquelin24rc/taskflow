class Tarea {
  const Tarea({
    required this.id,
    required this.titulo,
    this.descripcion = '',
    this.completada = false,
    this.prioridad = 2,
    this.fechaLimite,
    this.categoria = '',
  }) : assert(prioridad >= 1 && prioridad <= 3);

  final String id;
  final String titulo;
  final String descripcion;
  final bool completada;
  final int prioridad;
  final DateTime? fechaLimite;
  final String categoria;

  Tarea copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    bool? completada,
    int? prioridad,
    DateTime? fechaLimite,
    String? categoria,
  }) {
    return Tarea(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      completada: completada ?? this.completada,
      prioridad: prioridad ?? this.prioridad,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      categoria: categoria ?? this.categoria,
    );
  }
}
