import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../estado/task_notifier.dart';

class DetalleTareaScreen extends ConsumerWidget {
  final int tareaId;

  const DetalleTareaScreen({
    super.key,
    required this.tareaId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tarea = ref.watch(
      taskByIdProvider(tareaId),
    );

    if (tarea == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de tarea'),
        ),
        body: const Center(
          child: Text(
            'La tarea no existe o fue eliminada.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tarea.titulo,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Meta: ${tarea.meta}'),
            const SizedBox(height: 8),
            Text('Prioridad: ${tarea.prioridad}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(taskProvider.notifier)
                    .alternarCompletada(tarea.id);
              },
              child: Text(
                tarea.completada
                    ? 'Marcar como pendiente'
                    : 'Marcar como completada',
              ),
            ),
          ],
        ),
      ),
    );
  }
}