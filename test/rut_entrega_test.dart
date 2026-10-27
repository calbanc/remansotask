import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verfwork/providers/addtrabajadorcontratistaprovider.dart';
import 'package:verfwork/response/Entrega.dart';
import 'package:verfwork/response/entrega_response.dart';
import 'package:verfwork/util/validar_rut.dart';
import 'package:verfwork/widgets/rut_otp_field.dart';

void main() {
  test('Valida cuerpos de uno a ocho digitos y los formatos permitidos', () {
    for (final rut in [
      '1-9',
      '12-4',
      '123-6',
      '1234-3',
      '12345-5',
      '123456-0',
      '1234567-4',
      '12345678-5',
      '123456785',
      '12.345.678-5',
      '1.234.567-4',
      ' 6-k ',
      '14-0',
    ]) {
      expect(validarRut(rut), isTrue, reason: rut);
    }
  });

  test('Rechaza RUT vacio, cero, formato incorrecto y DV incorrecto', () {
    for (final rut in [
      null,
      '',
      ' ',
      '0-0',
      '00000000-0',
      '12345678-4',
      '6-0',
      '14-K',
      '123456789-2',
      '12.34.567-4',
      '1 234567-4',
      '12345678-',
      '12345678-55',
      'ABC-5',
      '12.345.6785',
    ]) {
      expect(validarRut(rut), isFalse, reason: '$rut');
    }
  });

  test('Cada registro nuevo inicia con la validacion activa', () {
    final provider = AddTrabajadorContratistaProvider();
    expect(provider.validarut, isTrue);
    provider.validarut = false;
    expect(provider.validarut, isFalse);
    expect(AddTrabajadorContratistaProvider().validarut, isTrue);
  });

  test('El indicador conserva su valor al serializar y sincronizar', () {
    final entrega = Entrega(nombre: 'Trabajador', rut: '12345678');
    expect(entrega.toJson()['SW_EXTRANJERO_SIN_DOCUMENTO'], 1);
    entrega.swExtranjeroSinDocumento = 0;
    final json = entrega.toJson();
    expect(Entrega.fromJson(json).swExtranjeroSinDocumento, 0);
    final response = EntregaResponse.fromJson({
      ...json,
      'IdEntrega': 1,
      'IdAndroidCartilla': 'C1',
      'Qr': 'QR1',
      'Cantidad': 1.0,
      'Fecha': '27/10/2026',
      'Hora': '12:00',
    });
    expect(response.toJson()['SW_EXTRANJERO_SIN_DOCUMENTO'], 0);
    json.remove('SW_EXTRANJERO_SIN_DOCUMENTO');
    expect(Entrega.fromJson(json).swExtranjeroSinDocumento, 1);
  });

  Future<void> showField(
    WidgetTester tester,
    TextEditingController controller, {
    bool validar = true,
    GlobalKey<FormState>? formKey,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: RutOtpField(
              controller: controller,
              validarRutChile: validar,
              labelText: 'Rut/DNI Trabajador',
              validator:
                  (value) =>
                      !validar || validarRut(value)
                          ? null
                          : 'Debe ingresar un rut valido',
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Valida al escribir el DV y al corregirlo', (tester) async {
    final controller = TextEditingController();
    await showField(tester, controller);
    final inputs = find.byType(TextFormField);
    for (var i = 0; i < 8; i++) {
      await tester.enterText(inputs.at(i), '${i + 1}');
      await tester.pump();
      expect(find.text('Debe ingresar un rut valido'), findsNothing);
      expect(
        find.text('Debe completar todos los campos del rut'),
        findsNothing,
      );
    }
    await tester.enterText(inputs.last, '4');
    await tester.pump();
    expect(find.text('Debe ingresar un rut valido'), findsOneWidget);
    await tester.enterText(inputs.last, '5');
    await tester.pump();
    expect(find.text('Debe ingresar un rut valido'), findsNothing);
    expect(controller.text, '12345678-5');
  });

  testWidgets('Permite cuerpo corto y K minuscula', (tester) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showField(tester, controller, formKey: formKey);
    await tester.enterText(find.byType(TextFormField).first, '6');
    await tester.enterText(find.byType(TextFormField).last, 'k');
    await tester.pump();
    expect(controller.text, '6-K');
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('Revalida al cambiar Validar Rut Chile', (tester) async {
    final controller = TextEditingController(text: '12345678-4');
    final formKey = GlobalKey<FormState>();
    await showField(tester, controller, formKey: formKey);
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    await showField(tester, controller, validar: false, formKey: formKey);
    await tester.pump();
    expect(find.text('Debe ingresar un rut valido'), findsNothing);
    await showField(tester, controller, formKey: formKey);
    await tester.pump();
    expect(find.text('Debe ingresar un rut valido'), findsOneWidget);
  });

  testWidgets('Carga RUT formateado corto sin duplicar el DV', (tester) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showField(tester, controller, formKey: formKey);
    controller.text = '1.234.567-4';
    await tester.pump();
    expect(formKey.currentState!.validate(), isTrue);
    final fields = tester.widgetList<TextFormField>(find.byType(TextFormField));
    expect(fields.map((field) => field.controller!.text).toList(), [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '',
      '4',
    ]);
  });

  testWidgets('Impide guardar un RUT incompleto o con huecos', (tester) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showField(tester, controller, formKey: formKey);
    expect(formKey.currentState!.validate(), isFalse);
    await tester.enterText(find.byType(TextFormField).at(1), '6');
    await tester.enterText(find.byType(TextFormField).last, 'K');
    await tester.pump();
    expect(formKey.currentState!.validate(), isFalse);
  });
}
