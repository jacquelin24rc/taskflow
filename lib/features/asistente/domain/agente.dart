
import 'herramienta.dart';
import 'modelo_agente.dart';

class AgenteException implements Exception {
  const AgenteException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

class AgenteTaskFlow {
  AgenteTaskFlow({
    required this.modelo,
    required List<HerramientaAgente> herramientas,
    required this.confirmar,
    this.maxIteraciones = 5,
    this.alEjecutarHerramienta,
    this.alPensar,
  })  : assert(maxIteraciones > 0),
        _herramientas = {
          for (final herramienta in herramientas)
            herramienta.nombre: herramienta,
        };

  final ModeloAgente modelo;

  final Map<String, HerramientaAgente> _herramientas;

  final Future<bool> Function(String) confirmar;

  final int maxIteraciones;

  final void Function(String)? alEjecutarHerramienta;

  final void Function()? alPensar;

  final List<MensajeAgente> _historial = [];

  bool _ocupado = false;

  Future<String> enviar(String texto) async {
    if (texto.trim().isEmpty) {
      throw const AgenteException(
        'Escribe una instrucción para el asistente.',
      );
    }

    if (_ocupado) {
      throw const AgenteException(
        'El asistente ya está procesando una solicitud.',
      );
    }

    _ocupado = true;

    final inicio = _historial.length;

    _historial.add(
      MensajeUsuario(texto.trim()),
    );

    try {
      for (var i = 0; i < maxIteraciones; i++) {
        alPensar?.call();

        final respuesta = await modelo.responder(
          List.unmodifiable(_historial),
          _herramientas.values.toList(),
        );

        _historial.add(respuesta);

        if (respuesta.llamadas.isEmpty) {
          return respuesta.texto ??
              'No obtuve una respuesta.';
        }

        final resultados = <ResultadoHerramienta>[];

        for (final llamada in respuesta.llamadas) {
          final resultado = await _ejecutar(llamada);

          resultados.add(
            ResultadoHerramienta(
              llamada.nombre,
              resultado,
              id: llamada.id,
            ),
          );
        }

        _historial.add(
          MensajeResultados(resultados),
        );
      }

      throw AgenteException(
        'El asistente superó $maxIteraciones '
        'pasos sin terminar.',
      );
    } catch (_) {
      _historial.removeRange(
        inicio,
        _historial.length,
      );

      rethrow;
    } finally {
      _ocupado = false;
    }
  }

  Future<String> _ejecutar(
    LlamadaHerramienta llamada,
  ) async {
    final herramienta = _herramientas[llamada.nombre];

    if (herramienta == null) {
      return 'Error: no existe la herramienta '
          '${llamada.nombre}.';
    }

    try {
      alEjecutarHerramienta?.call(llamada.nombre);

      final accion = await herramienta.preparar(
        llamada.argumentos,
      );

      switch (accion) {
        case AccionInvalida(:final motivo):
          return 'Error: $motivo';

        case AccionLectura(:final ejecutar):
          return await ejecutar();

        case AccionModificacion(
            :final descripcion,
            :final ejecutar,
          ):
          final autorizado = await confirmar(
            descripcion,
          );

          if (!autorizado) {
            return 'El usuario RECHAZÓ esta acción: '
                '$descripcion. '
                'No se hizo ningún cambio.';
          }

          alEjecutarHerramienta?.call(llamada.nombre);

          return await ejecutar();
      }
    } catch (e) {
      return 'Error al ejecutar ${llamada.nombre}: $e';
    }
  }
}
