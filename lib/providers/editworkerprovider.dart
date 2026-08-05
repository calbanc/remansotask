import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sqflite/sqflite.dart';

import '../page/mrz/chile_mrz_parser.dart';
import '../response/listadoentrega_response.dart';

class EditWorkerProvider extends ChangeNotifier {
  final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  String _path='';
  String get path => _path;
  set path(String value) {
    _path = value;
    notifyListeners();
  }

  GlobalKey<FormState> formdetailkey = GlobalKey<FormState>();
  TextEditingController controllerrut = TextEditingController();
  TextEditingController controllername = TextEditingController();

  String? _nombre;
  String? get nombre => _nombre;
  set nombre(value) {
    _nombre = value;
    notifyListeners();
  }

  String? _rut;
  String? get rut => _rut;
  set rut(value) {
    _rut = value;
    notifyListeners();
  }

  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'VerfrutContratista.db');

    return await openDatabase(
      path,
      version: 1,
      onUpgrade: (Database db, int olverion, int newverion) async {},
      onOpen: (db) => {},
    );
  }

  bool _isloading = false;

  bool get isloading => _isloading;
  set isloading(value) {
    _isloading = value;
    notifyListeners();
  }

  bool _validarut = false;

  bool get validarut => _validarut;
  set validarut(value) {
    _validarut = value;
    notifyListeners();
  }

  bool isValidateForm() {
    return formdetailkey.currentState?.validate() ?? false;
  }

  Future<int> updateworkerentry(
      String rut, String nombre, ListadoEntregaResponse trabajador,String dv) async {
    final db = await database;
    final now = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.now());
    final res = await db.rawUpdate('''
      UPDATE ENTREGAS SET Rut='$rut' , Nombre='$nombre',Digito='$dv' WHERE Qr ='${trabajador.qr}' and Fecha='$now'
    ''');
    return res;
  }
  Future<void>procesardatos(String path) async{
    final input = InputImage.fromFilePath(path);
    final result = await recognizer.processImage(input);
    final text = result.text;
    final parsed = ChileMrzParser.parseFromOcr(text);
    controllername.text='${parsed!.nombresCompletos} ${parsed!.apellidoPaterno} ${parsed.apellidoMaterno!}';

    controllerrut.text='${parsed.rutDigits}-${parsed.dv}';
    notifyListeners();
  }

  void cargardatosiniciales(ListadoEntregaResponse response){
    String dv=response.digito??'';
    if(dv.isNotEmpty){
      String rut=response.rut!;
       if(response.rut!.contains('-',1)) rut=response.rut!.substring(0, response.rut!.indexOf('-'));
      controllerrut.text='${rut}-${response.digito}';
    }else{
      controllerrut.text=response.rut!;
    }
    controllername.text=response.nombre!;
    notifyListeners();
  }
}
