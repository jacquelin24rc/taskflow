
import 'dart:async';

Future<String> cargarPerfil() =>
    Future.delayed(const Duration(seconds: 2), () => 'Ana');

Future<int> cargarPendientes(String perfil) async {
  await Future.delayed(const Duration(seconds: 3));

  print('Consultando las tareas de $perfil');
  return 7;
}

Future<void> main() async {
  final reloj = Stopwatch()..start();

  final perfil = await cargarPerfil();
  final pendientes = await cargarPendientes(perfil);

  print(
    'Tiempo total: ${reloj.elapsed.inSeconds} s',
  );

  print('Perfil: $perfil');
  print('Tareas pendientes: $pendientes');

  reloj.stop();
}
