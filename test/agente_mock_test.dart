import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/features/asistente/domain/agente.dart';
import 'package:taskflow/features/asistente/domain/herramientas_tareas.dart';
import 'package:taskflow/features/asistente/domain/modelo_agente.dart';
import 'package:taskflow/features/tareas/domain/tarea.dart';
import 'package:taskflow/features/tareas/domain/task_repository.dart';

import 'agente_test.dart' show ModeloGuionado;

class MockTaskRepository extends Mock implements TaskRepository {}

class FakeTarea extends Fake implements Tarea {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTarea());
  });

  test('Crear RECHAZADO: nunca se llama al método agregar', () async {
    final repositorio = MockTaskRepository();

    when(() => repositorio.agregar(any())).thenAnswer((_) async => '1');

    final fecha = DateTime.now().add(const Duration(days: 7));

    final fechaTexto =
        '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';

    final modelo = ModeloGuionado([
      MensajeModelo(
        llamadas: [
          LlamadaHerramienta('crear_tarea', {
            'titulo': 'Leer Cap. 19',
            'fecha_limite': fechaTexto,
          }),
        ],
      ),
      const MensajeModelo(texto: 'Acción rechazada.'),
    ]);

    var confirmaciones = 0;

    final agente = AgenteTaskFlow(
      modelo: modelo,
      herramientas: [CrearTarea(repositorio)],
      confirmar: (_) async {
        confirmaciones++;
        return false;
      },
    );

    await agente.enviar('Crea Leer Cap. 19');

    expect(confirmaciones, 1);

    verifyNever(() => repositorio.agregar(any()));

    expect(modelo.ultimoResultado, contains('RECHAZÓ'));
  });

  test('Eliminar AMBIGUO: no confirma ni elimina tareas', () async {
    final repositorio = MockTaskRepository();

    const tareas = [
      Tarea(
        id: '1',
        titulo: 'Repasar Cap. 15',
        descripcion: 'Tarea de prueba 1',
      ),
      Tarea(
        id: '2',
        titulo: 'Repasar Cap. 16',
        descripcion: 'Tarea de prueba 2',
      ),
    ];

    when(
      () => repositorio.observarTareas(),
    ).thenAnswer((_) => Stream.value(tareas));

    when(() => repositorio.eliminar(any())).thenAnswer((_) async {});

    final modelo = ModeloGuionado([
      const MensajeModelo(
        llamadas: [
          LlamadaHerramienta('eliminar_tarea', {'titulo': 'Repasar'}),
        ],
      ),
      const MensajeModelo(
        texto: 'Debes especificar cuál tarea deseas eliminar.',
      ),
    ]);

    var confirmaciones = 0;

    final agente = AgenteTaskFlow(
      modelo: modelo,
      herramientas: [EliminarTarea(repositorio)],
      confirmar: (_) async {
        confirmaciones++;
        return true;
      },
    );

    await agente.enviar('Elimina Repasar');

    expect(confirmaciones, 0);

    verify(() => repositorio.observarTareas()).called(1);

    verifyNever(() => repositorio.eliminar(any()));

    expect(modelo.ultimoResultado, contains('Hay varias coincidencias'));

    expect(modelo.ultimoResultado, contains('Repasar Cap. 15'));

    expect(modelo.ultimoResultado, contains('Repasar Cap. 16'));

    expect(
      modelo.ultimoResultado,
      contains('Debes especificar cuál tarea deseas eliminar'),
    );
  });
}
