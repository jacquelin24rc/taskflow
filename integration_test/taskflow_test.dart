import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:taskflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Entrar, crear, completar y eliminar una tarea', (tester) async {
    // Verificar que se utiliza el backend en memoria.
    const backend = String.fromEnvironment('BACKEND');

    expect(backend, 'memoria');

    // 1. Iniciar la aplicacion real.
    await app.main();
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido a TaskFlow'), findsOneWidget);

    // 2. Ingresar las credenciales de prueba.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo electrónico'),
      'demo@usam.edu.sv',
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      'Prueba123',
    );

    // 3. Iniciar sesion.
    await tester.tap(find.text('Iniciar sesión'));

    await tester.pumpAndSettle();

    expect(find.text('Mis tareas'), findsOneWidget);

    expect(find.text('Todavía no tienes tareas guardadas.'), findsOneWidget);

    // 4. Abrir el formulario de nueva tarea.
    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();

    expect(find.text('Registrar nueva tarea'), findsOneWidget);

    // 5. Completar el formulario.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título'),
      'Estudiar pruebas de integración',
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descripción (opcional)'),
      'Prueba automatizada de la Semana 20',
    );

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    final botonGuardar = find.text('Guardar tarea');

    await tester.ensureVisible(botonGuardar);
    await tester.tap(botonGuardar);
    await tester.pumpAndSettle();

    // 6. Comprobar que la tarea fue creada.
    expect(find.text('Mis tareas'), findsOneWidget);

    expect(find.text('Estudiar pruebas de integración'), findsOneWidget);

    expect(find.byType(Checkbox), findsOneWidget);

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);

    // 7. Marcar la tarea como completada.
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

    // 8. Eliminar la tarea.
    await tester.tap(find.byTooltip('Eliminar tarea'));

    await tester.pumpAndSettle();

    // 9. Comprobar que la tarea fue eliminada.
    expect(find.text('Estudiar pruebas de integración'), findsNothing);

    expect(find.byType(Checkbox), findsNothing);

    expect(find.text('Todavía no tienes tareas guardadas.'), findsOneWidget);
  });
}
