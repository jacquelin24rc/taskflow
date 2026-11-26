import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/features/tareas/presentation/nueva_tarea_screen.dart';
import 'package:taskflow/features/tareas/presentation/tareas_providers.dart';

import 'escaneo_confirmacion_test.dart' show RepositorioTareasFalso;

Future<void> abrirFormulario(
  WidgetTester tester,
  RepositorioTareasFalso repositorio,
) async {
  final router = GoRouter(
    initialLocation: '/tareas/nueva',
    routes: [
      GoRoute(
        path: '/tareas/nueva',
        builder: (context, state) {
          return const NuevaTareaScreen();
        },
      ),
      GoRoute(
        path: '/tareas',
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('Mis tareas')));
        },
      ),
    ],
  );

  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        firestoreTaskRepositoryProvider.overrideWith((ref) => repositorio),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('El formulario impide guardar una tarea sin título', (
    tester,
  ) async {
    final repositorio = RepositorioTareasFalso();

    await abrirFormulario(tester, repositorio);

    await tester.ensureVisible(find.text('Guardar tarea'));

    await tester.tap(find.text('Guardar tarea'));

    await tester.pumpAndSettle();

    expect(find.text('Ingresa el título de la tarea.'), findsOneWidget);

    expect(repositorio.tareasGuardadas, isEmpty);

    expect(find.byType(NuevaTareaScreen), findsOneWidget);
  });

  testWidgets('El formulario rechaza un título de dos caracteres', (
    tester,
  ) async {
    final repositorio = RepositorioTareasFalso();

    await abrirFormulario(tester, repositorio);

    await tester.enterText(find.byType(TextFormField).first, 'AB');

    await tester.ensureVisible(find.text('Guardar tarea'));

    await tester.tap(find.text('Guardar tarea'));

    await tester.pumpAndSettle();

    expect(
      find.text('El título debe tener al menos 3 caracteres.'),
      findsOneWidget,
    );

    expect(repositorio.tareasGuardadas, isEmpty);

    expect(find.byType(NuevaTareaScreen), findsOneWidget);
  });
}
