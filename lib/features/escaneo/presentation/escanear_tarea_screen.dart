
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../data/interpretador_gemini.dart';
import '../domain/propuesta_tarea.dart';
import 'escaneo_providers.dart';

class EscanearTareaScreen extends ConsumerStatefulWidget {
  const EscanearTareaScreen({super.key});

  @override
  ConsumerState<EscanearTareaScreen> createState() =>
      _EscanearTareaScreenState();
}

class _EscanearTareaScreenState
    extends ConsumerState<EscanearTareaScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  String? _rutaImagen;
  String _textoReconocido = '';
  bool _procesando = false;
  bool _interpretando = false;
  String? _error;

  Future<void> _seleccionarImagen(ImageSource origen) async {
    if (_procesando || _interpretando) return;

    setState(() {
      _procesando = true;
      _error = null;
      _rutaImagen = null;
      _textoReconocido = '';
    });

    try {
      final imagen = await _imagePicker.pickImage(
        source: origen,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (!mounted) return;

      if (imagen == null) return;

      setState(() {
        _rutaImagen = imagen.path;
      });

      final reconocedor = ref.read(reconocedorTextoProvider);
      final texto = await reconocedor.reconocer(imagen.path);

      if (!mounted) return;

      setState(() {
        _textoReconocido = texto.trim();

        if (_textoReconocido.isEmpty) {
          _error = 'No se detectó texto en la imagen. '
              'Prueba con una fotografía más clara.';
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'No se pudo procesar la imagen. '
            'Verifica los permisos e inténtalo nuevamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _procesando = false;
        });
      }
    }
  }

  void _revisarTarea() {
    if (_textoReconocido.isEmpty ||
        _procesando ||
        _interpretando) {
      return;
    }

    final propuesta = PropuestaTarea.desdeTexto(
      _textoReconocido,
    );

    unawaited(
      context.push(
        '/tareas/nueva',
        extra: propuesta,
      ),
    );
  }

  Future<void> _interpretarConGemini() async {
    if (_textoReconocido.isEmpty ||
        _procesando ||
        _interpretando) {
      return;
    }

    setState(() {
      _interpretando = true;
      _error = null;
    });

    try {
      final interpretador = InterpretadorGemini();

      final propuesta = await interpretador.interpretar(
        _textoReconocido,
      );

      if (!mounted) return;

      unawaited(
        context.push(
          '/tareas/nueva',
          extra: propuesta,
        ),
      );
    } on TimeoutException {
      if (!mounted) return;

      setState(() {
        _error = 'Gemini tardó demasiado en responder. '
            'Intenta nuevamente.';
      });
    } on FormatException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'No se pudo interpretar la tarea: '
            '${e.message}';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'No se pudo interpretar el texto con Gemini. '
            'Verifica tu conexión e inténtalo nuevamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _interpretando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hayTexto = _textoReconocido.isNotEmpty;
    final ocupado = _procesando || _interpretando;

    ref.watch(reconocedorTextoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear tarea'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Reconocer texto de una imagen',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Toma una fotografía o selecciona una imagen '
              'que contenga los datos de una tarea.',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: ocupado
                  ? null
                  : () => _seleccionarImagen(
                        ImageSource.camera,
                      ),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar fotografía'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: ocupado
                  ? null
                  : () => _seleccionarImagen(
                        ImageSource.gallery,
                      ),
              icon: const Icon(Icons.photo_library),
              label: const Text('Elegir de galería'),
            ),
            if (_procesando) ...[
              const SizedBox(height: 24),
              const Center(
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('Reconociendo texto...'),
              ),
            ],
            if (_rutaImagen != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Imagen seleccionada',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Image.file(
                File(_rutaImagen!),
                height: 220,
                fit: BoxFit.contain,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 20),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            if (hayTexto) ...[
              const SizedBox(height: 24),
              const Text(
                'Texto reconocido',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(_textoReconocido),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: ocupado ? null : _revisarTarea,
                icon: const Icon(Icons.edit_note),
                label: const Text('Revisar tarea'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: ocupado
                    ? null
                    : _interpretarConGemini,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Interpretar con Gemini'),
              ),
              if (_interpretando) ...[
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text('Interpretando con Gemini...'),
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Gemini recibe el texto reconocido, no la foto. '
                'Los datos se mostrarán en el formulario '
                'para que puedas corregirlos antes de guardar.',
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
