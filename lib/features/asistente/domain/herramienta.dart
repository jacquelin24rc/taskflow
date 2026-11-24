
class Parametro {
  const Parametro({
    required this.tipo,
    required this.descripcion,
    this.requerido = true,
  });

  final String tipo;
  final String descripcion;
  final bool requerido;
}

abstract interface class HerramientaAgente {
  String get nombre;

  String get descripcion;

  Map<String, Parametro> get parametros;

  Future<AccionPreparada> preparar(
    Map<String, Object?> argumentos,
  );
}

sealed class AccionPreparada {
  const AccionPreparada();
}

final class AccionInvalida extends AccionPreparada {
  const AccionInvalida(this.motivo);

  final String motivo;
}

final class AccionLectura extends AccionPreparada {
  const AccionLectura({
    required this.ejecutar,
  });

  final Future<String> Function() ejecutar;
}

final class AccionModificacion extends AccionPreparada {
  const AccionModificacion({
    required this.descripcion,
    required this.ejecutar,
  });

  final String descripcion;
  final Future<String> Function() ejecutar;
}
