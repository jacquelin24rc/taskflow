import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/registro_screen.dart';
import '../features/tareas/presentation/listado_tareas_screen.dart';
import '../features/tareas/presentation/nueva_tarea_screen.dart';

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

      if (sesion.isLoading) {
        return enInicio ? null : '/inicio';
      }

      if (sesion.hasError) {
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
    ],
  );

  ref.onDispose(() {
    router.dispose();
    notificador.dispose();
  });

  return router;
});
