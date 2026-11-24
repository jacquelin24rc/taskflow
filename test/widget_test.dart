
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/app.dart';
import 'package:taskflow/estado/task_repository_provider.dart';
import 'package:taskflow/modelos/tarea.dart';
import 'package:taskflow/repositorios/task_repository.dart';
import 'package:taskflow/widgets/tarjeta_tarea.dart';

class RepositorioTareasPrueba implements TaskRepository {
  final List<Tarea> _tareas = [
    Tarea(
      id: 1,
      titulo: 'Estudiar Flutter',
      fechaLimite: DateTime(2026, 12, 1),
    ),
    Tarea(
      id: 2,
      titulo: 'Completar laboratorio',
      fechaLimite: DateTime(2026, 12, 2),
    ),
    Tarea(
      id: 3,
      titulo: 'Revisar apuntes',
      fechaLimite: DateTime(2026, 12, 3),
    ),
    Tarea(
      id: 4,
      titulo: 'Preparar evaluación',
      fechaLimite: DateTime(2026, 12, 4),
    ),
  ];

  @override
  Future<List<Tarea>> obtenerTareas() async {
    return List<Tarea>.from(_tareas);
  }

  @override
  Future<Tarea> agregar(Tarea tarea) async {
    tarea.id = _tareas.length + 1;
    _tareas.add(tarea);
    return tarea;
  }

  @override
  Future<void> actualizar(Tarea tarea) async {
    final indice = _tareas.indexWhere(
      (elemento) => elemento.id == tarea.id,
    );

    if (indice != -1) {
      _tareas[indice] = tarea;
    }
  }

  @override
  Future<void> eliminar(int id) async {
    _tareas.removeWhere((tarea) => tarea.id == id);
  }
}

void main() {
  testWidgets(
    'TaskFlow muestra las tareas iniciales y permite completar una',
    (WidgetTester tester) async {
      final repositorio = RepositorioTareasPrueba();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWith(
              (ref) async => repositorio,
            ),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('TaskFlow'), findsOneWidget);
      expect(find.text('Agregar tarea'), findsOneWidget);
      expect(find.byType(TarjetaTarea), findsNWidgets(4));

      final primeraTarjeta = find.byType(TarjetaTarea).first;

      expect(
        tester.widget<TarjetaTarea>(primeraTarjeta).completada,
        isFalse,
      );

      final botonCompletar = find.descendant(
        of: primeraTarjeta,
        matching: find.byTooltip('Marcar como completada'),
      );

      await tester.ensureVisible(botonCompletar);
      await tester.tap(botonCompletar);
      await tester.pumpAndSettle();

      expect(
        tester.widget<TarjetaTarea>(primeraTarjeta).completada,
        isTrue,
      );

      expect(
        find.descendant(
          of: primeraTarjeta,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );
    },
  );
}
