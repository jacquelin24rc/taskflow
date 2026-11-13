import 'tarea.dart';

class HabitoRecurrente extends Tarea {
  int racha;

  HabitoRecurrente({
    required super.titulo,
    super.descripcion = '',
    required super.fechaLimite,
    super.prioridad = 2,
    this.racha = 0,
  });

  @override
  void completar() {
    super.completar();
    racha++;
  }
}