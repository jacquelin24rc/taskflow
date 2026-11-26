import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/validacion/validadores_tarea.dart';

void main() {
  group('Validación del título', () {
    test('rechaza un título vacío', () {
      expect(ValidadoresTarea.validarTitulo(''), isNotNull);
    });

    test('rechaza un título de 2 caracteres', () {
      expect(ValidadoresTarea.validarTitulo('AB'), isNotNull);
    });

    test('acepta un título de 3 caracteres', () {
      expect(ValidadoresTarea.validarTitulo('ABC'), isNull);
    });

    test('acepta un título de 60 caracteres', () {
      expect(ValidadoresTarea.validarTitulo('A' * 60), isNull);
    });

    test('rechaza un título de 61 caracteres', () {
      expect(ValidadoresTarea.validarTitulo('A' * 61), isNotNull);
    });

    test('rechaza un título compuesto por espacios', () {
      expect(ValidadoresTarea.validarTitulo('   '), isNotNull);
    });
  });

  group('Validación de la descripción', () {
    test('acepta una descripción vacía', () {
      expect(ValidadoresTarea.validarDescripcion(''), isNull);
    });

    test('acepta una descripción de 200 caracteres', () {
      expect(ValidadoresTarea.validarDescripcion('A' * 200), isNull);
    });

    test('rechaza una descripción de 201 caracteres', () {
      expect(ValidadoresTarea.validarDescripcion('A' * 201), isNotNull);
    });
  });

  group('Validación de la fecha', () {
    test('rechaza una fecha nula', () {
      expect(ValidadoresTarea.validarFecha(null), isNotNull);
    });

    test('rechaza la fecha de ayer', () {
      final ahora = DateTime.now();
      final ayer = DateTime(ahora.year, ahora.month, ahora.day - 1);

      expect(ValidadoresTarea.validarFecha(ayer), isNotNull);
    });

    test('acepta la fecha de hoy', () {
      final ahora = DateTime.now();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);

      expect(ValidadoresTarea.validarFecha(hoy), isNull);
    });

    test('acepta una fecha futura', () {
      final ahora = DateTime.now();
      final manana = DateTime(ahora.year, ahora.month, ahora.day + 1);

      expect(ValidadoresTarea.validarFecha(manana), isNull);
    });
  });
}
