
import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasService {
  static const String _claveSoloPendientes = 'solo_pendientes';

  Future<bool> obtenerSoloPendientes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_claveSoloPendientes) ?? false;
  }

  Future<void> guardarSoloPendientes(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveSoloPendientes, valor);
  }
}
