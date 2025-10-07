import 'package:verfwork/response/qrcartilla_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import 'db_provider.dart';

class QrProvider extends ChangeNotifier {
  GlobalKey<FormState> formkey = new GlobalKey<FormState>();

  List<QrCartillaResponse> qrdisponibles = [];

  Future<List<QrCartillaResponse>> getqravailable() async {
    List<QrCartillaResponse> lista =
        DBProvider.db.getcartillasdisponibles() as List<QrCartillaResponse>;

    return lista;
  }
}
