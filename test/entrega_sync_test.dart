import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:verfwork/response/entrega_response.dart';
import 'package:verfwork/services/entrega_sync_service.dart';
import 'package:verfwork/widgets/sync_errors_dialog.dart';

void main() {
  late EntregaResponse entrega;
  late bool marcada;

  setUp(() {
    marcada = false;
    entrega = EntregaResponse(
      identrega: 42,
      idcartilla: 'C123',
      qr: 'QR1',
      cantidad: 2,
      fecha: '27/10/2026',
      hora: '10:00',
      nombre_trabajador: 'Trabajador',
      rut: '12345678',
      digito: '4',
      swExtranjeroSinDocumento: 0,
    );
  });

  Future<String> enviar(
    Future<http.Response> Function(http.Request) handler, {
    Future<void> Function()? actualizar,
    Duration timeout = const Duration(seconds: 30),
    String baseUrl = 'https://example.test/api',
  }) {
    final client = MockClient(handler);
    addTearDown(client.close);
    return sincronizarEntrega(
      entrega: entrega,
      baseUrl: baseUrl,
      client: client,
      timeout: timeout,
      marcarSincronizada:
          actualizar ??
          () async {
            marcada = true;
          },
    );
  }

  test('Muestra entrega, RUT, HTTP y validaciones del servidor', () async {
    final result = await enviar(
      (_) async => http.Response(
        jsonEncode({
          'message': 'Datos inválidos',
          'errors': {
            'Rut': ['El RUT ya existe'],
            'Cantidad': ['Cantidad inválida'],
          },
        }),
        422,
      ),
    );
    expect(result, contains('Entrega 42'));
    expect(result, contains('Cartilla C123'));
    expect(result, contains('RUT: 12345678'));
    expect(result, contains('HTTP 422'));
    expect(result, contains('Datos inválidos'));
    expect(result, contains('Rut: El RUT ya existe'));
    expect(result, contains('Cantidad: Cantidad inválida'));
    expect(marcada, isFalse);
  });

  test('Agrega el endpoint conservando api y sin duplicar barras', () async {
    for (final base in [
      'https://example.test/api',
      'https://example.test/api/',
      'https://example.test/api///',
      ' https://example.test/api/ ',
    ]) {
      final result = await enviar((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'https://example.test/api/androidcartilladetalle/save_new',
        );
        return http.Response('{"status":"success"}', 200);
      }, baseUrl: base);
      expect(result, 'ok');
    }
  });

  test('HTTP 500 muestra el mensaje y conserva la entrega pendiente', () async {
    final result = await enviar(
      (_) async => http.Response(
        jsonEncode({'status': 'error', 'message': 'Cartilla ya fue aprobada'}),
        500,
      ),
    );
    expect(result, contains('HTTP 500'));
    expect(result, contains('Cartilla ya fue aprobada'));
    expect(marcada, isFalse);
  });

  test('Detecta errores de negocio aunque HTTP sea 200', () async {
    for (final datos in [
      {'status': 'error', 'message': 'No existe la cartilla'},
      {'success': false, 'mensaje': 'No existe la cartilla'},
      {'code': 422, 'message': 'No existe la cartilla'},
    ]) {
      final result = await enviar(
        (_) async => http.Response(jsonEncode(datos), 200),
      );
      expect(result, contains('HTTP 200'));
      expect(result, contains('No existe la cartilla'));
      expect(marcada, isFalse);
    }
  });

  test('Explica el RUT inválido sin enviar una solicitud', () async {
    entrega.rut = '123456789';
    final result = await enviar((_) async {
      fail('No debe enviar una entrega con RUT inválido');
    });
    expect(result, contains('Entrega 42'));
    expect(result, contains('RUT inválido'));
    expect(result, contains('entre 1 y 8 dígitos'));
    expect(marcada, isFalse);
  });

  test('Muestra el error de conexión', () async {
    final result = await enviar((_) async {
      throw http.ClientException('No se pudo resolver el servidor');
    });
    expect(result, contains('No se pudo enviar la entrega'));
    expect(result, contains('No se pudo resolver el servidor'));
    expect(marcada, isFalse);
  });

  test('Informa cuando se agota el tiempo de espera', () async {
    final result = await enviar((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return http.Response('{"status":"success"}', 200);
    }, timeout: const Duration(milliseconds: 1));
    expect(result, contains('Tiempo de espera agotado'));
    expect(marcada, isFalse);
  });

  test('No acepta HTML como confirmación de la API', () async {
    final result = await enviar(
      (_) async => http.Response('<html><h1>Iniciar sesión</h1></html>', 200),
    );
    expect(result, contains('Respuesta inesperada'));
    expect(result, contains('Iniciar sesión'));
    expect(marcada, isFalse);
  });

  test('Explica una respuesta sin detalle', () async {
    final result = await enviar((_) async => http.Response('', 503));
    expect(result, contains('HTTP 503'));
    expect(result, contains('El servidor no envió un detalle del error'));
    expect(marcada, isFalse);
  });

  test(
    'Solo marca sincronizada una respuesta correcta y conserva el payload',
    () async {
      final result = await enviar((request) async {
        final data = jsonDecode(request.bodyFields['json']!) as Map;
        expect(data['Rut'], '12345678');
        expect(data['Digito'], '4');
        expect(data['SW_EXTRANJERO_SIN_DOCUMENTO'], 0);
        expect(data['IdEntrega'], 42);
        return http.Response('{"status":"success","code":200}', 200);
      });
      expect(result, 'ok');
      expect(marcada, isTrue);
    },
  );

  test('Distingue un fallo al actualizar el estado local', () async {
    final result = await enviar(
      (_) async => http.Response('{"status":"success"}', 200),
      actualizar: () async {
        throw StateError('Base de datos cerrada');
      },
    );
    expect(result, contains('El servidor recibió la entrega'));
    expect(result, contains('Base de datos cerrada'));
    expect(result, isNot('ok'));
  });

  testWidgets('El diálogo permite leer listas largas sin desbordarse', (
    tester,
  ) async {
    final messages = List.generate(
      50,
      (i) => 'Entrega $i\nHTTP 422: RUT inválido',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed:
                    () => showDialog<void>(
                      context: context,
                      builder: (_) => SyncErrorsDialog(messages: messages),
                    ),
                child: const Text('Mostrar'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Mostrar'));
    await tester.pumpAndSettle();
    expect(find.text('Detalle de sincronización'), findsOneWidget);
    expect(
      tester.widget<SelectableText>(find.byType(SelectableText)).data,
      contains('Entrega 49'),
    );
    expect(find.byType(SingleChildScrollView), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Aceptar'));
    await tester.pumpAndSettle();
    expect(find.text('Detalle de sincronización'), findsNothing);
  });
}
