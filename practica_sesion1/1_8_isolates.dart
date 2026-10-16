
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ExperimentoIsolates(),
  ));
}

int calculoPesado(int n) {
  var total = 0;

  for (var i = 0; i < n; i++) {
    total += i % 7;
  }

  return total;
}

class ExperimentoIsolates extends StatefulWidget {
  const ExperimentoIsolates({super.key});

  @override
  State<ExperimentoIsolates> createState() =>
      _ExperimentoIsolatesState();
}

class _ExperimentoIsolatesState extends State<ExperimentoIsolates> {
  bool procesando = false;
  String resultado = 'Presiona un botón para comenzar.';

  Future<void> ejecutarSinIsolate() async {
    setState(() {
      procesando = true;
      resultado = 'Ejecutando sin isolate...';
    });

    await Future.delayed(const Duration(milliseconds: 100));

    final reloj = Stopwatch()..start();
    final total = calculoPesado(400000000);
    reloj.stop();

    if (!mounted) return;

    setState(() {
      procesando = false;
      resultado =
          'Sin isolate: ${reloj.elapsedMilliseconds} ms. Resultado: $total';
    });
  }

  Future<void> ejecutarConIsolate() async {
    setState(() {
      procesando = true;
      resultado = 'Ejecutando con isolate...';
    });

    await Future.delayed(const Duration(milliseconds: 100));

    final reloj = Stopwatch()..start();
    final total = await compute(calculoPesado, 400000000);
    reloj.stop();

    if (!mounted) return;

    setState(() {
      procesando = false;
      resultado =
          'Con isolate: ${reloj.elapsedMilliseconds} ms. Resultado: $total';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Experimento de Isolates'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Semana 14 - Programación asíncrona',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 24),
              if (procesando)
                const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                resultado,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: procesando ? null : ejecutarSinIsolate,
                child: const Text('Ejecutar sin isolate'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: procesando ? null : ejecutarConIsolate,
                child: const Text('Ejecutar con isolate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
