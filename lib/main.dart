
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_notifier.dart';
import 'task_state.dart';
import 'detalle_tarea_screen.dart';
import 'habitos_screen.dart';
import 'tarea.dart';
import 'pantallas/nueva_tarea_screen.dart';
import 'pantallas/tareas_remotas_screen.dart';
import 'estado/tareas_remotas_provider.dart';
import 'modelos/tarea.dart' as modelo;

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const TaskFlowScreen(),
        '/habitos': (context) => const HabitosScreen(),
        '/tareas-remotas': (context) => const TareasRemotasScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/tarea') {
          final tareaId = settings.arguments;

          if (tareaId is int) {
            return MaterialPageRoute(
              builder: (context) => DetalleTareaScreen(
                tareaId: tareaId,
              ),
            );
          }

          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Detalle de tarea'),
              ),
              body: const Center(
                child: Text('No se recibió una tarea válida.'),
              ),
            ),
          );
        }

        return null;
      },
    );
  }
}

class TaskFlowScreen extends ConsumerWidget {
  const TaskFlowScreen({super.key});

  Future<void> _agregarTarea(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nuevaTarea = await Navigator.push<Tarea>(
      context,
      MaterialPageRoute<Tarea>(
        builder: (context) => const NuevaTareaScreen(),
      ),
    );

    if (nuevaTarea == null || !context.mounted) {
      return;
    }

    final fecha = nuevaTarea.fechaLimite;

    final fechaTexto =
        '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';

    final prioridadTexto = switch (nuevaTarea.prioridad) {
      1 => 'Alta',
      2 => 'Media',
      _ => 'Baja',
    };

    // Guardar la tarea localmente, como en la Semana 13.
    ref.read(taskProvider.notifier).agregarTarea(
      TareaEstado(
        id: DateTime.now().microsecondsSinceEpoch,
        titulo: nuevaTarea.titulo,
        meta: '$fechaTexto · ${nuevaTarea.categoria}',
        prioridad: prioridadTexto,
      ),
    );

    // Semana 14: enviar la misma tarea a la API REST.
    try {
      final tareaParaApi = modelo.Tarea(
        titulo: nuevaTarea.titulo,
        descripcion: nuevaTarea.descripcion,
        fechaLimite: nuevaTarea.fechaLimite,
        categoria: nuevaTarea.categoria,
        prioridad: nuevaTarea.prioridad,
        completada: nuevaTarea.completada,
      );

      await ref
          .read(tareasRemotasProvider.notifier)
          .crear(tareaParaApi);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tarea guardada y enviada correctamente a la API.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'La tarea se guardó localmente, pero no se pudo '
            'enviar a la API: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);

    final totalTareas = taskState.tareas.length;

    final completadas = taskState.tareas
        .where((tarea) => tarea.completada)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra superior.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TaskFlow',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C215C),
                      ),
                    ),
                    const CircleAvatar(
                      backgroundColor: Color(0xFFE4E1F0),
                      child: Text(
                        'J',
                        style: TextStyle(
                          color: Color(0xFF453A7A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Cabecera principal.
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 104,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF453A7A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Buenos días, Jacquelin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Viernes 28 de agosto',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$totalTareas tareas registradas',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: -38,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE8AA33),
                            width: 4,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '60%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF453A7A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // Estadísticas.
                Row(
                  children: [
                    Expanded(
                      child: TarjetaEstadistica(
                        valor: '$totalTareas',
                        etiqueta: 'Tareas',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TarjetaEstadistica(
                        valor: '$completadas',
                        etiqueta: 'Completadas',
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: TarjetaEstadistica(
                        valor: '2',
                        etiqueta: 'Hábitos',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Encabezado de tareas.
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tareas de hoy',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                    Text(
                      'Ver todas',
                      style: TextStyle(
                        color: Color(0xFFE8AA33),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Formulario de la Semana 13.
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _agregarTarea(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar tarea'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF453A7A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Semana 14: acceso a las tareas de Internet.
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/tareas-remotas',
                      );
                    },
                    icon: const Icon(Icons.cloud_outlined),
                    label: const Text('Tareas en la nube'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF453A7A),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      side: const BorderSide(
                        color: Color(0xFF453A7A),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Tareas locales administradas con Riverpod.
                ...taskState.tareas.map(
                  (tarea) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TarjetaTarea(
                      titulo: tarea.titulo,
                      meta: tarea.meta,
                      prioridad: tarea.prioridad,
                      completada: tarea.completada,
                      onAbrir: () {
                        Navigator.pushNamed(
                          context,
                          '/tarea',
                          arguments: tarea.id,
                        );
                      },
                      onToggle: () {
                        ref
                            .read(taskProvider.notifier)
                            .alternarCompletada(tarea.id);
                      },
                      onEliminar: () {
                        ref
                            .read(taskProvider.notifier)
                            .eliminarTarea(tarea.id);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                // Frase motivacional.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEBF7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    '“La disciplina es el puente entre las metas y '
                    'los logros que realmente importan.”\n'
                    '— Jim Rohn',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF453A7A),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Barra inferior.
                Container(
                  width: double.infinity,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const BottomItem(
                        icon: Icons.list,
                        label: 'Tareas',
                        active: true,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/habitos',
                          );
                        },
                        child: const BottomItem(
                          icon: Icons.water_drop,
                          label: 'Hábitos',
                        ),
                      ),
                      const BottomItem(
                        icon: Icons.person_outline,
                        label: 'Perfil',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Tarjeta de estadística.
class TarjetaEstadistica extends StatelessWidget {
  final String valor;
  final String etiqueta;

  const TarjetaEstadistica({
    super.key,
    required this.valor,
    required this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            valor,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C215C),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            etiqueta,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Tarjeta de tarea.
class TarjetaTarea extends StatelessWidget {
  final String titulo;
  final String meta;
  final String prioridad;
  final bool completada;
  final VoidCallback onToggle;
  final VoidCallback onEliminar;
  final VoidCallback onAbrir;

  const TarjetaTarea({
    super.key,
    required this.titulo,
    required this.meta,
    required this.prioridad,
    required this.completada,
    required this.onToggle,
    required this.onEliminar,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAbrir,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: completada
                  ? 'Marcar como pendiente'
                  : 'Marcar como completada',
              onPressed: onToggle,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                completada
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 22,
                color: const Color(0xFF453A7A),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: completada
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    meta,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F0F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                prioridad,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF453A7A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 4),

            IconButton(
              tooltip: 'Eliminar tarea',
              onPressed: onEliminar,
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Elementos de la barra inferior.
class BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const BottomItem({
    super.key,
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: active
              ? const Color(0xFF453A7A)
              : Colors.grey,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: active
                ? const Color(0xFF453A7A)
                : Colors.grey,
          ),
        ),
      ],
    );
  }
}
