import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/registro_screen.dart';
import '../features/tareas/presentation/listado_tareas_screen.dart';
import '../features/tareas/presentation/nueva_tarea_screen.dart';

import '../pantallas/taskflow_screen.dart';
import '../pantallas/habitos_screen.dart';
import '../pantallas/tareas_remotas_screen.dart';
import '../pantallas/detalle_tarea_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notificador = ValueNotifier<int>(0);

  ref.listen(sesionProvider, (anterior, siguiente) {
    notificador.value++;
  });

  final router = GoRouter(
    initialLocation: '/inicio',
    refreshListenable: notificador,
    redirect: (context, state) {
      final sesion = ref.read(sesionProvider);

      final enLogin = state.matchedLocation == '/login';
      final enRegistro = state.matchedLocation == '/registro';
      final enInicio = state.matchedLocation == '/inicio';

      if (sesion.isLoading || sesion.hasError) {
        return enInicio ? null : '/inicio';
      }

      final autenticado = sesion.value != null;

      if (!autenticado) {
        if (enLogin || enRegistro) {
          return null;
        }

        return '/login';
      }

      if (enLogin || enRegistro || enInicio) {
        return '/tareas';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/inicio',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/registro',
        builder: (context, state) => const RegistroScreen(),
      ),

      GoRoute(
        path: '/tareas',
        builder: (context, state) => const ListadoTareasScreen(),
      ),

      GoRoute(
        path: '/tareas/nueva',
        builder: (context, state) => const NuevaTareaScreen(),
      ),

      // Pantalla principal de las semanas anteriores.
      GoRoute(
        path: '/taskflow-local',
        builder: (context, state) => const TaskFlowScreen(),
      ),

      // Pantalla de hábitos.
      GoRoute(
        path: '/habitos',
        builder: (context, state) => const HabitosScreen(),
      ),

      // Tareas de la API anterior.
      GoRoute(
        path: '/tareas-remotas',
        builder: (context, state) => const TareasRemotasScreen(),
      ),

      // Detalle de una tarea local.
      GoRoute(
        path: '/tarea',
        builder: (context, state) {
          final tareaId = state.extra;

          if (tareaId is int) {
            return DetalleTareaScreen(tareaId: tareaId);
          }

          return const Scaffold(
            body: Center(
              child: Text('No se recibió una tarea válida.'),
            ),
          );
        },
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    notificador.dispose();
  });

  return router;
});
