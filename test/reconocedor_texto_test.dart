import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/escaneo/domain/reconocedor_texto.dart';
import 'package:taskflow/features/escaneo/domain/propuesta_tarea.dart';

class ReconocedorTextoFalso implements ReconocedorTexto {
  bool cerrado = false;

  @override
  Future<String> reconocer(String rutaImagen) async {
    return '''
Tarea de Ciencias
Investigar el sistema solar.
Fecha limite: 26/11/2026
''';
  }

  @override
  Future<void> cerrar() async {
    cerrado = true;
  }
}

void main() {
  group('Reconocedor de texto simulado', () {
    test('reconoce texto sin utilizar ML Kit', () async {
      final reconocedor = ReconocedorTextoFalso();

      final texto = await reconocedor.reconocer('imagen_prueba.jpg');

      expect(texto, contains('Tarea de Ciencias'));
      expect(texto, contains('Investigar el sistema solar.'));
    });

    test('genera una propuesta a partir del texto', () async {
      final reconocedor = ReconocedorTextoFalso();

      final texto = await reconocedor.reconocer('imagen_prueba.jpg');

      final propuesta = PropuestaTarea.desdeTexto(texto);

      expect(propuesta.titulo, 'Tarea de Ciencias');
      expect(propuesta.descripcion, contains('Investigar el sistema solar.'));
      expect(propuesta.fechaLimite?.day, 26);
      expect(propuesta.fechaLimite?.month, 11);
      expect(propuesta.fechaLimite?.year, 2026);
    });

    test('permite liberar los recursos del reconocedor', () async {
      final reconocedor = ReconocedorTextoFalso();

      await reconocedor.cerrar();

      expect(reconocedor.cerrado, isTrue);
    });
  });
}
