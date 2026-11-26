import 'usuario.dart';

abstract class AuthRepository {
  Stream<Usuario?> observarSesion();

  Usuario? get usuarioActual;

  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  Future<void> registrar({required String correo, required String contrasena});

  Future<void> cerrarSesion();
}
