import '../../../validacion/validadores_tarea.dart';
import '../../tareas/domain/tarea.dart';
import '../../tareas/domain/task_repository.dart';
import 'herramienta.dart';

DateTime? leerFecha(String texto) {
  final coincidencia = RegExp(
    r'^(\d{2})/(\d{2})/(\d{4})$',
  ).firstMatch(texto.trim());

  if (coincidencia == null) return null;

  final dia = int.parse(coincidencia.group(1)!);
  final mes = int.parse(coincidencia.group(2)!);
  final anio = int.parse(coincidencia.group(3)!);

  final fecha = DateTime(anio, mes, dia);

  if (fecha.day != dia || fecha.month != mes || fecha.year != anio) {
    return null;
  }

  return fecha;
}

String formatearFecha(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  final anio = fecha.year.toString().padLeft(4, '0');

  return '$dia/$mes/$anio';
}

class ListarTareas implements HerramientaAgente {
  ListarTareas(this._repo);

  final TaskRepository _repo;

  @override
  String get nombre => 'listar_tareas';

  @override
  String get descripcion => 'Consulta las tareas del usuario y su estado.';

  @override
  Map<String, Parametro> get parametros => const {
    'solo_pendientes': Parametro(
      tipo: 'boolean',
      descripcion: 'Mostrar únicamente tareas pendientes.',
      requerido: false,
    ),
  };

  @override
  Future<AccionPreparada> preparar(Map<String, Object?> argumentos) async {
    final valor = argumentos['solo_pendientes'];

    if (valor != null && valor is! bool) {
      return const AccionInvalida(
        'solo_pendientes debe ser verdadero o falso.',
      );
    }

    final soloPendientes = valor == true;

    return AccionLectura(
      ejecutar: () async {
        final tareas = await _repo.observarTareas().first;

        final resultado = tareas.where(
          (tarea) => !soloPendientes || !tarea.completada,
        );

        if (resultado.isEmpty) {
          return 'No hay tareas que coincidan con la consulta.';
        }

        return resultado
            .map((tarea) {
              final estado = tarea.completada ? 'Completada' : 'Pendiente';

              final fecha = tarea.fechaLimite == null
                  ? 'Sin fecha'
                  : formatearFecha(tarea.fechaLimite!);

              return '${tarea.titulo} | '
                  'Estado: $estado | '
                  'Fecha límite: $fecha | '
                  'Descripción: ${tarea.descripcion}';
            })
            .join('\n');
      },
    );
  }
}

class CrearTarea implements HerramientaAgente {
  CrearTarea(this._repo);

  final TaskRepository _repo;

  @override
  String get nombre => 'crear_tarea';

  @override
  String get descripcion => 'Prepara la creación de una tarea nueva.';

  @override
  Map<String, Parametro> get parametros => const {
    'titulo': Parametro(tipo: 'string', descripcion: 'Título de la tarea.'),
    'descripcion': Parametro(
      tipo: 'string',
      descripcion: 'Descripción de la tarea.',
      requerido: false,
    ),
    'fecha_limite': Parametro(
      tipo: 'string',
      descripcion: 'Fecha límite en formato dd/mm/aaaa.',
    ),
  };

  @override
  Future<AccionPreparada> preparar(Map<String, Object?> argumentos) async {
    final tituloValor = argumentos['titulo'];
    final descripcionValor = argumentos['descripcion'];
    final fechaValor = argumentos['fecha_limite'];

    if (tituloValor is! String) {
      return const AccionInvalida('Debes proporcionar un título válido.');
    }

    if (descripcionValor != null && descripcionValor is! String) {
      return const AccionInvalida('La descripción debe ser texto.');
    }

    final titulo = tituloValor.trim();

    final descripcion = (descripcionValor as String? ?? '').trim();

    final errorTitulo = ValidadoresTarea.validarTitulo(titulo);

    if (errorTitulo != null) {
      return AccionInvalida(errorTitulo);
    }

    final errorDescripcion = ValidadoresTarea.validarDescripcion(descripcion);

    if (errorDescripcion != null) {
      return AccionInvalida(errorDescripcion);
    }

    final fecha = fechaValor is String ? leerFecha(fechaValor) : null;

    if (fecha == null) {
      return const AccionInvalida('La fecha no es válida. Usa dd/mm/aaaa.');
    }

    final errorFecha = ValidadoresTarea.validarFecha(fecha);

    if (errorFecha != null) {
      return AccionInvalida(errorFecha);
    }

    final tarea = Tarea(
      id: '',
      titulo: titulo,
      descripcion: descripcion,
      fechaLimite: fecha,
    );

    return AccionModificacion(
      descripcion:
          'Crear la tarea «${tarea.titulo}» '
          'con fecha límite ${formatearFecha(fecha)}. '
          'Descripción: ${tarea.descripcion}',
      ejecutar: () async {
        final error = ValidadoresTarea.validarFecha(fecha);

        if (error != null) {
          return error;
        }

        await _repo.agregar(tarea);

        return 'Tarea «${tarea.titulo}» creada correctamente.';
      },
    );
  }
}

