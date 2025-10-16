// To parse this JSON data, do
//
//     final cartillaQrResponse = cartillaQrResponseFromMap(jsonString);

import 'dart:convert';

CartillaQrResponse cartillaQrResponseFromMap(String str) =>
    CartillaQrResponse.fromMap(json.decode(str));

String cartillaQrResponseToMap(CartillaQrResponse data) =>
    json.encode(data.toMap());

class CartillaQrResponse {
  String? status;
  int? code;
  String? message;
  List<Cartillaqr>? cartillaqr;

  CartillaQrResponse({
    this.status,
    this.code,
    this.message,
    this.cartillaqr,
  });

  factory CartillaQrResponse.fromMap(Map<String, dynamic> json) =>
      CartillaQrResponse(
        status: json["status"],
        code: json["code"],
        message: json["message"],
        cartillaqr: json["cartillaqr"] == null
            ? []
            : List<Cartillaqr>.from(
                json["cartillaqr"]!.map((x) => Cartillaqr.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "code": code,
        "message": message,
        "cartillaqr": cartillaqr == null
            ? []
            : List<dynamic>.from(cartillaqr!.map((x) => x.toMap())),
      };
}

class Cartillaqr {
  String? idAndroidCartilla;
  String? idEmpresa;
  String? idFamilia;
  String? idActividad;
  String? idContratista;
  String? idZona;
  String? idEspecie;
  String? idVariedad;
  String? idCuartel;
  String? horainicio;
  String? horatermino;
  String? fechainicio;
  String? fechatermino;
  String? idusuario;
  String? swUnoaUno;
  String? swCartillaCierre;
  String? fechasys;
  String? codEnv;
  String? maxEnv;
  String? nomEspecie;
  String? nomVariedad;
  String? nomZon;
  String? nomCuartel;
  String? nomContratista;
  String? nomFamilia;
  String? nomActividad;
  String? nomEnv;
  int? cantBins;
  String? SwSincronizado;

  Cartillaqr({
    this.idAndroidCartilla,
    this.idEmpresa,
    this.idFamilia,
    this.idActividad,
    this.idContratista,
    this.idZona,
    this.idEspecie,
    this.idVariedad,
    this.idCuartel,
    this.horainicio,
    this.horatermino,
    this.fechainicio,
    this.fechatermino,
    this.idusuario,
    this.swUnoaUno,
    this.swCartillaCierre,
    this.fechasys,
    this.codEnv,
    this.maxEnv,
    this.nomEspecie,
    this.nomVariedad,
    this.nomZon,
    this.nomCuartel,
    this.nomContratista,
    this.nomFamilia,
    this.nomActividad,
    this.nomEnv,
    this.cantBins,
    this.SwSincronizado,
  });

  factory Cartillaqr.fromMap(Map<String, dynamic> json) => Cartillaqr(
      idAndroidCartilla: json["IdAndroidCartilla"],
      idEmpresa: json["IdEmpresa"],
      idFamilia: json["IdFamilia"],
      idActividad: json["IdActividad"],
      idContratista: json["IdContratista"],
      idZona: json["IdZona"],
      idEspecie: json["IdEspecie"],
      idVariedad: json["IdVariedad"],
      idCuartel: json["IdCuartel"],
      horainicio: json["HORAINICIO"],
      horatermino: json["HORATERMINO"],
      fechainicio: json["FECHAINICIO"],
      fechatermino: json["FECHATERMINO"],
      idusuario: json["IDUSUARIO"],
      swUnoaUno: json["SwUnoaUno"],
      swCartillaCierre: json["SwCartillaCierre"],
      fechasys: json["FECHASYS"],
      codEnv: json["COD_ENV"],
      nomEspecie: json["NomEspecie"],
      nomVariedad: json["NomVariedad"],
      nomZon: json["NomZon"],
      nomCuartel: json["NomCuartel"],
      nomContratista: json["NomContratista"],
      nomFamilia: json["NomFamilia"],
      nomActividad: json["NomActividad"],
      nomEnv: json["NOM_ENV"],
      cantBins: json["CantMaxEnv"]=='null' || json["CantMaxEnv"]==null ? 0: int.parse(json["CantMaxEnv"]),
      SwSincronizado: json["SwSincronizado"]);

  Map<String, dynamic> toMap() => {
        "IdAndroidCartilla": idAndroidCartilla,
        "IdEmpresa": idEmpresa,
        "IdFamilia": idFamilia,
        "IdActividad": idActividad,
        "IdContratista": idContratista,
        "IdZona": idZona,
        "IdEspecie": idEspecie,
        "IdVariedad": idVariedad,
        "IdCuartel": idCuartel,
        "HORAINICIO": horainicio,
        "HORATERMINO": horatermino,
        "FECHAINICIO": fechainicio,
        "FECHATERMINO": fechatermino,
        "IDUSUARIO": idusuario,
        "SwUnoaUno": swUnoaUno,
        "SwCartillaCierre": swCartillaCierre,
        "FECHASYS": fechasys,
        "COD_ENV": codEnv,
        "CantMaxEnv":maxEnv,
        "NomEspecie": nomEspecie,
        "NomVariedad": nomVariedad,
        "NomZon": nomZon,
        "NomCuartel": nomCuartel,
        "NomContratista": nomContratista,
        "NomFamilia": nomFamilia,
        "NomActividad": nomActividad,
        "SwSincronizado": SwSincronizado
      };
}


class Contador_bins{
  String? idAndroidCartilla;
  int? cant;
  Contador_bins({
    this.idAndroidCartilla,
    this.cant,

  });
  factory Contador_bins.fromMap(Map<String, dynamic> json) => Contador_bins(
      idAndroidCartilla: json["IdAndroidCartilla"],
      cant: json["CANT"],
     );
  Map<String, dynamic> toMap() => {
    "IdAndroidCartilla": idAndroidCartilla,
    "CANT": cant,
  };
}
