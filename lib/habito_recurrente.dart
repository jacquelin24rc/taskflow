import 'tarea.dart';

class HabitoRecurrente extends Tarea {
  int racha;

  HabitoRecurrente({
    required String titulo,
    String descripcion = '',
    required DateTime fechaLimite,
    int prioridad = 2,
    this.racha = 0,
  }) : super(
          titulo: titulo,
          descripcion: descripcion,
          fechaLimite: fechaLimite,
          prioridad: prioridad,
        );

  @override
  void completar() {
    super.completar();
    racha++;
    print('Racha actual: $racha');
  }
}