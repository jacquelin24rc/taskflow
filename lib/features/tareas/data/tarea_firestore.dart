
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/tarea.dart';

class TareaFirestore {
  static Tarea desdeDocumento(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final datos = documento.data();

    if (datos == null) {
      throw const FormatException(
        'El documento de la tarea no contiene datos.',
      );
    }

    return Tarea(
      id: documento.id,
      titulo: datos['titulo'] as String,
      descripcion: datos['descripcion'] as String? ?? '',
      completada: datos['completada'] as bool? ?? false,
      prioridad: datos['prioridad'] as int? ?? 2,
      fechaLimite: (datos['fechaLimite'] as Timestamp?)?.toDate(),
      categoria: datos['categoria'] as String? ?? '',
    );
  }

  static Map<String, dynamic> aDocumento(Tarea tarea) {
    return {
      'titulo': tarea.titulo,
      'descripcion': tarea.descripcion,
      'completada': tarea.completada,
      'prioridad': tarea.prioridad,
      'fechaLimite': tarea.fechaLimite == null
          ? null
          : Timestamp.fromDate(tarea.fechaLimite!),
      'categoria': tarea.categoria,
    };
  }
}
