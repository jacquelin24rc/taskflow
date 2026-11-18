import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/firestore_task_repository.dart';
import '../domain/tarea.dart';
import '../domain/task_repository.dart';

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firestoreTaskRepositoryProvider = Provider<TaskRepository?>((ref) {
  final sesion = ref.watch(sesionProvider);
  final usuario = sesion.value;

  if (usuario == null) {
    return null;
  }

  final firestore = ref.watch(firebaseFirestoreProvider);

  return FirestoreTaskRepository(
    firestore: firestore,
    uid: usuario.uid,
  );
});

final tareasFirestoreProvider = StreamProvider<List<Tarea>>((ref) {
  final repositorio = ref.watch(firestoreTaskRepositoryProvider);

  if (repositorio == null) {
    return Stream.value(<Tarea>[]);
  }

  return repositorio.observarTareas();
});
