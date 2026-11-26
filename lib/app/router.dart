import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/registro_screen.dart';
import '../features/escaneo/domain/propuesta_tarea.dart';
import '../features/escaneo/presentation/escanear_tarea_screen.dart';
import '../features/tareas/presentation/listado_tareas_screen.dart';
import '../features/tareas/presentation/nueva_tarea_screen.dart';
import '../pantallas/taskflow_screen.dart';
import '../pantallas/habitos_screen.dart';
import '../pantallas/tareas_remotas_screen.dart';
import '../pantallas/detalle_tarea_screen.dart';
import '../features/gemini/presentation/gemini_prueba_screen.dart';
import '../features/asistente/presentation/asistente_screen.dart';
import '../features/rendimiento/presentation/rendimiento_screen.dart';

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
        return (enLogin || enRegistro) ? null : '/login';
      }

      if (enLogin || enRegistro || enInicio) {
        return '/tareas';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/inicio',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
        builder: (context, state) {
          final propuesta = state.extra;

          return NuevaTareaScreen(
            inicial: propuesta is PropuestaTarea ? propuesta : null,
          );
        },
      ),
      GoRoute(
        path: '/tareas/escanear',
        builder: (context, state) => const EscanearTareaScreen(),
      ),
      GoRoute(
        path: '/gemini/prueba',
        builder: (context, state) => const GeminiPruebaScreen(),
      ),

      // Semana 19: asistente agéntico.
      GoRoute(
        path: '/asistente',
        builder: (context, state) => const AsistenteScreen(),
      ),

      // Semana 20: laboratorio de rendimiento.
      GoRoute(
        path: '/rendimiento',
        builder: (context, state) => const RendimientoScreen(),
      ),

      GoRoute(
        path: '/taskflow-local',
        builder: (context, state) => const TaskFlowScreen(),
      ),
      GoRoute(
        path: '/habitos',
        builder: (context, state) => const HabitosScreen(),
      ),
      GoRoute(
        path: '/tareas-remotas',
        builder: (context, state) => const TareasRemotasScreen(),
      ),
      GoRoute(
        path: '/tarea',
        builder: (context, state) {
          final tareaId = state.extra;

          if (tareaId is int) {
            return DetalleTareaScreen(tareaId: tareaId);
          }

          return const Scaffold(
            body: Center(child: Text('No se recibió una tarea válida.')),
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
