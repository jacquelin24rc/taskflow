import 'package:firebase_auth/firebase_auth.dart';

import '../domain/auth_repository.dart';
import '../domain/usuario.dart';

class AuthException implements Exception {
  const AuthException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  Usuario _convertirUsuario(User usuario) {
    return Usuario(
      uid: usuario.uid,
      correo: usuario.email ?? '',
    );
  }

  @override
  Stream<Usuario?> observarSesion() {
    return _firebaseAuth.authStateChanges().map(
      (usuario) {
        if (usuario == null) {
          return null;
        }

        return _convertirUsuario(usuario);
      },
    );
  }

  @override
  Usuario? get usuarioActual {
    final usuario = _firebaseAuth.currentUser;

    if (usuario == null) {
      return null;
    }

    return _convertirUsuario(usuario);
  }

  @override
  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: correo.trim(),
        password: contrasena,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mensajeError(error.code));
    }
  }

  @override
  Future<void> registrar({
    required String correo,
    required String contrasena,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: correo.trim(),
        password: contrasena,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mensajeError(error.code));
    }
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mensajeError(error.code));
    }
  }

  String _mensajeError(String codigo) {
    switch (codigo) {
      case 'invalid-email':
        return 'El correo electrónico no es válido.';

      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado.';

      case 'weak-password':
        return 'La contraseña es demasiado débil.';

      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'El correo o la contraseña son incorrectos.';

      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';

      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde.';

      case 'network-request-failed':
        return 'No se pudo establecer conexión a Internet.';

      case 'operation-not-allowed':
        return 'El inicio de sesión con correo y contraseña no está habilitado.';

      default:
        return 'Ocurrió un error de autenticación. Inténtalo nuevamente.';
    }
  }
}
