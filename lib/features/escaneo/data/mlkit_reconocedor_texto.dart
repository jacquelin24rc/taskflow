
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../domain/reconocedor_texto.dart';

class MlKitReconocedorTexto implements ReconocedorTexto {
  final _reconocedor = TextRecognizer();

  @override
  Future<String> reconocer(String rutaImagen) async {
    final resultado = await _reconocedor.processImage(
      InputImage.fromFilePath(rutaImagen),
    );

    return [
      for (final bloque in resultado.blocks)
        for (final linea in bloque.lines) linea.text,
    ].join('\n');
  }

  @override
  Future<void> cerrar() => _reconocedor.close();
}
