import '../../../validacion/validadores_tarea.dart';

class PropuestaTarea {
  const PropuestaTarea({
    required this.titulo,
    this.descripcion = '',
    this.fechaLimite,
  });

  final String titulo;
  final String descripcion;
  final DateTime? fechaLimite;

  static final _fecha = RegExp(r'\b(\d{1,2})[/-](\d{1,2})[/-](\d{4})\b');

  factory PropuestaTarea.desdeTexto(String texto) {
    final lineas = texto
        .split('\n')
        .map((linea) => linea.trim())
        .where((linea) => linea.isNotEmpty)
        .toList();

    if (lineas.isEmpty) {
      return const PropuestaTarea(titulo: '');
    }

    return PropuestaTarea(
      titulo: _recortar(lineas.first, ValidadoresTarea.tituloMax),
      descripcion: _recortar(
        lineas.skip(1).join(' '),
        ValidadoresTarea.descripcionMax,
      ),
      fechaLimite: _buscarFecha(texto),
    );
  }

  static String _recortar(String texto, int maximo) {
    return texto.length <= maximo ? texto : texto.substring(0, maximo);
  }

  static DateTime? _buscarFecha(String texto) {
    final coincidencia = _fecha.firstMatch(texto);

    if (coincidencia == null) {
      return null;
    }

    final dia = int.parse(coincidencia[1]!);
    final mes = int.parse(coincidencia[2]!);
    final anio = int.parse(coincidencia[3]!);

    final fecha = DateTime(anio, mes, dia);

    if (fecha.day != dia || fecha.month != mes || fecha.year != anio) {
      return null;
    }

    return fecha;
  }
}
