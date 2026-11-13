
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../datos/tareas_api.dart';
import '../datos/tareas_db.dart';
import '../modelos/tarea.dart';
import '../repositorios/app_task_repository.dart';
import '../repositorios/task_repository.dart';

final tareasDbProvider = FutureProvider<TareasDb>((ref) async {
  return TareasDb.abrir();
});

final tareasApiProvider = Provider<TareasApi>((ref) {
  final cliente = http.Client();

  ref.onDispose(cliente.close);

  return TareasApi(cliente);
});

final taskRepositoryProvider = FutureProvider<TaskRepository>((ref) async {
  final db = await ref.watch(tareasDbProvider.future);
  final api = ref.watch(tareasApiProvider);

  return AppTaskRepository(db, api: api);
});

final tareasLocalesProvider = FutureProvider<List<Tarea>>((ref) async {
  final repositorio = await ref.watch(taskRepositoryProvider.future);

  return repositorio.obtenerTareas();
});
