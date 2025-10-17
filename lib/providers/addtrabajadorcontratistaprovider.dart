import 'dart:io';
import 'dart:convert';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:verfwork/const/env.dart';
import 'package:verfwork/response/response.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

import '../page/mrz/chile_mrz_parser.dart';

class AddTrabajadorContratistaProvider extends ChangeNotifier {
  GlobalKey<FormState> formaddkey = GlobalKey<FormState>();
  TextEditingController controlladornombre = TextEditingController();

  TextEditingController controlladoridentrega = TextEditingController();
  TextEditingController controlladorcartilla = TextEditingController();

  TextEditingController controlladorcantidad = TextEditingController();
  TextEditingController controlladorlabor = TextEditingController();
  TextEditingController controlladorqr = TextEditingController();
  TextEditingController controlladorrut = TextEditingController();
  TextEditingController controlladordigito = TextEditingController();
  TextEditingController controlladoridempresa = TextEditingController();
  TextEditingController controlladorcodigotrabajador = TextEditingController();

  String Rut = '';
  String Digito = '';
  String Nombre = '';
  String Qr = '';
  String IdEmpresa = '';
  String idtrabxcontr = '';

  static Database? _database;
  int cantidad = 0;
  int _cantidadentregas = 0;
  int get CantidadEntregas => _cantidadentregas;

  bool _validarut = false;
  bool get validarut => _validarut;

  bool isValidateForm() {
    return formaddkey.currentState?.validate() ?? false;
  }


  String _path='';
  String get path => _path;
  set path(String value) {
    _path = value;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set validarut(bool value) {
    _validarut = value;
    notifyListeners();
  }

  set setCantidadEntregas(int entrega) {
    _cantidadentregas = entrega;
    notifyListeners();
  }

  Future<Database> get database async => _database ??= await initDB();
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'VerfrutContratista.db');

