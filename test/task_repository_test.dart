
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/modelos/tarea.dart';
import 'package:taskflow/repositorios/task_repository.dart';

class FakeTaskRepository implements TaskRepository {
  final List<Tarea> _tareas = [];
  int _siguienteId = 1;

  @override
  Future<List<Tarea>> obtenerTareas() async {
    return List<Tarea>.from(_tareas);
  }

  @override
  Future<Tarea> agregar(Tarea tarea) async {
    tarea.id = _siguienteId++;
    _tareas.add(tarea);
    return tarea;
  }

  @override
  Future<void> actualizar(Tarea tarea) async {
    final indice = _tareas.indexWhere((t) => t.id == tarea.id);

    if (indice == -1) {
      throw StateError('Tarea no encontrada');
    }

    _tareas[indice] = tarea;
  }

  @override
  Future<void> eliminar(int id) async {
    _tareas.removeWhere((t) => t.id == id);
  }
}

void main() {
  late FakeTaskRepository repositorio;

  setUp(() {
    repositorio = FakeTaskRepository();
  });

  Tarea crearTarea() {
    return Tarea(
      titulo: 'Prueba Fake Repository',
      descripcion: 'Prueba de Semana 16',
      fechaLimite: DateTime(2026, 11, 20),
      categoria: 'Estudio',
      prioridad: 2,
    );
  }

  test('Agregar una tarea', () async {
    final tarea = await repositorio.agregar(crearTarea());

    expect(tarea.id, 1);
    expect((await repositorio.obtenerTareas()).length, 1);
  });

  test('Consultar tareas', () async {
    await repositorio.agregar(crearTarea());

    final tareas = await repositorio.obtenerTareas();

    expect(tareas.length, 1);
    expect(tareas.first.titulo, 'Prueba Fake Repository');
  });

  test('Actualizar una tarea', () async {
    final tarea = await repositorio.agregar(crearTarea());

    tarea.completada = true;
    await repositorio.actualizar(tarea);

    final tareas = await repositorio.obtenerTareas();

    expect(tareas.first.completada, true);
  });

  test('Eliminar una tarea', () async {
    final tarea = await repositorio.agregar(crearTarea());

    await repositorio.eliminar(tarea.id!);

    final tareas = await repositorio.obtenerTareas();

    expect(tareas.isEmpty, true);
  });
}
