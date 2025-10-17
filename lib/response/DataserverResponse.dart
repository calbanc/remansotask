import 'dart:convert';

DataserverResponse dataserverResponseFromMap(String str) => DataserverResponse.fromMap(json.decode(str));

String dataserverResponseToMap(DataserverResponse data) => json.encode(data.toMap());

class DataserverResponse {
  String? status;
  int? code;
  String? message;
  List<Entregas>? entregas;

  DataserverResponse({
    this.status,
    this.code,
    this.message,
    this.entregas,
  });

  factory DataserverResponse.fromMap(Map<String, dynamic> json) => DataserverResponse(
    status: json["status"],
    code: json["code"],
    message: json["message"],
    entregas: json["entregas"] == null ? [] : List<Entregas>.from(json["entregas"]!.map((x) => Entregas.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "status": status,
    "code": code,
    "message": message,
    "entregas": entregas == null ? [] : List<dynamic>.from(entregas!.map((x) => x.toMap())),
  };
}

class Entregas {
  String? idAndroidCartilla;
  String? idEmpresa;
  String? idContratista;
  String? idZona;
  String? unidadProducida;
  DateTime? fecha;
  String? qr;
  String? nombre;
  String? rut;
  String? dv;
  String? idTrabajadorxContratista;
  String? fechasys;

  Entregas({
    this.idAndroidCartilla,
    this.idEmpresa,
    this.idContratista,
    this.idZona,
    this.unidadProducida,
    this.fecha,
    this.qr,
    this.nombre,
    this.rut,
    this.dv,
    this.idTrabajadorxContratista,
    this.fechasys,
  });

  factory Entregas.fromMap(Map<String, dynamic> json) => Entregas(
    idAndroidCartilla: json["IdAndroidCartilla"],
    idEmpresa: json["IdEmpresa"],
    idContratista: json["IdContratista"],
    idZona: json["IdZona"],
    unidadProducida: json["UnidadProducida"],
    fecha: json["Fecha"] == null ? null : DateTime.parse(json["Fecha"]),
    qr: json["Qr"],
    nombre: json["Nombre"],
    rut: json["Rut"],
    dv: json["Dv"],
    idTrabajadorxContratista: json["IdTrabajadorxContratista"],
    fechasys: json["FECHASYS"],
  );

  Map<String, dynamic> toMap() => {
    "IdAndroidCartilla": idAndroidCartilla,
    "IdEmpresa": idEmpresa,
    "IdContratista": idContratista,
    "IdZona": idZona,
    "UnidadProducida": unidadProducida,
    "Fecha": "${fecha!.year.toString().padLeft(4, '0')}-${fecha!.month.toString().padLeft(2, '0')}-${fecha!.day.toString().padLeft(2, '0')}",
    "Qr": qr,
    "Nombre": nombre,
    "Rut": rut,
    "Dv": dv,
    "IdTrabajadorxContratista": idTrabajadorxContratista,
    "FECHASYS": fechasys,
  };
}
