
sealed class FaseAgente {
  const FaseAgente();
}

final class Inactivo extends FaseAgente {
  const Inactivo();
}

final class Pensando extends FaseAgente {
  const Pensando();
}

final class EjecutandoHerramienta extends FaseAgente {
  const EjecutandoHerramienta(this.nombre);

  final String nombre;
}

final class EsperandoConfirmacion extends FaseAgente {
  const EsperandoConfirmacion(this.descripcion);

  final String descripcion;
}
