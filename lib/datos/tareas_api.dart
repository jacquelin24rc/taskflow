
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../modelos/tarea.dart';

class ApiException implements Exception {
  final String mensaje;
  final int? codigo;

  const ApiException(this.mensaje, {this.codigo});

  @override
  String toString() => mensaje;
}

class TareasApi {
  TareasApi(this._client);

  final http.Client _client;

  static const _host = 'jsonplaceholder.typicode.com';
  static const _limite = Duration(seconds: 10);

  // GET: obtener 15 tareas del servidor.
  Future<List<Tarea>> obtenerTareas() async {
    final uri = Uri.https(
      _host,
      '/todos',
      {'_limit': '15'},
    );

    final respuesta = await _enviar(
      () => _client.get(uri),
    );

    if (respuesta.statusCode != 200) {
      throw ApiException(
        'El servidor respondió con un error '
        '(${respuesta.statusCode}).',
        codigo: respuesta.statusCode,
      );
    }

    final datos = _decodificar(respuesta.body);

    if (datos is! List) {
      throw const ApiException(
        'La respuesta del servidor no tiene el formato esperado.',
      );
    }

    final tareas = <Tarea>[];

    for (final item in datos) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      try {
        tareas.add(Tarea.fromJson(item));
      } on FormatException {
        // Se descarta el elemento inválido y se continúa.
      }
    }

    return tareas;
  }

  // POST: enviar una tarea nueva.
  Future<Tarea> crearTarea(Tarea tarea) async {
    final uri = Uri.https(_host, '/todos');

    final respuesta = await _enviar(
      () => _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(tarea.toJson()),
      ),
    );

    if (respuesta.statusCode != 201) {
      throw ApiException(
        'No se pudo crear la tarea '
        '(${respuesta.statusCode}).',
        codigo: respuesta.statusCode,
      );
    }

    final datos = _decodificar(respuesta.body);

    final id = datos is Map<String, dynamic>
        ? datos['id']
        : null;

    tarea.id = id is int ? id : null;

    return tarea;
  }

  // Manejo de errores de conexión y tiempo de espera.
  Future<http.Response> _enviar(
    Future<http.Response> Function() peticion,
  ) async {
    try {
      return await peticion().timeout(_limite);
    } on TimeoutException {
      throw const ApiException(
        'El servidor tardó demasiado en responder. '
        'Intenta de nuevo.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No fue posible conectar con el servidor. '
        'Revisa tu conexión a internet.',
      );
    }
  }

  // Conversión y validación de la respuesta JSON.
  Object? _decodificar(String cuerpo) {
    try {
      return jsonDecode(cuerpo);
    } on FormatException {
      throw const ApiException(
        'El servidor envió una respuesta que no es JSON válido.',
      );
    }
  }
}
