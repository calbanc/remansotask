import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:verfwork/response/CartillaQrResponse.dart';
import 'package:http/http.dart' as http;

import '../const/env.dart';

class dataServerProvider extends ChangeNotifier {


  Future<http.Response>getentregasbycartilla(Cartillaqr qr)async{
    final Map<String, dynamic> data = {
      'IdEmpresa': qr.idEmpresa,
      'IdCartilla': qr.idAndroidCartilla,
      "Fecha": qr.fechainicio,

    };
    String parametros = json.encode(data);
    var url = Uri.parse(Env.baseUrl + '/androidcartilladetalle/getentregasbycartilla');
    Map<String, String> header = new Map();
    header["content-type"] = "application/x-www-form-urlencoded";
    final response = await http.post(url, body: {"json": parametros});

    return response;


  }

}