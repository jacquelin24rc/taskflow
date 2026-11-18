import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/usuario.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);

  return FirebaseAuthRepository(firebaseAuth);
});

final sesionProvider = StreamProvider<Usuario?>((ref) {
  final repositorio = ref.watch(authRepositoryProvider);

  return repositorio.observarSesion();
});
