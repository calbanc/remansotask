import 'dart:convert';

class EnvaseResponse {
  String? status;
  int? code;
  List<Envase>? envase;
  String? message;

  EnvaseResponse({
    this.status,
    this.code,
    this.envase,
    this.message,
  });

  factory EnvaseResponse.fromJson(String str) => EnvaseResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory EnvaseResponse.fromMap(Map<String, dynamic> json) => EnvaseResponse(
    status: json["status"],
    code: json["code"],
    envase: json["data"] == null ? [] : List<Envase>.from(json["data"]!.map((x) => Envase.fromMap(x))),
    message: json["message"],
  );

  Map<String, dynamic> toMap() => {
    "status": status,
    "code": code,
    "data": envase == null ? [] : List<dynamic>.from(envase!.map((x) => x.toMap())),
  };
}

class Envase {
  String? codEnv;
  String? codTem;
  String? codEmp;
  String? nomEnv;
  String? arrEnv;
  String? marEnv;
  String? pesoNeto;
  String? usoBins;
  String? largo;
  String? ancho;
  String? alto;
  String? tipoEnv;
  String? swBins;


  Envase({
    this.codEnv,
    this.codTem,
    this.codEmp,
    this.nomEnv,
    this.arrEnv,
    this.marEnv,
    this.pesoNeto,
    this.usoBins,
    this.largo,
    this.ancho,
    this.alto,
    this.tipoEnv,
    this.swBins,
  });

  factory Envase.fromJson(String str) => Envase.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Envase.fromMap(Map<String, dynamic> json) => Envase(
    codEnv: json["COD_ENV"],
    codTem: json["COD_TEM"],
    codEmp: json["COD_EMP"],
    nomEnv: json["NOM_ENV"],

    arrEnv: json["ARR_ENV"] ?? '',
    marEnv: json["MAR_ENV"] ?? '',
    pesoNeto: json["PESO_NETO"] ?? '',
    usoBins: json["USO_BINS"] ?? '',
    largo: json["LARGO"] ?? '',
    ancho: json["ANCHO"] ?? '',
    alto: json["ALTO"] ?? '',
    tipoEnv: json["TIPO_ENV"] ?? '',
    swBins: json["SW_BINS"] ?? '',
  );

  Map<String, dynamic> toMap() => {
    "COD_ENV": codEnv,
    "COD_TEM": codTem,
    "COD_EMP": codEmp,
    "NOM_ENV": nomEnv,

    /*"ARR_ENV": arrEnv,
    "MAR_ENV": marEnv,
    "PESO_NETO": pesoNeto,
    "USO_BINS": usoBins,
    "LARGO": largo,
    "ANCHO": ancho,
    "ALTO": alto,
    "TIPO_ENV": tipoEnv,
    "SW_BINS": swBins,*/
  };
}
