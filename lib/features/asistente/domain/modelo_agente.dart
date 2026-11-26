import 'herramienta.dart';

sealed class MensajeAgente {
  const MensajeAgente();
}

final class MensajeUsuario extends MensajeAgente {
  const MensajeUsuario(this.texto);

  final String texto;
}

class LlamadaHerramienta {
  const LlamadaHerramienta(this.nombre, this.argumentos, {this.id});

  final String nombre;
  final Map<String, Object?> argumentos;
  final String? id;
}

final class MensajeModelo extends MensajeAgente {
  const MensajeModelo({this.texto, this.llamadas = const []});

  final String? texto;
  final List<LlamadaHerramienta> llamadas;
}

class ResultadoHerramienta {
  const ResultadoHerramienta(this.nombre, this.resultado, {this.id});

  final String nombre;
  final String resultado;
  final String? id;
}

final class MensajeResultados extends MensajeAgente {
  const MensajeResultados(this.resultados);

  final List<ResultadoHerramienta> resultados;
}

abstract interface class ModeloAgente {
  Future<MensajeModelo> responder(
    List<MensajeAgente> historial,
    List<HerramientaAgente> herramientas,
  );
}
