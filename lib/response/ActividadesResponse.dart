import 'dart:convert';

class ActividadesResponse {
  ActividadesResponse({
    required this.status,
    required this.code,
    required this.actividades,
  });

  String status;
  int code;

  List<Actividade> actividades;

  factory ActividadesResponse.fromJson(String str) =>
      ActividadesResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ActividadesResponse.fromMap(Map<String, dynamic> json) =>
      ActividadesResponse(
        status: json["status"],
        code: json["code"],
        actividades: List<Actividade>.from(
            json["actividades"].map((x) => Actividade.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "code": code,
        "actividades": List<dynamic>.from(actividades.map((x) => x.toJson())),
      };
}

class Actividade {
  String? idEmpresa;
  String? idFamilia;
  String? noombreFamilia;
  String? idActividad;
  String? nombre;
  String? unidadMedida;
  String? controldeunidades;
  String? swcosecha;

  Actividade(
      {this.idEmpresa,
      this.idFamilia,
      this.noombreFamilia,
      this.idActividad,
      this.nombre,
      this.unidadMedida,
      this.controldeunidades,
      this.swcosecha});

  factory Actividade.fromJson(String str) =>
      Actividade.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Actividade.fromMap(Map<String, dynamic> json) => Actividade(
      idEmpresa: json["IdEmpresa"],
      idFamilia: json["IdFamilia"],
      noombreFamilia: json["NOOMBRE_FAMILIA"],
      idActividad: json["IdActividad"],
      nombre: json["Nombre"],
      unidadMedida: json["UnidadMedida"],
      controldeunidades: json["ControldeUnidades"],
      swcosecha: json['SwCosecha']);

  Map<String, dynamic> toMap() => {
        "IdEmpresa": idEmpresa,
        "IdFamilia": idFamilia,
        "NOOMBRE_FAMILIA": noombreFamilia,
        "IdActividad": idActividad,
        "Nombre": nombre,
        "UnidadMedida": unidadMedida,
        "ControldeUnidades": controldeunidades,
        "SwCosecha": swcosecha
      };
}
