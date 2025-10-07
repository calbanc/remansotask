import 'dart:convert';

class QrCartillaResponse{
    String idcartilla;
    String cuartel;
    String labor;
    String fechainicio;
    String fechatermino;
    String swunoauno;
    String? horainicio;
    String? horatermino;
    String  swSincronizado;
    String contratista;
    QrCartillaResponse({
        required this.idcartilla,
        required this.cuartel,
        required this.labor,
        required this.fechainicio,
        required this.fechatermino,
        required this.swunoauno,
        this.horainicio,
        this.horatermino,
        required this.swSincronizado,
        required this.contratista
    });

    factory QrCartillaResponse.fromJson(String str) => QrCartillaResponse.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory QrCartillaResponse.fromMap(Map<String, dynamic> json) => QrCartillaResponse(
        idcartilla: json["idcartilla"],
        cuartel: json["cuartel"],
        labor: json["labor"],
        fechainicio: json["fechainicio"],
        fechatermino: json["fechatermino"],
        swunoauno: json["swunoauno"],
        horainicio: json["HoraInicio"],
        horatermino: json["HoraTermino"],
        swSincronizado: json["SwSincronizado"],
        contratista: json["Contratista"]
    );

    Map<String, dynamic> toMap() => {
        "IdCartilla": idcartilla,
        "Cuartel": cuartel,
        "Labor": labor,
        "Fechainicio": fechainicio,
        "Fechatermino": fechatermino,
        "SwUnoaUno":swunoauno,
        "HoraInicio":horainicio,
        "HoraTermino":horatermino,
        "SwSincronizado":swSincronizado,
        "Contratista":contratista
    };
}
