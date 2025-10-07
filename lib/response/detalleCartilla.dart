import 'dart:convert';

class QrCartilla {
  String idAndroidCartilla;
  String idCuartel;
  String? horainicio;
  String? horatermino;
  String fechainicio;
  String fechatermino;
  String swUnoaUno;
  String swCartillaCierre;
  String sw_contenedora;
  String? cod_env;
  String nomEspecie;
  String nomVariedad;
  String nomCuartel;
  String nomContratista;
  String nomFamilia;
  String nomActividad;


  QrCartilla({
    required this.idAndroidCartilla,
    required this.idCuartel,
    this.horainicio,
    this.horatermino,
    required this.fechainicio,
    required this.fechatermino,
    required this.swUnoaUno,
    required this.swCartillaCierre,
    required this.sw_contenedora,
    this.cod_env,
    required this.nomEspecie,
    required this.nomVariedad,
    required this.nomCuartel,
    required this.nomContratista,
    required this.nomFamilia,
    required this.nomActividad,

  });

  factory QrCartilla.fromJson(String str) => QrCartilla.fromJson(json.decode(str));

  String toJson() => json.encode(toMap());

  factory QrCartilla.fromMap(Map<String, dynamic> json) => QrCartilla(
      idAndroidCartilla: json["IdAndroidCartilla"],
      idCuartel: json["IdCuartel"],
      horainicio: json["HORAINICIO"],
      horatermino: json["HORATERMINO"],
      fechainicio: json["FECHAINICIO"],
      fechatermino: json["FECHATERMINO"],
      swUnoaUno: json["SwUnoaUno"],
      swCartillaCierre: json["SwCartillaCierre"],
      nomEspecie: json["NomEspecie"],
      nomVariedad: json["NomVariedad"],
      nomCuartel: json["NomCuartel"],
      nomContratista: json["NomContratista"],
      nomFamilia: json["NomFamilia"],
      nomActividad: json["NomActividad"],
      sw_contenedora: json["SW_CONTENEDORA"],
      cod_env: json['COD_ENV']
  );

  Map<String, dynamic> toMap() => {
    "IdAndroidCartilla": idAndroidCartilla,
    "IdCuartel": idCuartel,
    "HORAINICIO": horainicio,
    "HORATERMINO": horatermino,
    "FECHAINICIO": fechainicio,
    "FECHATERMINO": fechatermino,
    "SwUnoaUno": swUnoaUno,
    "SwCartillaCierre": swCartillaCierre,
    "SW_CONTENEDORA":sw_contenedora,
    "COD_ENV":cod_env,
    "NomEspecie": nomEspecie,
    "NomVariedad": nomVariedad,
    "NomCuartel": nomCuartel,
    "NomContratista": nomContratista,
    "NomFamilia": nomFamilia,
    "NomActividad": nomActividad,

  };
}

