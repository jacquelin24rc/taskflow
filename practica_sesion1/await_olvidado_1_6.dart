
import 'dart:developer' as developer;

Future<void> guardarTarea(String titulo) async {
  await Future.delayed(const Duration(seconds: 1));

  if (titulo.isEmpty) {
    throw Exception('Título vacío');
  }

  developer.log('Guardada: $titulo');
}

Future<void> alPresionarGuardar() async {
  try {
    // Ahora esperamos correctamente el resultado.
    await guardarTarea('');

    developer.log('¡Listo!');
  } catch (e) {
    developer.log('Error detectado: $e');
  }
}

Future<void> main() async {
  await alPresionarGuardar();
}
