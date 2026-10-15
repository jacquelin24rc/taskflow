
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../datos/tareas_api.dart';
import '../modelos/tarea.dart';

// Cliente HTTP compartido.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();

  ref.onDispose(client.close);

  return client;
});

// Servicio encargado de comunicarse con la API.
final tareasApiProvider = Provider<TareasApi>((ref) {
  return TareasApi(ref.watch(httpClientProvider));
});

// Provider que administra las tareas remotas.
final tareasRemotasProvider =
    AsyncNotifierProvider<TareasRemotasNotifier, List<Tarea>>(
  TareasRemotasNotifier.new,
);

class TareasRemotasNotifier extends AsyncNotifier<List<Tarea>> {
  // Carga las tareas cuando se abre la pantalla.
  @override
  Future<List<Tarea>> build() {
    return ref.watch(tareasApiProvider).obtenerTareas();
  }

  // Permite actualizar la lista desde Internet.
  Future<void> recargar() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(tareasApiProvider).obtenerTareas(),
    );
  }

  // Envía una tarea y la agrega a la lista.
  Future<void> crear(Tarea tarea) async {
    final creada = await ref.read(tareasApiProvider).crearTarea(tarea);

    final tareasActuales = state.asData?.value ?? <Tarea>[];

    state = AsyncData([
      creada,
      ...tareasActuales,
    ]);
  }
}
