import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/modelos/tarea.dart';

void main() {
  group('Pruebas de JSON - Semana 14', () {
    test('1. JSON válido con todos los campos', () {
      final tarea = Tarea.fromJson({
        'id': 1,
        'title': 'Estudiar Flutter',
        'completed': false,
      });

      expect(tarea.id, 1);
      expect(tarea.titulo, 'Estudiar Flutter');
      expect(tarea.completada, false);
    });

    test('2. JSON sin identificador', () {
      final tarea = Tarea.fromJson({
        'title': 'Hacer tarea',
        'completed': false,
      });

      expect(tarea.titulo, 'Hacer tarea');
    });

    test('3. JSON sin título', () {
      expect(
        () => Tarea.fromJson({'id': 3, 'completed': false}),
        throwsException,
      );
    });

    test('4. JSON con título vacío', () {
      expect(
        () => Tarea.fromJson({'id': 4, 'title': '', 'completed': false}),
        throwsException,
      );
    });

    test('5. JSON con título que no es texto', () {
      expect(
        () => Tarea.fromJson({'id': 5, 'title': 123, 'completed': false}),
        throwsException,
      );
    });

    test('6. JSON sin estado de completado', () {
      final tarea = Tarea.fromJson({'id': 6, 'title': 'Repasar Dart'});

      expect(tarea.titulo, 'Repasar Dart');
    });

    test('7. JSON con estado de completado incorrecto', () {
      final tarea = Tarea.fromJson({
        'id': 7,
        'title': 'Leer documentación',
        'completed': 'incorrecto',
      });

      expect(tarea.titulo, 'Leer documentación');
    });

    test('8. JSON con campos adicionales', () {
      final tarea = Tarea.fromJson({
        'id': 8,
        'title': 'Preparar proyecto',
        'completed': true,
        'campoDesconocido': 'dato extra',
      });

      expect(tarea.id, 8);
      expect(tarea.titulo, 'Preparar proyecto');
      expect(tarea.completada, true);
    });
  });
}
