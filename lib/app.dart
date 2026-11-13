import 'package:flutter/material.dart';

import 'pantallas/detalle_tarea_screen.dart';
import 'pantallas/habitos_screen.dart';
import 'pantallas/taskflow_screen.dart';
import 'pantallas/tareas_remotas_screen.dart';

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