
abstract interface class ReconocedorTexto {
  Future<String> reconocer(String rutaImagen);

  Future<void> cerrar();
}
