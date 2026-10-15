
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../estado/tareas_remotas_provider.dart';
import '../modelos/tarea.dart';

class TareasRemotasScreen extends ConsumerStatefulWidget {
  const TareasRemotasScreen({super.key});

  @override
  ConsumerState<TareasRemotasScreen> createState() =>
      _TareasRemotasScreenState();
}

class _TareasRemotasScreenState
    extends ConsumerState<TareasRemotasScreen> {
  final _tituloController = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  Future<void> _crearTarea() async {
    final titulo = _tituloController.text.trim();

    if (titulo.length < 3 || titulo.length > 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El título debe tener entre 3 y 60 caracteres.',
          ),
        ),
      );
      return;
    }

    final nuevaTarea = Tarea(
      titulo: titulo,
      fechaLimite: DateTime.now().add(
        const Duration(days: 7),
      ),
    );

    setState(() {
      _enviando = true;
    });

    try {
      await ref.read(tareasRemotasProvider.notifier).crear(nuevaTarea);

      if (!mounted) return;

      _tituloController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarea enviada correctamente.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo enviar la tarea: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tareasAsync = ref.watch(tareasRemotasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas en la nube'),
        backgroundColor: const Color(0xFF453A7A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Recargar tareas',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(tareasRemotasProvider.notifier).recargar();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _tituloController,
                  maxLength: 60,
                  decoration: const InputDecoration(
                    labelText: 'Título de la tarea',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cloud_upload_outlined),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _enviando ? null : _crearTarea,
                    icon: const Icon(Icons.cloud_upload),
                    label: Text(
                      _enviando
                          ? 'Enviando...'
                          : 'Enviar tarea a la API',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tareasAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off,
                        size: 50,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No se pudieron cargar las tareas.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$error',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(tareasRemotasProvider.notifier)
                              .recargar();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (List<Tarea> tareas) {
                if (tareas.isEmpty) {
                  return const Center(
                    child: Text('No hay tareas disponibles.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () {
                    return ref
                        .read(tareasRemotasProvider.notifier)
                        .recargar();
                  },
                  child: ListView.builder(
                    itemCount: tareas.length,
                    itemBuilder: (context, index) {
                      final tarea = tareas[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: Icon(
                            tarea.completada
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: const Color(0xFF453A7A),
                          ),
                          title: Text(tarea.titulo),
                          subtitle: Text(
                            'ID: ${tarea.id ?? "Sin ID"}',
                          ),
                          trailing: Text(
                            tarea.completada
                                ? 'Completada'
                                : 'Pendiente',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
