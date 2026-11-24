
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/auth_providers.dart';
import '../domain/tarea.dart';
import 'tareas_providers.dart';

class ListadoTareasScreen extends ConsumerWidget {
  const ListadoTareasScreen({super.key});

  Future<void> _cerrarSesion(
    WidgetRef ref,
    BuildContext context,
  ) async {
    try {
      await ref.read(authRepositoryProvider).cerrarSesion();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo cerrar la sesión.'),
          ),
        );
      }
    }
  }

  Future<void> _alternarCompletada(
    WidgetRef ref,
    BuildContext context,
    Tarea tarea,
  ) async {
    try {
      final repositorio = ref.read(
        firestoreTaskRepositoryProvider,
      );

      if (repositorio == null) {
        throw StateError('No hay una sesión activa.');
      }

      await repositorio.actualizar(
        tarea.copyWith(
          completada: !tarea.completada,
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo actualizar la tarea.'),
          ),
        );
      }
    }
  }

  Future<void> _eliminarTarea(
    WidgetRef ref,
    BuildContext context,
    Tarea tarea,
  ) async {
    try {
      final repositorio = ref.read(
        firestoreTaskRepositoryProvider,
      );

      if (repositorio == null) {
        throw StateError('No hay una sesión activa.');
      }

      await repositorio.eliminar(tarea.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo eliminar la tarea.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tareasAsync = ref.watch(tareasFirestoreProvider);
    final sesion = ref.watch(sesionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis tareas'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => _cerrarSesion(ref, context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (sesion.value != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Cuenta: ${sesion.value!.correo}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/taskflow-local');
                },
                icon: const Icon(Icons.dashboard_outlined),
                label: const Text(
                  'Ver TaskFlow anterior (SQLite y hábitos)',
                ),
              ),
            ),
          ),

          // Semana 19: acceso a la prueba de Gemini.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/gemini/prueba');
                },
                icon: const Icon(Icons.smart_toy_outlined),
                label: const Text('Probar Gemini'),
              ),
            ),
          ),

          // Semana 19: acceso al asistente agéntico.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/asistente');
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Asistente de TaskFlow'),
              ),
            ),
          ),

          Expanded(
            child: tareasAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No se pudieron cargar las tareas. '
                    'Verifica tu conexión y los permisos de Firestore.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (tareas) {
                if (tareas.isEmpty) {
                  return const Center(
                    child: Text(
                      'Todavía no tienes tareas guardadas.',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tareas.length,
                  itemBuilder: (context, index) {
                    final tarea = tareas[index];

                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: tarea.completada,
                          onChanged: (_) {
                            _alternarCompletada(
                              ref,
                              context,
                              tarea,
                            );
                          },
                        ),
                        title: Text(
                          tarea.titulo,
                          style: TextStyle(
                            decoration: tarea.completada
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          tarea.descripcion.isEmpty
                              ? 'Prioridad: ${tarea.prioridad}'
                              : '${tarea.descripcion}\n'
                                  'Prioridad: ${tarea.prioridad}',
                        ),
                        isThreeLine: tarea.descripcion.isNotEmpty,
                        trailing: IconButton(
                          tooltip: 'Eliminar tarea',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            _eliminarTarea(
                              ref,
                              context,
                              tarea,
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'escanear_tarea',
            onPressed: () => context.push('/tareas/escanear'),
            icon: const Icon(Icons.document_scanner),
            label: const Text('Escanear tarea'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'nueva_tarea',
            onPressed: () => context.go('/tareas/nueva'),
            icon: const Icon(Icons.add),
            label: const Text('Nueva tarea'),
          ),
        ],
      ),
    );
  }
}
