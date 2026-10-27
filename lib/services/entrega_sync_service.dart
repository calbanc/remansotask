import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../response/entrega_response.dart';
import '../util/validar_rut.dart';

Future<String> sincronizarEntrega({
  required EntregaResponse entrega,
  required String baseUrl,
  required Future<void> Function() marcarSincronizada,
  http.Client? client,
  Duration timeout = const Duration(seconds: 30),
}) async {
  String error(String detalle) =>
      'Entrega ${entrega.identrega} · Cartilla ${entrega.idcartilla}\n'
      'RUT: ${entrega.rut ?? "vacío"} · DV: ${entrega.digito ?? "vacío"}\n'
      '$detalle';

  if (!esRutParaGuardar(entrega.rut)) {
    return error(
      'RUT inválido: debe contener entre 1 y 8 dígitos numéricos, '
      'sin puntos, guion ni letras.',
    );
  }

  http.Response response;
  final connection = client ?? http.Client();
  try {
    final base = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base/androidcartilladetalle/save_new');
    final body = {
      'json': jsonEncode({
        'IdCartilla': entrega.idcartilla,
        'Qr': entrega.qr,
        'Fecha': entrega.fecha,
        'Cantidad': entrega.cantidad,
        'Nombre_trabajador': entrega.nombre_trabajador,
        'IdEntrega': entrega.identrega,
        'Rut': entrega.rut,
        'IdTrabajadorXContratista': entrega.idtrabajadorxcontratista,
        'Digito': entrega.digito,
        'SW_EXTRANJERO_SIN_DOCUMENTO': entrega.swExtranjeroSinDocumento,
      }),
    };

    print(uri);
    print(body);
    response = await connection.post(uri, body: body).timeout(timeout);
  } on TimeoutException {
    return error(
      'Tiempo de espera agotado: el servidor no respondió '
      'en ${timeout.inSeconds} segundos.',
    );
  } catch (e) {
    return error('No se pudo enviar la entrega: $e');
  } finally {
    if (client == null) connection.close();
  }

  dynamic datos;
  try {
    datos = jsonDecode(response.body);
  } on FormatException {
    datos = null;
  }

  final httpCorrecto = response.statusCode >= 200 && response.statusCode < 300;
  final estado =
      datos is Map
          ? '${datos['status'] ?? datos['estado'] ?? ''}'.toLowerCase()
          : '';
  final codigo =
      datos is Map
          ? int.tryParse('${datos['code'] ?? datos['codigo'] ?? ''}')
          : null;
  final errorServidor =
      datos is Map &&
      (datos['success'] == false ||
          ['error', 'failed', 'failure', 'fail', 'false'].contains(estado) ||
          (codigo != null && codigo >= 400));

  if (!httpCorrecto || errorServidor || datos is! Map) {
    final detalle = _detalleServidor(datos, response.body);
    final motivo =
        httpCorrecto && datos is! Map
            ? 'Respuesta inesperada del servidor'
            : 'El servidor rechazó la entrega';
    return error('$motivo (HTTP ${response.statusCode}).\n$detalle');
  }

  try {
    await marcarSincronizada();
  } catch (e) {
    return error(
      'El servidor recibió la entrega, pero no se pudo guardar '
      'su estado de sincronización en el dispositivo: $e',
    );
  }
  return 'ok';
}

String _detalleServidor(dynamic datos, String body) {
  final detalles = <String>[];
  if (datos is Map) {
    for (final key in [
      'message',
      'mensaje',
      'error',
      'errors',
      'detail',
      'details',
      'description',
      'descripcion',
    ]) {
      if (datos[key] == null) continue;
      final detalle = _formatearDetalle(datos[key]);
      if (detalle.isNotEmpty && !detalles.contains(detalle)) {
        detalles.add(detalle);
      }
    }
    if (detalles.isEmpty) detalles.add(jsonEncode(datos));
  } else {
    final detalle =
        body
            .replaceAll(RegExp(r'<[^>]*>'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
    if (detalle.isNotEmpty) detalles.add(detalle);
  }
  return detalles.isEmpty
      ? 'El servidor no envió un detalle del error.'
      : detalles.join('\n');
}

String _formatearDetalle(dynamic value) {
  if (value is Map) {
    return value.entries
        .map((e) => '${e.key}: ${_formatearDetalle(e.value)}')
        .join('\n');
  }
  if (value is List) return value.map(_formatearDetalle).join('; ');
  return value?.toString().trim() ?? '';
}
