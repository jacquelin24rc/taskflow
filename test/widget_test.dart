import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/app.dart';
import 'package:taskflow/widgets/tarjeta_tarea.dart';

void main() {
  testWidgets(
    'TaskFlow muestra las tareas iniciales y permite completar una',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
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