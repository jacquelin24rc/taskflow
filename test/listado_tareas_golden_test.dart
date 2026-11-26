import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/auth/presentation/auth_providers.dart';
import 'package:taskflow/features/tareas/domain/tarea.dart';
import 'package:taskflow/features/tareas/presentation/listado_tareas_screen.dart';
import 'package:taskflow/features/tareas/presentation/tareas_providers.dart';

void main() {
  testWidgets('Golden: listado de tareas con tres tareas de ejemplo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tareas = [
      Tarea(
        id: '1',
        titulo: 'Estudiar Flutter',
        descripcion: 'Repasar los widgets.',
        prioridad: 3,
        completada: false,
        fechaLimite: DateTime(2026, 12, 1),
        categoria: 'Estudio',
      ),
      Tarea(
        id: '2',
        titulo: 'Completar laboratorio',
        descripcion: 'Realizar las pruebas.',
        prioridad: 2,
        completada: true,
        fechaLimite: DateTime(2026, 12, 2),
        categoria: 'Estudio',
      ),
      Tarea(
        id: '3',
        titulo: 'Organizar apuntes',
        descripcion: 'Ordenar los materiales.',
        prioridad: 1,
        completada: false,
        fechaLimite: DateTime(2026, 12, 3),
        categoria: 'Personal',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sesionProvider.overrideWith((ref) => Stream.value(null)),
          tareasFirestoreProvider.overrideWith((ref) => Stream.value(tareas)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            platform: TargetPlatform.android,
          ),
          home: const ListadoTareasScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Mis tareas'), findsOneWidget);
    expect(find.byType(Checkbox), findsNWidgets(3));
    expect(find.text('Estudiar Flutter'), findsOneWidget);
    expect(find.text('Completar laboratorio'), findsOneWidget);
    expect(find.text('Organizar apuntes'), findsOneWidget);

    await expectLater(
      find.byType(ListadoTareasScreen),
      matchesGoldenFile('goldens/listado_tareas.png'),
    );
  }, tags: ['golden']);
}
