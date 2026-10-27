import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:verfwork/providers/addtrabajadorcontratistaprovider.dart';
import 'package:verfwork/providers/editworkerprovider.dart';
import 'package:verfwork/response/Entrega.dart';
import 'package:verfwork/response/entrega_response.dart';
import 'package:verfwork/response/listadoentrega_response.dart';
import 'package:verfwork/response/TrabajadorContratistaResponse.dart';
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

  test('Al editar se restaura el estado guardado de Validar Rut Chile', () {
    final provider = EditWorkerProvider();
    for (final value in [0, 1, '0', '1', null]) {
      final trabajador = ListadoEntregaResponse.fromJson({
        'Rut': '12345678',
        'Digito': '5',
        'Nombre': 'Trabajador',
        'SW_EXTRANJERO_SIN_DOCUMENTO': value,
      });
      provider.cargardatosiniciales(trabajador);
      expect(provider.validarut, value == 0 || value == '0');
    }
  });

  test(
    'Alta y edicion guardan extranjero como inverso de Validar Rut Chile',
    () async {
      for (final validar in [true, false]) {
        final db = _RecordingDatabase();
        final alta = _AddProviderWithDatabase(db)..validarut = validar;
        final entrega = Entrega(
          nombre: 'Trabajador',
          rut: '12345678',
          digito: '5',
        );
        await alta.insertentry(entrega);
        final esperado = validar ? 0 : 1;
        expect(db.saved!['SW_EXTRANJERO_SIN_DOCUMENTO'], esperado);
        expect(entrega.swExtranjeroSinDocumento, esperado);

        final trabajador = ListadoEntregaResponse.fromJson({
          ...db.saved!,
          'Qr': 'QR1',
        });
        final edicion = _EditProviderWithDatabase(db)
          ..cargardatosiniciales(trabajador);
        expect(edicion.validarut, validar);
        await edicion.updateworkerentry(
          '12345678',
          'Trabajador',
          trabajador,
          '5',
        );
        expect(db.saved!['SW_EXTRANJERO_SIN_DOCUMENTO'], esperado);
        expect(db.saved!['SwSincronizado'], '0');

        edicion.validarut = !validar;
        await edicion.updateworkerentry(
          '12345678',
          'Trabajador',
          trabajador,
          '5',
        );
        expect(db.saved!['SW_EXTRANJERO_SIN_DOCUMENTO'], validar ? 1 : 0);
      }
    },
  );

  test('Sin modulo chileno exige exactamente ocho digitos y un DV', () {
    for (final input in [
      '12345678-4',
      '123456784',
      '12.345.678-4',
      '12.345.678-k',
    ]) {
      expect(
        validarDocumento(input, validarRutChile: false),
        isNull,
        reason: input,
      );
    }
    for (final input in [
      null,
      '',
      '123',
      '12345678',
      '1234567-4',
      '1.234.567-4',
      '12345678-',
      '12345678-A',
      'PE-AB123456789',
      '12.34.5678-4',
      '123456789-0',
      '123456789012-3',
      '123.456.789.012-k',
    ]) {
      expect(
        validarDocumento(input, validarRutChile: false),
        isNotNull,
        reason: '$input',
      );
    }
    expect(validarDocumento('12345678-4', validarRutChile: true), isNotNull);
  });

  test('Separa el cuerpo y el DV sin importar si se calcula el modulo', () {
    for (final input in ['12345678-4', '123456784', '12.345.678-4']) {
      final documento = separarDocumento(input);
      expect(documento, (rut: '12345678', digito: '4'));
      final entrega = Entrega(
        nombre: 'Trabajador',
        rut: documento.rut,
        digito: documento.digito,
        swExtranjeroSinDocumento: 0,
      );
      expect(entrega.toJson()['Rut'], '12345678');
      expect(entrega.toJson()['Digito'], '4');
    }
    expect(separarDocumento('12.345.678-k'), (rut: '12345678', digito: 'K'));
  });

  test('Al editar sin validar Chile conserva cuerpo y DV separados', () {
    final provider = EditWorkerProvider();
    provider.cargardatosiniciales(
      ListadoEntregaResponse(
        rut: '12345678',
        digito: '4',
        nombre: 'Trabajador',
        swExtranjeroSinDocumento: 1,
      ),
    );
    expect(provider.validarut, isFalse);
    expect(provider.controllerrut.text, '12345678-4');
    expect(separarDocumento(provider.controllerrut.text), (
      rut: '12345678',
      digito: '4',
    ));
  });

  test('Rut para guardar solo acepta entre uno y ocho digitos ASCII', () {
    for (final rut in ['1', '12345678', '00001234']) {
      expect(esRutParaGuardar(rut), isTrue);
      expect(() => asegurarRutParaGuardar(rut), returnsNormally);
    }
    for (final rut in [
      null,
      '',
      '123456789',
      '1234567K',
      '12.345.678',
      '12345678-5',
      ' 123',
      '123 ',
      '1234567\n',
      '123\u0000',
      '١٢٣٤٥٦٧٨',
      '１２３４５６７８',
    ]) {
      expect(esRutParaGuardar(rut), isFalse, reason: '$rut');
      expect(() => asegurarRutParaGuardar(rut), throwsFormatException);
    }
  });

  test('No recorta ni limpia documentos invalidos para poder guardarlos', () {
    for (final rut in [
      '123456789-0',
      '123456789012-3',
      '123.456.789.012-k',
      '1234567A-4',
      '12.34.5678-4',
      '12345678--4',
    ]) {
      expect(() => separarDocumento(rut), throwsFormatException, reason: rut);
    }
  });

  test(
    'Los proveedores rechazan Rut invalido antes de insertar o actualizar',
    () async {
      final alta = AddTrabajadorContratistaProvider();
      final edicion = EditWorkerProvider();
      for (final rut in ['123456789', '1234567K', '12.345.678']) {
        await expectLater(
          alta.insertentry(Entrega(nombre: 'Trabajador', rut: rut)),
          throwsFormatException,
        );
        await expectLater(
          alta.insertnewtrabajadorcontratista(
            Trabajador(nombre: 'Trabajador', qr: 'Q1', rut: rut),
          ),
          throwsFormatException,
        );
        await expectLater(
          edicion.updateworkerentry(
            rut,
            'Trabajador',
            ListadoEntregaResponse(),
            '5',
          ),
          throwsFormatException,
        );
      }
    },
  );

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
                  (value) => validarDocumento(value, validarRutChile: validar),
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

  testWidgets('Sin modulo acepta ocho digitos y DV, pero rechaza incompletos', (
    tester,
  ) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showField(tester, controller, validar: false, formKey: formKey);
    expect(find.byType(TextFormField), findsOneWidget);
    for (final input in [
      '123',
      '12345678',
      '1234567-4',
      'PE-AB123456789',
      '123456789012-3',
    ]) {
      await tester.enterText(find.byType(TextFormField), input);
      await tester.pump();
      expect(formKey.currentState!.validate(), isFalse);
    }
    for (final input in ['12345678-4', '12345678-K']) {
      await tester.enterText(find.byType(TextFormField), input);
      await tester.pump();
      expect(formKey.currentState!.validate(), isTrue);
      expect(controller.text, input);
    }
  });

  testWidgets(
    'Desactivar elimina el error y conserva el documento al alternar',
    (tester) async {
      final controller = TextEditingController(text: '12345678-4');
      final formKey = GlobalKey<FormState>();
      await showField(tester, controller, formKey: formKey);
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      await showField(tester, controller, validar: false, formKey: formKey);
      expect(formKey.currentState!.validate(), isTrue);
      expect(find.text('Debe ingresar un rut valido'), findsNothing);
      await tester.enterText(find.byType(TextFormField), '12345678-K');
      await showField(tester, controller, formKey: formKey);
      expect(formKey.currentState!.validate(), isFalse);
      await showField(tester, controller, validar: false, formKey: formKey);
      expect(controller.text, '12345678-K');
      expect(formKey.currentState!.validate(), isTrue);
    },
  );
}

class _RecordingDatabase extends Fake implements Database {
  Map<String, Object?>? saved;

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    saved = Map.of(values);
    return 1;
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    saved = Map.of(values);
    return 1;
  }
}

class _AddProviderWithDatabase extends AddTrabajadorContratistaProvider {
  _AddProviderWithDatabase(this.db);
  final Database db;

  @override
  Future<Database> get database async => db;
}

class _EditProviderWithDatabase extends EditWorkerProvider {
  _EditProviderWithDatabase(this.db);
  final Database db;

  @override
  Future<Database> get database async => db;
}
