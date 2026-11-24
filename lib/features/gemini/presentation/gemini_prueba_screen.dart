
import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';

class GeminiPruebaScreen extends StatefulWidget {
  const GeminiPruebaScreen({super.key});

  @override
  State<GeminiPruebaScreen> createState() =>
      _GeminiPruebaScreenState();
}

class _GeminiPruebaScreenState extends State<GeminiPruebaScreen> {
  final TextEditingController _controlador = TextEditingController();

  bool _cargando = false;
  String _resultado = '';
  String? _error;

  Future<void> _preguntar() async {
    final pregunta = _controlador.text.trim();

    if (pregunta.isEmpty || _cargando) {
      return;
    }

    setState(() {
      _cargando = true;
      _resultado = '';
      _error = null;
    });

    try {
      final modelo = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-3.5-flash-lite',
      );

      final respuesta = await modelo.generateContent([
        Content.text(pregunta),
      ]).timeout(const Duration(seconds: 45));

      if (!mounted) return;

      setState(() {
        final texto = respuesta.text;

        if (texto == null || texto.trim().isEmpty) {
          _resultado = 'Gemini no devolvió una respuesta.';
        } else {
          _resultado = texto;
        }
      });
    } on TimeoutException {
      if (!mounted) return;

      setState(() {
        _error =
            'Gemini tardó demasiado en responder. '
            'Intenta nuevamente más tarde.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error =
            'No se pudo obtener una respuesta de Gemini. '
            'Verifica tu conexión y la configuración de Firebase.\n\n'
            'Detalle: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Gemini'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Escribe una pregunta para Gemini:',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controlador,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '¿Qué es Flutter?',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _cargando ? null : _preguntar,
              child: const Text('Preguntar a Gemini'),
            ),
            const SizedBox(height: 16),
            if (_cargando)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_resultado.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(_resultado),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
