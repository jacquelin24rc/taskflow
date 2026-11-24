
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/taskflow_app.dart';
import 'datos/tareas_db.dart';
import 'firebase_options.dart';
import 'modelos/tarea.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase para la Semana 17.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Semana 19: configurar App Check para pruebas.
  // En modo debug se utiliza el proveedor de depuracion.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider(),
  );

  // Conservar la base de datos SQLite de la Semana 16.
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

  // Mostrar las tareas almacenadas en SQLite.
  final tareas = await db.todas();

  for (final tarea in tareas) {
    debugPrint(
      'SQLite: ${tarea.id} - ${tarea.titulo}',
    );
  }

  // Iniciar TaskFlow con la arquitectura de Semana 17.
  runApp(
    const ProviderScope(
      child: TaskFlowApp(),
    ),
  );
}