List<Tarea> _buscarCoincidencias(List<Tarea> tareas, String titulo) {
  final consulta = titulo.trim().toLowerCase();

  final exactas = tareas
      .where((tarea) => tarea.titulo.trim().toLowerCase() == consulta)
      .toList();

  if (exactas.isNotEmpty) {
    return exactas;
  }

  return tareas
      .where((tarea) => tarea.titulo.toLowerCase().contains(consulta))
      .toList();
}

class CompletarTarea implements HerramientaAgente {
  CompletarTarea(this._repo);

  final TaskRepository _repo;

  @override
  String get nombre => 'completar_tarea';

  @override
  String get descripcion =>
      'Prepara una tarea pendiente para marcarla como completada.';

  @override
  Map<String, Parametro> get parametros => const {
    'titulo': Parametro(
      tipo: 'string',
      descripcion: 'Título de la tarea que se completará.',
    ),
  };

  @override
  Future<AccionPreparada> preparar(Map<String, Object?> argumentos) async {
    final titulo = argumentos['titulo'];

    if (titulo is! String || titulo.trim().isEmpty) {
      return const AccionInvalida('Debes indicar el título de la tarea.');
    }

    final tareas = await _repo.observarTareas().first;

    final coincidencias = _buscarCoincidencias(tareas, titulo);

    if (coincidencias.isEmpty) {
      return const AccionInvalida('No se encontró la tarea indicada.');
    }

    if (coincidencias.length > 1) {
      final nombres = coincidencias.map((tarea) => tarea.titulo).join(', ');

      return AccionInvalida(
        'Hay varias coincidencias: $nombres. '
        'Debes especificar cuál tarea deseas completar.',
      );
    }

    final tarea = coincidencias.single;

    if (tarea.completada) {
      return const AccionInvalida('La tarea ya está completada.');
    }

    return AccionModificacion(
      descripcion: 'Completar la tarea «${tarea.titulo}».',
      ejecutar: () async {
        await _repo.actualizar(tarea.copyWith(completada: true));

        return 'Tarea «${tarea.titulo}» completada correctamente.';
      },
    );
  }
}

class EliminarTarea implements HerramientaAgente {
  EliminarTarea(this._repo);

  final TaskRepository _repo;

  @override
  String get nombre => 'eliminar_tarea';

  @override
  String get descripcion => 'Prepara la eliminación de una única tarea.';

  @override
  Map<String, Parametro> get parametros => const {
    'titulo': Parametro(
      tipo: 'string',
      descripcion: 'Título de la tarea que se eliminará.',
    ),
  };

  @override
  Future<AccionPreparada> preparar(Map<String, Object?> argumentos) async {
    final titulo = argumentos['titulo'];

    if (titulo is! String || titulo.trim().isEmpty) {
      return const AccionInvalida('Debes indicar el título de la tarea.');
    }

    final tareas = await _repo.observarTareas().first;

    final coincidencias = _buscarCoincidencias(tareas, titulo);

    if (coincidencias.isEmpty) {
      return const AccionInvalida('No se encontró la tarea indicada.');
    }

    if (coincidencias.length > 1) {
      final nombres = coincidencias.map((tarea) => tarea.titulo).join(', ');

      return AccionInvalida(
        'Hay varias coincidencias: $nombres. '
        'Debes especificar cuál tarea deseas eliminar.',
      );
    }

    final tarea = coincidencias.single;

    return AccionModificacion(
      descripcion: 'Eliminar la tarea «${tarea.titulo}».',
      ejecutar: () async {
        await _repo.eliminar(tarea.id);

        return 'Tarea «${tarea.titulo}» eliminada correctamente.';
      },
    );
  }
}
