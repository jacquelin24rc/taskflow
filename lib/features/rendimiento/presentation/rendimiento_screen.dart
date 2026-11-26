import 'dart:async';

import 'package:flutter/material.dart';

class ContadorFilas {
  static int construidas = 0;
}

class RendimientoScreen extends StatefulWidget {
  const RendimientoScreen({super.key, this.optimizadaAlInicio = false});

  final bool optimizadaAlInicio;

  @override
  State<RendimientoScreen> createState() => _RendimientoScreenState();
}

class _RendimientoScreenState extends State<RendimientoScreen> {
  late bool _optimizada;
  Timer? _timer;
  int _decimas = 0;
  int _filasAnteriores = 0;
  int _filasPorSegundo = 0;

  @override
  void initState() {
    super.initState();
    _optimizada = widget.optimizadaAlInicio;
    ContadorFilas.construidas = 0;
    _iniciarRelojLento();
  }

  void _iniciarRelojLento() {
    _timer?.cancel();

    if (_optimizada) return;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        _decimas++;

        if (_decimas % 10 == 0) {
          _filasPorSegundo = ContadorFilas.construidas - _filasAnteriores;

          _filasAnteriores = ContadorFilas.construidas;
        }
      });
    });
  }

  void _cambiarVersion(bool valor) {
    _timer?.cancel();

    setState(() {
      _optimizada = valor;
      _decimas = 0;
      _filasAnteriores = 0;
      _filasPorSegundo = 0;
      ContadorFilas.construidas = 0;
    });

    _iniciarRelojLento();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laboratorio de rendimiento')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Versión optimizada'),
            subtitle: Text(_optimizada ? 'Optimizada' : 'Lenta'),
            value: _optimizada,
            onChanged: _cambiarVersion,
          ),
          const Text('Total de tareas: 1500'),
          if (_optimizada)
            const _RelojOptimizado()
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text('Reloj: ${(_decimas / 10).toStringAsFixed(1)} s'),
                  Text('Filas construidas: ${ContadorFilas.construidas}'),
                  Text('Filas por segundo: $_filasPorSegundo'),
                ],
              ),
            ),
          const Divider(),
          Expanded(
            child: _optimizada
                ? const _ListaOptimizada()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var i = 0; i < 1500; i++) _FilaTarea(indice: i),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RelojOptimizado extends StatefulWidget {
  const _RelojOptimizado();

  @override
  State<_RelojOptimizado> createState() => _RelojOptimizadoState();
}

class _RelojOptimizadoState extends State<_RelojOptimizado> {
  Timer? _timer;
  int _decimas = 0;
  int _filasAnteriores = 0;
  int _filasPorSegundo = 0;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        _decimas++;

        if (_decimas % 10 == 0) {
          _filasPorSegundo = ContadorFilas.construidas - _filasAnteriores;

          _filasAnteriores = ContadorFilas.construidas;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text('Reloj: ${(_decimas / 10).toStringAsFixed(1)} s'),
          Text('Filas construidas: ${ContadorFilas.construidas}'),
          Text('Filas por segundo: $_filasPorSegundo'),
        ],
      ),
    );
  }
}

class _ListaOptimizada extends StatelessWidget {
  const _ListaOptimizada();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1500,
      itemBuilder: (context, index) {
        return _FilaTarea(indice: index);
      },
    );
  }
}

class _FilaTarea extends StatelessWidget {
  const _FilaTarea({required this.indice});

  final int indice;

  @override
  Widget build(BuildContext context) {
    ContadorFilas.construidas++;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.assignment_outlined),
        title: Text('Tarea ${indice + 1}'),
        subtitle: const Text('Tarea de ejemplo'),
      ),
    );
  }
}
