import 'dart:async';

import '../domain/auth_repository.dart';
import '../domain/usuario.dart';

class MemoriaAuthRepository implements AuthRepository {
  final _sesiones = StreamController<Usuario?>.broadcast();

  Usuario? _usuario;

  @override
  Usuario? get usuarioActual => _usuario;

  @override
  Stream<Usuario?> observarSesion() async* {
    yield _usuario;
    yield* _sesiones.stream;
  }

  @override
  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    if (correo.trim().isEmpty || contrasena.isEmpty) {
      throw ArgumentError('El correo y la contraseña son obligatorios.');
    }

    _usuario = Usuario(uid: 'usuario-prueba', correo: correo.trim());

    _sesiones.add(_usuario);
  }

  @override
  Future<void> registrar({
    required String correo,
    required String contrasena,
  }) async {
    await iniciarSesion(correo: correo, contrasena: contrasena);
  }

  @override
  Future<void> cerrarSesion() async {
    _usuario = null;
    _sesiones.add(null);
  }

  Future<void> dispose() async {
    await _sesiones.close();
  }
}
