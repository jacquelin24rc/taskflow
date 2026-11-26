class ValidadoresTarea {
  static const int tituloMax = 60;
  static const int descripcionMax = 200;

  // El título es obligatorio y debe tener entre 3 y 60 caracteres.
  static String? validarTitulo(String? valor) {
    final titulo = (valor ?? '').trim();

    if (titulo.isEmpty) {
      return 'Ingresa el título de la tarea.';
    }

    if (titulo.length < 3) {
      return 'El título debe tener al menos 3 caracteres.';
    }

    if (titulo.length > tituloMax) {
      return 'El título no puede superar los 60 caracteres.';
    }

    return null;
  }

  // La descripción es opcional, con un máximo de 200 caracteres.
  static String? validarDescripcion(String? valor) {
    final descripcion = (valor ?? '').trim();

    if (descripcion.length > descripcionMax) {
      return 'La descripción no puede superar los 200 caracteres.';
    }

    return null;
  }

  // La fecha es obligatoria y no puede ser anterior a hoy.
  static String? validarFecha(DateTime? fecha) {
    if (fecha == null) {
      return 'Selecciona una fecha límite.';
    }

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final fechaSeleccionada = DateTime(fecha.year, fecha.month, fecha.day);

    if (fechaSeleccionada.isBefore(hoy)) {
      return 'La fecha límite no puede ser anterior a hoy.';
    }

    return null;
  }
}
