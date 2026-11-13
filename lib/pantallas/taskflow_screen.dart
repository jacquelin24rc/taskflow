
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datos/preferencias_service.dart';
import '../estado/task_notifier.dart';
import '../estado/tareas_remotas_provider.dart';
import '../modelos/tarea.dart';
import '../widgets/tarjeta_estadistica.dart';
import '../widgets/tarjeta_tarea.dart';
import '../widgets/bottom_item.dart';
import 'nueva_tarea_screen.dart';

class TaskFlowScreen extends ConsumerStatefulWidget {
  const TaskFlowScreen({super.key});

  @override
  ConsumerState<TaskFlowScreen> createState() => _TaskFlowScreenState();
}

class _TaskFlowScreenState extends ConsumerState<TaskFlowScreen> {
  final PreferenciasService _preferencias = PreferenciasService();
  bool _soloPendientes = false;

  @override
  void initState() {
    super.initState();
    _cargarPreferencia();
    Future.microtask(_cargarTareas);
  }

  Future<void> _cargarPreferencia() async {
    final valor = await _preferencias.obtenerSoloPendientes();
    if (!mounted) return;
    setState(() => _soloPendientes = valor);
  }

  Future<void> _cambiarFiltro(bool valor) async {
    setState(() => _soloPendientes = valor);
    await _preferencias.guardarSoloPendientes(valor);
  }

  Future<void> _cargarTareas() async {
    try {
      await ref.read(taskProvider.notifier).cargarTareas();
    } catch (error) {
      if (!mounted) return;
      _mostrarMensaje('No se pudieron cargar las tareas: $error');
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  Future<void> _alternarTarea(int id) async {
    try {
      await ref.read(taskProvider.notifier).alternarCompletada(id);
    } catch (error) {
      _mostrarMensaje('No se pudo actualizar la tarea: $error');
    }
  }

  Future<void> _eliminarTarea(int id) async {
    try {
      await ref.read(taskProvider.notifier).eliminarTarea(id);
    } catch (error) {
      _mostrarMensaje('No se pudo eliminar la tarea: $error');
    }
  }

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

    // Primero guardar en SQLite para conservar la tarea al reiniciar.
    try {
      await ref.read(taskProvider.notifier).agregarTarea(nuevaTarea);
    } catch (error) {
      _mostrarMensaje('No se pudo guardar la tarea: $error');
      return;
    }

    // La API de demostración es independiente de SQLite.
    // Se usa otra instancia para no sobrescribir el ID local.
    final tareaRemota = Tarea(
      titulo: nuevaTarea.titulo,
      descripcion: nuevaTarea.descripcion,
      fechaLimite: nuevaTarea.fechaLimite,
      categoria: nuevaTarea.categoria,
      prioridad: nuevaTarea.prioridad,
      completada: nuevaTarea.completada,
      recordatorio: nuevaTarea.recordatorio,
    );

    try {
      await ref.read(tareasRemotasProvider.notifier).crear(tareaRemota);
      _mostrarMensaje('Tarea guardada en SQLite y enviada a la API.');
    } catch (error) {
      _mostrarMensaje(
        'Tarea guardada en SQLite. No se pudo enviar a la API: $error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final taskState = ref.watch(taskProvider);
    final totalTareas = taskState.tareas.length;
    final completadas = taskState.tareas
        .where((tarea) => tarea.completada)
        .length;

    final tareasVisibles = _soloPendientes
        ? taskState.tareas.where((tarea) => !tarea.completada).toList()
        : taskState.tareas;

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

                // Agregar una tarea.
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

                // Acceso a las tareas de la API.
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

                // Filtro persistente de tareas pendientes.
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Solo pendientes'),
                  value: _soloPendientes,
                  onChanged: _cambiarFiltro,
                  activeThumbColor: const Color(0xFF453A7A),
                ),

                // Listado de tareas.
                ...tareasVisibles.map(
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
                      onToggle: () => _alternarTarea(tarea.id),
                      onEliminar: () => _eliminarTarea(tarea.id),
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
