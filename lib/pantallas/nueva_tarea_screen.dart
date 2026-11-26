import 'package:flutter/material.dart';

import '../modelos/tarea.dart';
import '../validacion/validadores_tarea.dart';

class NuevaTareaScreen extends StatefulWidget {
  const NuevaTareaScreen({super.key});

  @override
  State<NuevaTareaScreen> createState() => _NuevaTareaScreenState();
}

class _NuevaTareaScreenState extends State<NuevaTareaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  DateTime? _fechaLimite;
  int _prioridad = 2;
  String _categoria = 'General';
  bool _guardando = false;

  final List<String> _categorias = [
    'General',
    'Estudio',
    'Trabajo',
    'Personal',
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaLimite ?? hoy,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 10),
      helpText: 'Selecciona la fecha límite',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (!mounted) return;

    if (fecha != null) {
      setState(() {
        _fechaLimite = fecha;
      });
    }
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  void _guardarTarea() {
    final formularioValido = _formKey.currentState?.validate() ?? false;

    final errorFecha = ValidadoresTarea.validarFecha(_fechaLimite);

    if (!formularioValido) return;

    if (errorFecha != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorFecha)));
      return;
    }

    if (_guardando) return;

    setState(() {
      _guardando = true;
    });

    final nuevaTarea = Tarea(
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      fechaLimite: _fechaLimite!,
      prioridad: _prioridad,
      categoria: _categoria,
    );

    Navigator.pop(context, nuevaTarea);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva tarea'),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Crear nueva tarea',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Completa la información para registrar tu tarea.'),
              const SizedBox(height: 24),

              TextFormField(
                controller: _tituloController,
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Título de la tarea',
                  hintText: 'Ej. Terminar actividad de Flutter',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_note),
                ),
                validator: ValidadoresTarea.validarTitulo,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descripcionController,
                maxLength: 200,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: 'Escribe los detalles de la tarea',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: ValidadoresTarea.validarDescripcion,
              ),

              const SizedBox(height: 16),

              Semantics(
                button: true,
                label: 'Seleccionar fecha límite de la tarea',
                child: OutlinedButton.icon(
                  onPressed: _seleccionarFecha,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    _fechaLimite == null
                        ? 'Seleccionar fecha límite'
                        : 'Fecha: ${_formatearFecha(_fechaLimite!)}',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<int>(
                initialValue: _prioridad,
                decoration: const InputDecoration(
                  labelText: 'Prioridad',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Alta')),
                  DropdownMenuItem(value: 2, child: Text('Media')),
                  DropdownMenuItem(value: 3, child: Text('Baja')),
                ],
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() {
                      _prioridad = valor;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: _categorias.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() {
                      _categoria = valor;
                    });
                  }
                },
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardando ? null : _guardarTarea,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar tarea'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6750A4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
