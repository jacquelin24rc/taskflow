
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/escaneo/domain/propuesta_tarea.dart';

void main() {
  group('PropuestaTarea', () {
    test('extrae el titulo y la descripcion del texto', () {
      const texto = '''
Tarea de Matematica
Resolver los ejercicios del capitulo 5.
''';

      final propuesta = PropuestaTarea.desdeTexto(texto);

      expect(propuesta.titulo, 'Tarea de Matematica');
      expect(
        propuesta.descripcion,
        'Resolver los ejercicios del capitulo 5.',
      );
      expect(propuesta.fechaLimite, isNull);
    });

    test('reconoce una fecha valida', () {
      const texto = '''
Tarea de Matematica
Resolver los ejercicios.
Fecha limite: 25/11/2026
''';

      final propuesta = PropuestaTarea.desdeTexto(texto);

      expect(propuesta.fechaLimite, isNotNull);
      expect(propuesta.fechaLimite!.day, 25);
      expect(propuesta.fechaLimite!.month, 11);
      expect(propuesta.fechaLimite!.year, 2026);
    });

    test('descarta una fecha imposible', () {
      const texto = '''
Tarea de Ciencias
Investigar el sistema solar.
Fecha limite: 31/02/2026
''';

      final propuesta = PropuestaTarea.desdeTexto(texto);

      expect(propuesta.fechaLimite, isNull);
    });

    test('limita el titulo a 60 caracteres', () {
      final tituloLargo = 'A' * 80;

      final propuesta = PropuestaTarea.desdeTexto(
        tituloLargo,
      );

      expect(propuesta.titulo.length, 60);
    });

    test('limita la descripcion a 200 caracteres', () {
      final descripcionLarga = 'B' * 250;

      final propuesta = PropuestaTarea.desdeTexto(
        'Tarea de prueba\n$descripcionLarga',
      );

      expect(propuesta.descripcion.length, 200);
    });

    test('maneja correctamente el texto vacio', () {
      final propuesta = PropuestaTarea.desdeTexto('');

      expect(propuesta.titulo, isEmpty);
      expect(propuesta.descripcion, isEmpty);
      expect(propuesta.fechaLimite, isNull);
    });
  });
}
