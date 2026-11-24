
import 'dart:developer' as developer;

Future<String> cargarPerfil() =>
    Future.delayed(const Duration(seconds: 2), () => 'Ana');

Future<int> cargarPendientes(String perfil) async {
  await Future.delayed(const Duration(seconds: 3));

  developer.log('Consultando las tareas de $perfil');
  return 7;
}

Future<void> main() async {
  final reloj = Stopwatch()..start();

  final perfil = await cargarPerfil();
  final pendientes = await cargarPendientes(perfil);

  developer.log(
    'Tiempo total: ${reloj.elapsed.inSeconds} s',
  );

  developer.log('Perfil: $perfil');
  developer.log('Tareas pendientes: $pendientes');

  reloj.stop();
}
