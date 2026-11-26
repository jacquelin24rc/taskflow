import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/rendimiento/presentation/rendimiento_screen.dart';

void main() {
  testWidgets('El reloj optimizado no reconstruye las filas de la lista', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: RendimientoScreen(optimizadaAlInicio: true)),
    );

    await tester.pump();

    expect(find.text('Optimizada'), findsOneWidget);
    expect(find.text('Tarea 1'), findsOneWidget);
    expect(ContadorFilas.construidas, greaterThan(0));

    ContadorFilas.construidas = 0;

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Reloj: 1.0 s'), findsOneWidget);

    expect(
      ContadorFilas.construidas,
      0,
      reason: 'El reloj no debe reconstruir las filas.',
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
