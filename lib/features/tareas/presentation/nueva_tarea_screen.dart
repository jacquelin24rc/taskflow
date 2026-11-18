import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/tarea.dart';
import 'tareas_providers.dart';

class NuevaTareaScreen extends ConsumerStatefulWidget {
  const NuevaTareaScreen({super.key});

  @override
  ConsumerState<NuevaTareaScreen> createState() =>
      _NuevaTareaScreenState();
}

class _NuevaTareaScreenState extends ConsumerState<NuevaTareaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  int _prioridad = 2;
  bool _guardando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardarTarea() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final repositorio = ref.read(
        firestoreTaskRepositoryProvider,
      );

      if (repositorio == null) {
        throw StateError('No hay una sesión activa.');
      }

      final tarea = Tarea(
        id: '',
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        prioridad: _prioridad,
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
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _tituloController,
                    maxLength: 60,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      hintText: 'Ejemplo: Estudiar Firebase',
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      final titulo = valor?.trim() ?? '';

                      if (titulo.length < 3) {
                        return 'El título debe tener al menos 3 caracteres.';
                      }

                      if (titulo.length > 60) {
                        return 'El título no puede superar 60 caracteres.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      hintText: 'Describe lo que necesitas realizar',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _prioridad,
                    decoration: const InputDecoration(
                      labelText: 'Prioridad',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text('Baja'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('Media'),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text('Alta'),
                      ),
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
