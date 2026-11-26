import 'package:taskflow/modelos/tarea.dart';
import 'package:taskflow/modelos/habito_recurrente.dart';

void main() {
  final List<Tarea> tareas = [
    Tarea(
      titulo: 'Hacer tarea de Flutter',
      descripcion: 'Completar actividad de la semana 4',
      fechaLimite: DateTime(2026, 8, 21),
      prioridad: 3,
    ),
    Tarea(
      titulo: 'Ordenar apuntes',
      descripcion: 'Organizar los apuntes de la universidad',
      fechaLimite: DateTime(2026, 8, 22),
      prioridad: 2,
    ),
    HabitoRecurrente(
      titulo: 'Leer 20 minutos',
      descripcion: 'Leer un poco todos los días',
      fechaLimite: DateTime(2026, 8, 21),
      prioridad: 2,
    ),
    HabitoRecurrente(
      titulo: 'Hacer ejercicio',
      descripcion: 'Realizar ejercicio diariamente',
      fechaLimite: DateTime(2026, 8, 21),
      prioridad: 1,
    ),
  ];

  for (Tarea tarea in tareas) {
    tarea.completar();
  }
}
