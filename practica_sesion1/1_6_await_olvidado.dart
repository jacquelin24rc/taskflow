
Future<void> guardarTarea(String titulo) async {
  await Future.delayed(const Duration(seconds: 1));

  if (titulo.isEmpty) {
    throw Exception('Título vacío');
  }

  print('Guardada: $titulo');
}

Future<void> alPresionarGuardar() async {
  try {
    // Ahora esperamos correctamente el resultado.
    await guardarTarea('');

    print('¡Listo!');
  } catch (e) {
    print('Error detectado: $e');
  }
}

Future<void> main() async {
  await alPresionarGuardar();
}
