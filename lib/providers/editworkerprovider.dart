import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sqflite/sqflite.dart';

class EditWorkerProvider extends ChangeNotifier {
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
      String rut, String nombre, int identrega) async {
    final db = await database;

    final res = await db.rawUpdate('''
      UPDATE ENTREGAS SET Rut='$rut' , Nombre='$nombre' WHERE IdEntrega='$identrega'
    ''');
    return res;
  }
}
