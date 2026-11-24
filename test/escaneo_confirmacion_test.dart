
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/features/escaneo/domain/propuesta_tarea.dart';
import 'package:taskflow/features/tareas/domain/tarea.dart';
import 'package:taskflow/features/tareas/domain/task_repository.dart';
import 'package:taskflow/features/tareas/presentation/nueva_tarea_screen.dart';
import 'package:taskflow/features/tareas/presentation/tareas_providers.dart';

class RepositorioTareasFalso implements TaskRepository {
  final List<Tarea> tareasGuardadas = [];

  @override
  Stream<List<Tarea>> observarTareas() {
    return Stream.value(tareasGuardadas);
  }

  @override
  Future<String> agregar(Tarea tarea) async {
    tareasGuardadas.add(tarea);
    return 'tarea-prueba';
  }

  @override
  Future<void> actualizar(Tarea tarea) async {}

  @override
  Future<void> eliminar(String id) async {}
}

void main() {
  testWidgets(
    'El escaneo requiere confirmacion antes de guardar',
    (tester) async {
      final repositorio = RepositorioTareasFalso();

      final fecha = DateTime.now().add(
        const Duration(days: 5),
      );

      final propuesta = PropuestaTarea(
        titulo: 'Tarea de Matematica',
        descripcion: 'Resolver ejercicios del capitulo 5.',
        fechaLimite: fecha,
      );

      final router = GoRouter(
        initialLocation: '/tareas/nueva',
        routes: [
          GoRoute(
            path: '/tareas/nueva',
            builder: (context, state) {
              return NuevaTareaScreen(
                inicial: propuesta,
              );
            },
          ),
          GoRoute(
            path: '/tareas',
            builder: (context, state) {
              return const Scaffold(
                body: Center(
                  child: Text('Mis tareas'),
                ),
              );
            },
          ),
        ],
      );

      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreTaskRepositoryProvider.overrideWith(
              (ref) => repositorio,
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Comprueba que el formulario recibe los datos.
      expect(
        find.text('Tarea de Matematica'),
        findsOneWidget,
      );

      expect(
        find.text('Resolver ejercicios del capitulo 5.'),
        findsOneWidget,
      );

      expect(
        find.text('Datos detectados en la foto'),
        findsOneWidget,
      );

      // Abrir el formulario no debe guardar nada.
      expect(repositorio.tareasGuardadas, isEmpty);

      // El guardado requiere una accion del usuario.
      await tester.ensureVisible(
        find.text('Guardar tarea'),
      );

      await tester.tap(
        find.text('Guardar tarea'),
      );

      await tester.pumpAndSettle();

      // Se guarda exactamente una tarea.
      expect(
        repositorio.tareasGuardadas.length,
        1,
      );

      final tarea = repositorio.tareasGuardadas.single;

      expect(
        tarea.titulo,
        'Tarea de Matematica',
      );

      expect(
        tarea.descripcion,
        'Resolver ejercicios del capitulo 5.',
      );

      expect(
        tarea.fechaLimite?.year,
        fecha.year,
      );

      expect(
        tarea.fechaLimite?.month,
        fecha.month,
      );

      expect(
        tarea.fechaLimite?.day,
        fecha.day,
      );
    },
  );
}
