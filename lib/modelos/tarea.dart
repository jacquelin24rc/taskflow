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

  // Convertir una tarea en datos para SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha_limite': fechaLimite.toIso8601String(),
      'categoria': categoria,
      'prioridad': prioridad,
      'completada': completada ? 1 : 0,
      'recordatorio': recordatorio ? 1 : 0,
    };
  }

  // Convertir los datos de SQLite en una tarea.
  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String,
      fechaLimite: DateTime.parse(map['fecha_limite'] as String),
      categoria: map['categoria'] as String,
      prioridad: map['prioridad'] as int,
      completada: map['completada'] == 1,
      recordatorio: map['recordatorio'] == 1,
    );
  }

  // Convertir los datos recibidos de la API REST.
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
      fechaLimite: DateTime.now().add(const Duration(days: 7)),
      completada: json['completed'] == true,
    );
  }

  // Convertir una tarea para enviarla a la API REST.
  Map<String, dynamic> toJson() {
    return {'title': titulo, 'completed': completada, 'userId': 1};
  }
}
