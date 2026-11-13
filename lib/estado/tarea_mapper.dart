
import '../modelos/tarea.dart';
import 'task_state.dart';

class TareaMapper {
  static TareaEstado aEstado(Tarea tarea) {
    final fecha = tarea.fechaLimite;

    final fechaTexto =
        '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';

    final prioridadTexto = switch (tarea.prioridad) {
      1 => 'Alta',
      2 => 'Media',
      _ => 'Baja',
    };

    return TareaEstado(
      id: tarea.id!,
      titulo: tarea.titulo,
      meta: '$fechaTexto · ${tarea.categoria}',
      prioridad: prioridadTexto,
      completada: tarea.completada,
    );
  }
}
