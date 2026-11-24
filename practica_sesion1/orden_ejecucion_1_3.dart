
import 'dart:async';
import 'dart:developer' as developer;

void main() {
  developer.log('A. inicio de main');

  Future(() => developer.log('B. evento (cola de eventos)'));

  scheduleMicrotask(() => developer.log('C. microtarea'));

  Future.delayed(
    Duration.zero,
    () => developer.log('D. temporizador de 0 ms'),
  );

  developer.log('E. fin de main');
}
