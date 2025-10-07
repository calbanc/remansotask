import 'dart:convert';

class CuartelResponse {
  CuartelResponse({
    required this.status,
    required this.code,
    required this.cuartel,
  });

  String status;
  int code;
  List<Cuarteles> cuartel;

  factory CuartelResponse.fromJson(String str) =>
      CuartelResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CuartelResponse.fromMap(Map<String, dynamic> json) => CuartelResponse(
        status: json["status"],
        code: json["code"],
        cuartel: List<Cuarteles>.from(
            json["cuartel"].map((x) => Cuarteles.fromJson(x))),
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "code": code,
        "cuartel": List<dynamic>.from(cuartel.map((x) => x.toJson())),
      };
}

class Cuarteles {
  String? idEmpresa;
  String? idCuartel;
  String? nomCuartel;
  String? idZona;
  String? nomZona;
  String? idEspecie;
  String? nomEspecie;
  String? idVariedad;
  String? nomVariedad;

  Cuarteles({
    this.idEmpresa,
    this.idCuartel,
    this.nomCuartel,
    this.idZona,
    this.nomZona,
    this.idEspecie,
    this.nomEspecie,
    this.idVariedad,
    this.nomVariedad,
  });

  factory Cuarteles.fromJson(Map<String, dynamic> json) => Cuarteles(
        idEmpresa: json["IdEmpresa"],
        idCuartel: json["IdCuartel"],
        nomCuartel: json["NomCuartel"],
        idZona: json["IdZona"],
        nomZona: json["NomZona"],
        idEspecie: json["IdEspecie"],
        nomEspecie: json["NomEspecie"],
        idVariedad: json["IdVariedad"],
        nomVariedad: json["NomVariedad"],
      );

  Map<String, dynamic> toJson() => {
        "IdEmpresa": idEmpresa,
        "IdCuartel": idCuartel,
        "NomCuartel": nomCuartel,
        "IdZona": idZona,
        "NomZona": nomZona,
        "IdEspecie": idEspecie,
        "NomEspecie": nomEspecie,
        "IdVariedad": idVariedad,
        "NomVariedad": nomVariedad,
      };
}
