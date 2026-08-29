import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TaskFlowScreen(),
    );
  }
}

class TaskFlowScreen extends StatelessWidget {
  const TaskFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                // Barra superior
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

                // Cabecera con insignia superpuesta
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
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Buenos días, Jacquelin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Viernes 28 de agosto',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            '4 tareas registradas',
                            style: TextStyle(
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

                // Estadísticas
                const Row(
                  children: [
                    Expanded(
                      child: TarjetaEstadistica(
                        valor: '4',
                        etiqueta: 'Tareas',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TarjetaEstadistica(
                        valor: '0',
                        etiqueta: 'Completadas',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TarjetaEstadistica(
                        valor: '2',
                        etiqueta: 'Hábitos',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Encabezado de tareas
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

                const TarjetaTarea(
                  titulo:
                      'Completar el laboratorio de Flutter sobre layouts y composición visual',
                  meta: '21 ago · Universidad',
                  prioridad: 'Alta',
                ),

                const SizedBox(height: 10),

                const TarjetaTarea(
                  titulo:
                      'Ordenar todos los apuntes y actividades pendientes de la universidad',
                  meta: '22 ago · Universidad',
                  prioridad: 'Media',
                ),

                const SizedBox(height: 10),

                const TarjetaTarea(
                  titulo:
                      'Leer 20 minutos todos los días para mantener el hábito de lectura',
                  meta: '21 ago · Hábito',
                  prioridad: 'Media',
                ),

                const SizedBox(height: 10),

                const TarjetaTarea(
                  titulo:
                      'Hacer ejercicio diariamente para mantener una rutina saludable',
                  meta: '21 ago · Hábito',
                  prioridad: 'Baja',
                ),

                const SizedBox(height: 12),

                // Frase
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEBF7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    '“La disciplina es el puente entre las metas y los logros que realmente importan.”\n— Jim Rohn',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF453A7A),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Barra inferior
                Container(
                  width: double.infinity,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      BottomItem(
                        icon: Icons.list,
                        label: 'Tareas',
                        active: true,
                      ),
                      BottomItem(
                        icon: Icons.water_drop,
                        label: 'Hábitos',
                      ),
                      BottomItem(
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


// WIDGET REUTILIZABLE: TARJETA DE ESTADÍSTICA


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


// WIDGET REUTILIZABLE: TARJETA DE TAREA


class TarjetaTarea extends StatelessWidget {
  final String titulo;
  final String meta;
  final String prioridad;
  final bool completada;

  const TarjetaTarea({
    super.key,
    required this.titulo,
    required this.meta,
    required this.prioridad,
    this.completada = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            completada
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            size: 22,
            color: const Color(0xFF453A7A),
          ),

          const SizedBox(width: 10),

          // Expanded evita el overflow horizontal.
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
                    decoration:
                        completada
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
        ],
      ),
    );
  }
}


// WIDGET REUTILIZABLE: BARRA INFERIOR


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
          color:
              active
                  ? const Color(0xFF453A7A)
                  : Colors.grey,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color:
                active
                    ? const Color(0xFF453A7A)
                    : Colors.grey,
          ),
        ),
      ],
    );
  }
}