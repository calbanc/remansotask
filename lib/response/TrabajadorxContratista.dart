import 'dart:convert';

TrabajadorxContratista trabajadorxContratistaFromJson(String str) => TrabajadorxContratista.fromJson(json.decode(str));

String trabajadorxContratistaToJson(TrabajadorxContratista data) => json.encode(data.toJson());

class TrabajadorxContratista {
  String? status;
  int? code;
  List<Trabajadorxcontratista>? trabajadorxcontratista;

  TrabajadorxContratista({
    this.status,
    this.code,
    this.trabajadorxcontratista,
  });

  factory TrabajadorxContratista.fromJson(Map<String, dynamic> json) => TrabajadorxContratista(
    status: json["status"],
    code: json["code"],
    trabajadorxcontratista: json["trabajador"] == null ? [] : List<Trabajadorxcontratista>.from(json["trabajador"]!.map((x) => Trabajadorxcontratista.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "code": code,
    "trabajador": trabajadorxcontratista == null ? [] : List<dynamic>.from(trabajadorxcontratista!.map((x) => x.toJson())),
  };
}

class Trabajadorxcontratista {
  String? idEmpresa;
  String? idContratista;
  String? idTrabXContratista;
  String? rut;
  String? digito;
  String? nombre;
  String? activo;
  String? idZona;
  String? idBanco;
  String? indicadorDeposito;
  String? numeroCuentaBancaria;
  String? tipoCuentaBancaria;
  String? sexo;

  Trabajadorxcontratista({
    this.idEmpresa,
    this.idContratista,
    this.idTrabXContratista,
    this.rut,
    this.digito,
    this.nombre,
    this.activo,
    this.idZona,
    this.idBanco,
    this.indicadorDeposito,
    this.numeroCuentaBancaria,
    this.tipoCuentaBancaria,
    this.sexo,
  });

  factory Trabajadorxcontratista.fromJson(Map<String, dynamic> json) => Trabajadorxcontratista(
    idEmpresa: json["IdEmpresa"],
    idContratista: json["IdContratista"],
    idTrabXContratista: json["IdTrabXContratista"],
    rut: json["Rut"],
    digito: json["Digito"],
    nombre: json["Nombre"],
    activo: json["Activo"],
    idZona: json["IdZona"],
    idBanco: json["IdBanco"],
    indicadorDeposito: json["IndicadorDeposito"],
    numeroCuentaBancaria: json["NumeroCuentaBancaria"],
    tipoCuentaBancaria: json["TipoCuentaBancaria"],
    sexo: json["SEXO"],
  );

  Map<String, dynamic> toJson() => {
    "IdEmpresa": idEmpresa,
    "IdContratista": idContratista,
    "IdTrabXContratista": idTrabXContratista,
    "Rut": rut,
    "Digito": digito,
    "Nombre": nombre,
    "Activo": activo,
    "IdZona": idZona,
    "IdBanco": idBanco,
    "IndicadorDeposito": indicadorDeposito,
    "NumeroCuentaBancaria": numeroCuentaBancaria,
    "TipoCuentaBancaria": tipoCuentaBancaria,
    "SEXO": sexo,
  };
}
