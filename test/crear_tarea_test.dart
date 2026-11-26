import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/features/asistente/domain/agente.dart';
import 'package:taskflow/features/asistente/domain/herramientas_tareas.dart';
import 'package:taskflow/features/asistente/domain/modelo_agente.dart';
import 'package:taskflow/features/tareas/domain/tarea.dart';

import 'agente_mock_test.dart' show MockTaskRepository, FakeTarea;
import 'agente_test.dart' show ModeloGuionado;

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTarea());
  });

  late MockTaskRepository repositorio;

  setUp(() {
    repositorio = MockTaskRepository();

    when(() => repositorio.agregar(any())).thenAnswer((_) async => '1');
  });

  Future<void> comprobarRechazo(
    Map<String, Object?> argumentos,
    String errorEsperado,
  ) async {
    final modelo = ModeloGuionado([
      MensajeModelo(llamadas: [LlamadaHerramienta('crear_tarea', argumentos)]),
      const MensajeModelo(texto: 'No se pudo crear la tarea.'),
    ]);

    var confirmaciones = 0;

    final agente = AgenteTaskFlow(
      modelo: modelo,
      herramientas: [CrearTarea(repositorio)],
      confirmar: (_) async {
        confirmaciones++;
        return true;
      },
    );

    await agente.enviar('Crear una tarea');

    expect(confirmaciones, 0);

    verifyNever(() => repositorio.agregar(any()));

    expect(modelo.ultimoResultado, contains(errorEsperado));
  }

  test('Crear AUTORIZADO: guarda exactamente una tarea válida', () async {
    final fecha = DateTime.now().add(const Duration(days: 7));
    final fechaTexto = formatearFecha(fecha);

    final modelo = ModeloGuionado([
      MensajeModelo(
        llamadas: [
          LlamadaHerramienta('crear_tarea', {
            'titulo': 'Estudiar Flutter',
            'descripcion': 'Repasar las pruebas automatizadas',
            'fecha_limite': fechaTexto,
          }),
        ],
      ),
      const MensajeModelo(texto: 'Tarea creada correctamente.'),
    ]);

    var confirmaciones = 0;

    final agente = AgenteTaskFlow(
      modelo: modelo,
      herramientas: [CrearTarea(repositorio)],
      confirmar: (_) async {
        confirmaciones++;

        verifyNever(() => repositorio.agregar(any()));

        return true;
      },
    );

    await agente.enviar('Crea una tarea para estudiar Flutter');

    expect(confirmaciones, 1);

    final tarea =
        verify(() => repositorio.agregar(captureAny())).captured.single
            as Tarea;

    expect(tarea.titulo, 'Estudiar Flutter');
    expect(tarea.descripcion, 'Repasar las pruebas automatizadas');
    expect(tarea.fechaLimite, DateTime(fecha.year, fecha.month, fecha.day));
    expect(tarea.completada, isFalse);

    verifyNever(() => repositorio.agregar(any()));

    expect(modelo.ultimoResultado, contains('creada correctamente'));
  });

  test('Crear SIN FECHA: no confirma ni guarda', () async {
    await comprobarRechazo({
      'titulo': 'Estudiar Flutter',
    }, 'La fecha no es válida');
  });

  test('Crear FECHA IMPOSIBLE: rechaza el 31 de febrero', () async {
    final anio = DateTime.now().year + 1;

    await comprobarRechazo({
      'titulo': 'Estudiar Flutter',
      'fecha_limite': '31/02/$anio',
    }, 'La fecha no es válida');
  });

  test('Crear TÍTULO NUMÉRICO: rechaza argumentos incorrectos', () async {
    final fecha = DateTime.now().add(const Duration(days: 7));

    await comprobarRechazo({
      'titulo': 12345,
      'fecha_limite': formatearFecha(fecha),
    }, 'Debes proporcionar un título válido');
  });

  test('Crear FECHA PASADA: no confirma ni guarda', () async {
    final ahora = DateTime.now();

    final ayer = DateTime(ahora.year, ahora.month, ahora.day - 1);

    await comprobarRechazo({
      'titulo': 'Estudiar Flutter',
      'fecha_limite': formatearFecha(ayer),
    }, 'La fecha límite no puede ser anterior a hoy');
  });
}
