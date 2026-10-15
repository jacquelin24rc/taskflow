
class Tarea {
  String titulo;
  String descripcion;
  DateTime fechaLimite;
  String categoria;
  bool completada;
  bool recordatorio;

  int _prioridad;

  Tarea({
    required this.titulo,
    this.descripcion = '',
    required this.fechaLimite,
    this.categoria = 'General',
    int prioridad = 2,
    this.completada = false,
    this.recordatorio = false,
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
    print('Tarea "$titulo" marcada como completada.');
  }

  void activarRecordatorio() {
    recordatorio = true;
    print('Recordatorio activado para "$titulo"');
  }
}
