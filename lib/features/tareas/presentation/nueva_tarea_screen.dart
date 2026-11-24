
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../validacion/validadores_tarea.dart';
import '../../escaneo/domain/propuesta_tarea.dart';
import '../domain/tarea.dart';
import 'tareas_providers.dart';

class NuevaTareaScreen extends ConsumerStatefulWidget {
  const NuevaTareaScreen({super.key, this.inicial});

  final PropuestaTarea? inicial;

  @override
  ConsumerState<NuevaTareaScreen> createState() =>
      _NuevaTareaScreenState();
}

class _NuevaTareaScreenState extends ConsumerState<NuevaTareaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  int _prioridad = 2;
  DateTime? _fechaLimite;
  String _categoria = '';
  bool _guardando = false;

  @override
  void initState() {
    super.initState();

    final propuesta = widget.inicial;
    if (propuesta == null) return;

    _tituloController.text = propuesta.titulo;
    _descripcionController.text = propuesta.descripcion;

    final fecha = propuesta.fechaLimite;
    final hoy = DateUtils.dateOnly(DateTime.now());

    if (fecha != null && !fecha.isBefore(hoy)) {
      _fechaLimite = fecha;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateUtils.dateOnly(DateTime.now());

    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaLimite ?? hoy,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 10),
    );

    if (fecha != null && mounted) {
      setState(() {
        _fechaLimite = fecha;
      });
    }
  }

  Future<void> _guardarTarea() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaLimite != null &&
        _fechaLimite!.isBefore(DateUtils.dateOnly(DateTime.now()))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha límite no puede ser anterior a hoy.'),
        ),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final repositorio = ref.read(firestoreTaskRepositoryProvider);

      if (repositorio == null) {
        throw StateError('No hay una sesión activa.');
      }

      final tarea = Tarea(
        id: '',
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        prioridad: _prioridad,
        fechaLimite: _fechaLimite,
        categoria: _categoria,
      );

      await repositorio.agregar(tarea);

      if (!mounted) return;

      context.go('/tareas');
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo guardar la tarea. '
            'Verifica tu conexión y los permisos de Firestore.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva tarea'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/tareas'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Registrar nueva tarea',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.inicial != null) ...[
                    const SizedBox(height: 16),
                    const ListTile(
                      leading: Icon(Icons.auto_awesome),
                      title: Text('Datos detectados en la foto'),
                      subtitle: Text(
                        'Revísalos y corrígelos antes de guardar.',
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _tituloController,
                    maxLength: ValidadoresTarea.tituloMax,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      hintText: 'Ejemplo: Estudiar Firebase',
                      border: OutlineInputBorder(),
                    ),
                    validator: ValidadoresTarea.validarTitulo,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    maxLength: ValidadoresTarea.descripcionMax,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      hintText: 'Describe lo que necesitas realizar',
                      border: OutlineInputBorder(),
                    ),
                    validator: ValidadoresTarea.validarDescripcion,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _prioridad,
                    decoration: const InputDecoration(
                      labelText: 'Prioridad',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Baja')),
                      DropdownMenuItem(value: 2, child: Text('Media')),
                      DropdownMenuItem(value: 3, child: Text('Alta')),
                    ],
                    onChanged: _guardando
                        ? null
                        : (valor) {
                            if (valor != null) {
                              setState(() {
                                _prioridad = valor;
                              });
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _categoria,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: '',
                        child: Text('Sin categoría'),
                      ),
                      DropdownMenuItem(
                        value: 'Estudio',
                        child: Text('Estudio'),
                      ),
                      DropdownMenuItem(
                        value: 'Trabajo',
                        child: Text('Trabajo'),
                      ),
                      DropdownMenuItem(
                        value: 'Personal',
                        child: Text('Personal'),
                      ),
                    ],
                    onChanged: _guardando
                        ? null
                        : (valor) {
                            if (valor != null) {
                              setState(() {
                                _categoria = valor;
                              });
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _guardando ? null : _seleccionarFecha,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _fechaLimite == null
                          ? 'Seleccionar fecha límite'
                          : 'Fecha límite: '
                              '${_fechaLimite!.day}/'
                              '${_fechaLimite!.month}/'
                              '${_fechaLimite!.year}',
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _guardando ? null : _guardarTarea,
                    icon: _guardando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _guardando ? 'Guardando...' : 'Guardar tarea',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _guardando
                        ? null
                        : () => context.go('/tareas'),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
