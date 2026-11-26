import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mlkit_reconocedor_texto.dart';
import '../domain/reconocedor_texto.dart';

final reconocedorTextoProvider = Provider.autoDispose<ReconocedorTexto>((ref) {
  final reconocedor = MlKitReconocedorTexto();

  ref.onDispose(() {
    reconocedor.cerrar();
  });

  return reconocedor;
});
