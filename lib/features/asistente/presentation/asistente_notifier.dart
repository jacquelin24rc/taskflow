import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tareas/domain/task_repository.dart';
import '../../tareas/presentation/tareas_providers.dart';
import '../data/gemini_modelo_agente.dart';
import '../data/modelo_simulado_agente.dart';
import '../domain/agente.dart';
import '../domain/fase_agente.dart';
import '../domain/herramientas_tareas.dart';

class MensajeChat {
  const MensajeChat({required this.autor, required this.texto});

  final String autor;
  final String texto;
}

class EstadoAsistente {
  const EstadoAsistente({
    this.fase = const Inactivo(),
    this.mensajes = const [],
  });

  final FaseAgente fase;
  final List<MensajeChat> mensajes;

  EstadoAsistente copyWith({FaseAgente? fase, List<MensajeChat>? mensajes}) {
    return EstadoAsistente(
      fase: fase ?? this.fase,
      mensajes: mensajes ?? this.mensajes,
    );
  }
}

final asistenteProvider =
    NotifierProvider.autoDispose<AsistenteNotifier, EstadoAsistente>(
      AsistenteNotifier.new,
    );

class AsistenteNotifier extends Notifier<EstadoAsistente> {
  static const _modoAgente = String.fromEnvironment(
    'AGENTE',
    defaultValue: 'gemini',
  );

  AgenteTaskFlow? _agente;

  Completer<bool>? _confirmacionPendiente;

  bool _activo = true;

  @override
  EstadoAsistente build() {
    _activo = true;

    final repositorio = ref.watch(firestoreTaskRepositoryProvider);

    ref.onDispose(() {
      _activo = false;

      final pendiente = _confirmacionPendiente;

      if (pendiente != null && !pendiente.isCompleted) {
        pendiente.complete(false);
      }

      _confirmacionPendiente = null;
    });

    _agente = repositorio == null ? null : _crearAgente(repositorio);

    return const EstadoAsistente();
  }

  AgenteTaskFlow _crearAgente(TaskRepository repositorio) {
    return AgenteTaskFlow(
      modelo: _modoAgente == 'simulado'
          ? ModeloSimuladoAgente()
          : GeminiModeloAgente(),
      herramientas: [
        ListarTareas(repositorio),
        CrearTarea(repositorio),
        CompletarTarea(repositorio),
        EliminarTarea(repositorio),
      ],
      confirmar: _pedirConfirmacion,
      maxIteraciones: 5,
      alPensar: () {
        if (!_activo) return;

        state = state.copyWith(fase: const Pensando());
      },
      alEjecutarHerramienta: (nombre) {
        if (!_activo) return;

        state = state.copyWith(fase: EjecutandoHerramienta(nombre));

        _agregarMensaje('Sistema', 'Usando herramienta: $nombre');
      },
    );
  }

  void _agregarMensaje(String autor, String texto) {
    if (!_activo) return;

    state = state.copyWith(
      mensajes: [
        ...state.mensajes,
        MensajeChat(autor: autor, texto: texto),
      ],
    );
  }

  Future<void> enviar(String texto) async {
    final mensaje = texto.trim();

    if (mensaje.isEmpty || state.fase is! Inactivo) {
      return;
    }

    if (state.mensajes.isEmpty) {
      _agregarMensaje(
        'Sistema',
        _modoAgente == 'simulado'
            ? 'Modo simulado activo.'
            : 'Modo Gemini activo.',
      );
    }

    _agregarMensaje('Usuario', mensaje);

    final agente = _agente;

    if (agente == null) {
      _agregarMensaje(
        'Sistema',
        'Debes iniciar sesión para utilizar el asistente.',
      );

      return;
    }

    state = state.copyWith(fase: const Pensando());

    try {
      final respuesta = await agente.enviar(mensaje);

      _agregarMensaje('Asistente', respuesta);
    } on AgenteException catch (e) {
      _agregarMensaje('Sistema', e.mensaje);
    } on TimeoutException {
      _agregarMensaje(
        'Sistema',
        'El asistente tardó demasiado en responder. '
            'Inténtalo nuevamente.',
      );
    } catch (_) {
      _agregarMensaje(
        'Sistema',
        'No se pudo completar la solicitud. '
            'Verifica tu conexión e inténtalo nuevamente.',
      );
    } finally {
      if (_activo) {
        state = state.copyWith(fase: const Inactivo());
      }
    }
  }

  Future<bool> _pedirConfirmacion(String descripcion) {
    if (!_activo) {
      return Future.value(false);
    }

    final completer = Completer<bool>();

    _confirmacionPendiente = completer;

    _agregarMensaje('Sistema', 'Confirmación requerida: $descripcion');

    state = state.copyWith(fase: EsperandoConfirmacion(descripcion));

    return completer.future;
  }

  void responderConfirmacion(bool aprobada) {
    final pendiente = _confirmacionPendiente;

    if (pendiente == null || pendiente.isCompleted) {
      return;
    }

    _confirmacionPendiente = null;

    _agregarMensaje(
      'Usuario',
      aprobada ? 'Acción aprobada.' : 'Acción rechazada.',
    );

    state = state.copyWith(fase: const Pensando());

    pendiente.complete(aprobada);
  }
}
