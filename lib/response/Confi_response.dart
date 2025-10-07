import 'dart:convert';

class ConfigResponse{
    String FechaSincronizacion;
    String TiempoDelay;
    
    ConfigResponse({
        required this.FechaSincronizacion,
        required this.TiempoDelay,
       
    });

    factory ConfigResponse.fromJson(String str) => ConfigResponse.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ConfigResponse.fromMap(Map<String, dynamic> json) => ConfigResponse(
        FechaSincronizacion: json["FechaSincronizacion"],
        TiempoDelay: json["TiempoDelay"],
        
    );

    Map<String, dynamic> toMap() => {
        "FechaSincronizacion": FechaSincronizacion,
        "TiempoDelay": TiempoDelay,
    
    };
}
