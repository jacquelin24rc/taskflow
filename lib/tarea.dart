class Tarea {
  String titulo;
  String descripcion;
  DateTime fechaLimite;
  bool completada = false;

  // Atributo agregado para TaskFlow
  bool recordatorio = false;

  int _prioridad;

  Tarea({
    required this.titulo,
    this.descripcion = '',
    required this.fechaLimite,
    int prioridad = 2,
  }) : _prioridad = prioridad;

  int get prioridad => _prioridad;

  set prioridad(int valor) {
    if (valor >= 1 && valor <= 3) {
      _prioridad = valor;
    } else {
      print('La prioridad debe estar entre 1 y 3');
    }
  }

  void completar() {
    completada = true;
    print('Tarea "$titulo" marcada como completada');
  }

  // Método agregado para manejar el recordatorio
  void activarRecordatorio() {
    recordatorio = true;
    print('Recordatorio activado para "$titulo"');
  }
}
