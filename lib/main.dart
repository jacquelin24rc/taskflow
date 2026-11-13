
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'datos/tareas_db.dart';
import 'modelos/tarea.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Abrir la base de datos SQLite.
  final db = await TareasDb.abrir();

  // Consultar las tareas guardadas.
  final tareasGuardadas = await db.todas();

  // Insertar una tarea de prueba solamente si no existe.
  if (!tareasGuardadas.any(
    (tarea) => tarea.titulo == 'Prueba SQLite Semana 16',
  )) {
    final tareaPrueba = Tarea(
      titulo: 'Prueba SQLite Semana 16',
      descripcion: 'Comprobar almacenamiento local',
      fechaLimite: DateTime(2026, 12, 15),
      categoria: 'Estudio',
      prioridad: 2,
    );

    await db.insertar(tareaPrueba);
  }

  // Mostrar las tareas almacenadas.
  final tareas = await db.todas();

  for (final tarea in tareas) {
    debugPrint(
      'SQLite: ${tarea.id} - ${tarea.titulo}',
    );
  }

  // Iniciar TaskFlow normalmente.
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
