import 'dart:convert';

TrabajadorContratistaResponse trabajadorcontratistaFromJson(String str)=>TrabajadorContratistaResponse.fromJson(json.decode(str));



String trabajadorcontratistaToJson(TrabajadorContratistaResponse data)=>json.encode(data.toJson());

class TrabajadorContratistaResponse {
    String status;
    int code;
    List<Trabajador> trabajador;

    TrabajadorContratistaResponse({
        required this.status,
        required this.code,
        required this.trabajador,
    });

    

    factory TrabajadorContratistaResponse.fromJson(Map<String, dynamic> json) => TrabajadorContratistaResponse(
        status: json["status"],
        code: json["code"],
        trabajador: List<Trabajador>.from(json["trabajador"].map((x) => Trabajador.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "code": code,
        "trabajador": List<dynamic>.from(trabajador.map((x) => x.toJson())),
    };
}

class Trabajador {
    String? idempresa;
    String? rut;
    String? digito;
    String nombre;
    String qr;
    String? fecha;
    String? idtrabxcontratista;


    Trabajador({
         this.idempresa,
         this.rut,
         this.digito,
        required this.nombre,
        required this.qr,
        this.fecha,
         this.idtrabxcontratista
    });

    

    factory Trabajador.fromJson(Map<String, dynamic> json) => Trabajador(
        idempresa: json['IdEmpresa'],
        rut: json["Rut"],
        digito: json["Digito"],
        nombre: json["Nombre"],
        qr:json['Qr'],
        idtrabxcontratista: json['IdTrabXContratista']
    );

    Map<String, dynamic> toJson() => {
        "IdEmpresa":idempresa,
        "Rut": rut,
        "Digito": digito,
        "Nombre": nombre,
        "Qr":qr,
        'Fecha':fecha,
        "IdTrabXContratista":idtrabxcontratista
    };
}
