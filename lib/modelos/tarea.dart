
class Tarea {
  int? id;
  String titulo;
  String descripcion;
  DateTime fechaLimite;
  String categoria;
  bool completada;
  bool recordatorio;
  int _prioridad;

  Tarea({
    this.id,
    required this.titulo,
    this.descripcion = '',
    required this.fechaLimite,
    this.categoria = 'General',
    this.completada = false,
    this.recordatorio = false,
    int prioridad = 2,
  }) : _prioridad = prioridad {
    if (prioridad < 1 || prioridad > 3) {
      throw ArgumentError('La prioridad debe estar entre 1 y 3.');
    }
  }

  int get prioridad => _prioridad;

  set prioridad(int valor) {
    if (valor < 1 || valor > 3) {
      throw ArgumentError('La prioridad debe estar entre 1 y 3.');
    }

    _prioridad = valor;
  }

  void completar() {
    completada = true;
  }

  void activarRecordatorio() {
    recordatorio = true;
  }

  factory Tarea.fromJson(Map<String, dynamic> json) {
    final titulo = json['title'];

    if (titulo is! String || titulo.trim().isEmpty) {
      throw const FormatException(
        'La tarea recibida no tiene un título válido.',
      );
    }

    final id = json['id'];

    return Tarea(
      id: id is int ? id : null,
      titulo: titulo.trim(),
      fechaLimite: DateTime.now().add(
        const Duration(days: 7),
      ),
      completada: json['completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': titulo,
      'completed': completada,
      'userId': 1,
    };
  }
}
