
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/tarea.dart';
import '../domain/task_repository.dart';
import 'tarea_firestore.dart';

class FirestoreTaskRepository implements TaskRepository {
  FirestoreTaskRepository({
    required this.firestore,
    required this.uid,
  });

  final FirebaseFirestore firestore;
  final String uid;

  CollectionReference<Map<String, dynamic>> get _coleccion {
    return firestore
        .collection('usuarios')
        .doc(uid)
        .collection('tareas');
  }

  @override
  Stream<List<Tarea>> observarTareas() {
    return _coleccion.snapshots().map((consulta) {
      return consulta.docs.map((documento) {
        return TareaFirestore.desdeDocumento(documento);
      }).toList();
    });
  }

  @override
  Future<String> agregar(Tarea tarea) async {
    final documento = await _coleccion.add(
      TareaFirestore.aDocumento(tarea),
    );

    return documento.id;
  }

  @override
  Future<void> actualizar(Tarea tarea) async {
    if (tarea.id.isEmpty) {
      throw ArgumentError(
        'La tarea debe tener un identificador válido.',
      );
    }

    await _coleccion.doc(tarea.id).update(
      TareaFirestore.aDocumento(tarea),
    );
  }

  @override
  Future<void> eliminar(String id) async {
    if (id.isEmpty) {
      throw ArgumentError(
        'El identificador de la tarea no puede estar vacío.',
      );
    }

    await _coleccion.doc(id).delete();
  }
}