    return await openDatabase(
      path,
      version: Env.dbversion,
      onUpgrade: (Database db, int olverion, int newverion) async {},
      onOpen: (db) => {},
    );
  }

  Future<int> insertnewtrabajadorcontratista(Trabajador trabajador) async {
    final db = await database;
    String rut = trabajador.rut!;
    String qr = trabajador.qr;
    String fecha = trabajador.fecha!;
    final res1 = await db.query(
      'TRABAJADORESXCONTRATISTA',
      where: 'Rut=?',
      whereArgs: [rut],
    );
    List<Trabajador> listado = res1.map((e) => Trabajador.fromJson(e)).toList();
    if (listado.length > 0) {
      final res2 = await db.rawUpdate(
        '''UPDATE TRABAJADORESXCONTRATISTA SET Qr= '$qr' , Fecha = '$fecha' WHERE Rut='$rut' ''',
      );
      final res3 = await db.query(
        'TRABAJADORESXCONTRATISTA',
        where: 'Rut<>? AND Qr=? ',
        whereArgs: [rut, qr],
      );
      List<Trabajador> listado1 =
          res3.map((e) => Trabajador.fromJson(e)).toList();
      if (listado1.length > 0) {
        String newqr = listado1[0].rut!;
        final res2 = await db.rawUpdate(
          '''UPDATE TRABAJADORESXCONTRATISTA SET Qr= '$newqr' WHERE Rut='$newqr' ''',
        );
      }

      return res2;
    } else {
      final res = await db.insert(
        'TRABAJADORESXCONTRATISTA',
        trabajador.toJson(),
      );
      return res;
    }
  }

  Future<int> insertentry(Entrega entry) async {
    final db = await database;
    final res = await db.insert('ENTREGAS', entry.toJson());
    return res;
  }

  Future<List<QrCartillaResponse>> getcartillasdisponibles() async {
    final now = DateTime.now();
    DateTime fecha = new DateTime(now.year, now.month, now.day);

    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT * FROM CARTILLAS WHERE FechaInicio='$fecha' and HoraTermino is null 
      ''');

    return List.generate(
      res.length,
      (index) => QrCartillaResponse(
        idcartilla: res[index]['IdAndroidCartilla'],
        cuartel: res[index]['Cuartel'],
        labor: res[index]['Labor'],
        fechainicio: res[index]['FechaInicio'],
        fechatermino: res[index]['FechaTermino'],
        swunoauno: res[index]['SwUnoaUno'],
        swSincronizado: res[index]['SwSincronizado'],
        contratista: res[index]['Contratista'],
      ),
    );
  }

  Future<List<QrCartillaResponse>> getcartillabyid(String IdCartilla) async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      	SELECT * FROM CARTILLAS WHERE IdAndroidCartilla='$IdCartilla'
      ''');
    notifyListeners();
    return List.generate(
      res.length,
      (index) => QrCartillaResponse(
        idcartilla: res[index]['IdAndroidCartilla'],
        cuartel: res[index]['Cuartel'],
        labor: res[index]['Labor'],
        fechainicio: res[index]['FechaInicio'],
        fechatermino: res[index]['FechaTermino'],
        swunoauno: res[index]['SwUnoaUno'],
        swSincronizado: res[index]['SwSincronizado'],
        contratista: res[index]['Contratista'],
      ),
    );
  }

  Future<List<QrCartillaResponse>> getfechainiciobyidcartilla(
    String idcartilla,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT * FROM CARTILLAS WHERE IdAndroidCartilla='$idcartilla' and HoraInicio is null
      ''');

    return List.generate(
      res.length,
      (index) => QrCartillaResponse(
        idcartilla: res[index]['IdAndroidCartilla'],
        cuartel: res[index]['Cuartel'],
        labor: res[index]['Labor'],
        fechainicio: res[index]['FechaInicio'],
        fechatermino: res[index]['FechaTermino'],
        swunoauno: res[index]['SwUnoaUno'],
        swSincronizado: res[index]['SwSincronizado'],
        contratista: res[index]['Contratista'],
      ),
    );
  }

  Future<int> updatehorainicio(String idCartilla) async {
    final hora = DateTime.now();
    final db = await database;
    final res = await db.rawUpdate('''
      UPDATE CARTILLAS SET HoraInicio= '$hora' , SwSincronizado='0' WHERE IdAndroidCartilla='$idCartilla'
    ''');
    return res;
  }

  Future<List<Trabajador>?> gettrabajadorbyrut(String rut) async {
    final db = await database;
    final res = await db.rawQuery(
      ''' SELECT * FROM TRABAJADORESXCONTRATISTA WHERE Rut='$rut' ''',
    );
    return res.isNotEmpty
        ? res.map((e) => Trabajador.fromJson(e)).toList()
        : null;
  }

  Future<List<Trabajador>> getlasttrabajadorbyqr(String qr) async {
    final today = DateTime.now();
    final date = DateFormat('dd/MM/yyyy').format(today);
    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
     SELECT * 
      FROM ENTREGAS
      WHERE QR='$qr'
      ORDER BY Fecha DESC
      LIMIT 1

      ''');
    return List.generate(
      res.length,
      (index) => Trabajador(
        idempresa: res[index]['IdEmpresa'],
        rut: res[index]['Rut'],
        digito: res[index]['Digito'],
        nombre: res[index]['Nombre'],
        qr: res[index]['Qr'],
        idtrabxcontratista: res[index]['IdTrabXContratista'],
      ),
    );

    /*   final db=await database;
    final res=await db.query('TRABAJADORESXCONTRATISTA',distinct: true,where: 'Qr=?',whereArgs: [qr] );
    return res.isNotEmpty ?
          res.map((e) => Trabajador.fromJson(e)).toList()
          :null;*/
  }

  Future<void>procesardatos(String path) async{
    final input = InputImage.fromFilePath(path);
    final result = await recognizer.processImage(input);
    final text = result.text;
    final parsed = ChileMrzParser.parseFromOcr(text);
    controlladornombre.text='${parsed!.nombresCompletos} ${parsed!.apellidoPaterno} ${parsed.apellidoMaterno!}';
    controlladorrut.text=' ${parsed.rutDigits}-${parsed.dv}';
  }
}
