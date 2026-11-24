
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/asistente/domain/agente.dart';
import 'package:taskflow/features/asistente/domain/herramienta.dart';
import 'package:taskflow/features/asistente/domain/herramientas_tareas.dart';
import 'package:taskflow/features/asistente/domain/modelo_agente.dart';
import 'package:taskflow/features/tareas/domain/tarea.dart';
import 'package:taskflow/features/tareas/domain/task_repository.dart';

class RepositorioPrueba implements TaskRepository {
  final List<Tarea> tareas = [];

  @override
  Stream<List<Tarea>> observarTareas() async* {
    yield List<Tarea>.from(tareas);
  }

  @override
  Future<String> agregar(Tarea tarea) async {
    final id = '${tareas.length + 1}';
    tareas.add(tarea.copyWith(id: id));
    return id;
  }

  @override
  Future<void> actualizar(Tarea tarea) async {
    final indice = tareas.indexWhere(
      (elemento) => elemento.id == tarea.id,
    );

    if (indice != -1) {
      tareas[indice] = tarea;
    }
  }

  @override
  Future<void> eliminar(String id) async {
    tareas.removeWhere((tarea) => tarea.id == id);
  }
}

class ModeloGuionado implements ModeloAgente {
  ModeloGuionado(this.respuestas);

  final List<MensajeModelo> respuestas;

  int llamadas = 0;
  String? ultimoResultado;

  @override
  Future<MensajeModelo> responder(
    List<MensajeAgente> historial,
    List<HerramientaAgente> herramientas,
  ) async {
    if (historial.isNotEmpty &&
        historial.last is MensajeResultados) {
      final mensaje =
          historial.last as MensajeResultados;

      ultimoResultado = mensaje.resultados
          .map((resultado) => resultado.resultado)
          .join('\n');
    }

    final indice = llamadas < respuestas.length
        ? llamadas
        : respuestas.length - 1;

    llamadas++;

    return respuestas[indice];
  }
}

void main() {
  test(
    'Crear RECHAZADO: no guarda nada y el modelo lo sabe',
    () async {
      final repositorio = RepositorioPrueba();

      final fecha = DateTime.now().add(
        const Duration(days: 7),
      );

      final fechaTexto =
          '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}/'
          '${fecha.year}';

      final modelo = ModeloGuionado([
        MensajeModelo(
          llamadas: [
            LlamadaHerramienta(
              'crear_tarea',
              {
                'titulo': 'Leer Cap. 16',
                'fecha_limite': fechaTexto,
              },
            ),
          ],
        ),
        const MensajeModelo(
          texto: 'Acción rechazada.',
        ),
      ]);

      var confirmaciones = 0;

      final agente = AgenteTaskFlow(
        modelo: modelo,
        herramientas: [
          CrearTarea(repositorio),
        ],
        confirmar: (_) async {
          confirmaciones++;
          return false;
        },
      );

      await agente.enviar('Crea Leer Cap. 16');

      expect(
        await repositorio.observarTareas().first,
        isEmpty,
      );

      expect(confirmaciones, 1);

      expect(
        modelo.ultimoResultado,
        contains('RECHAZÓ'),
      );
    },
  );

  test(
    'Límite de iteraciones: un modelo en bucle se detiene',
    () async {
      final repositorio = RepositorioPrueba();

      final modelo = ModeloGuionado([
        const MensajeModelo(
          llamadas: [
            LlamadaHerramienta(
              'listar_tareas',
              {},
            ),
          ],
        ),
      ]);

      final agente = AgenteTaskFlow(
        modelo: modelo,
        herramientas: [
          ListarTareas(repositorio),
        ],
        confirmar: (_) async => false,
        maxIteraciones: 3,
      );

      await expectLater(
        agente.enviar('Lista mis tareas'),
        throwsA(isA<AgenteException>()),
      );

      expect(modelo.llamadas, 3);
    },
  );
}
