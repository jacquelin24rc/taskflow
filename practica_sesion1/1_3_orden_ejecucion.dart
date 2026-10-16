
import 'dart:async';

void main() {
  print('A. inicio de main');

  Future(() => print('B. evento (cola de eventos)'));

  scheduleMicrotask(() => print('C. microtarea'));

  Future.delayed(
    Duration.zero,
    () => print('D. temporizador de 0 ms'),
  );

  print('E. fin de main');
}
