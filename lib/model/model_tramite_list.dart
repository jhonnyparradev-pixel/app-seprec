import 'dart:convert';

ModelTramitelist modelTramitelistFromJson(String str) => ModelTramitelist.fromJson(json.decode(str));

String modelTramitelistToJson(ModelTramitelist data) => json.encode(data.toJson());

class ModelTramitelist {
  bool finalizado;
  String mensaje;
  Datos datos;

  ModelTramitelist({
    required this.finalizado,
    required this.mensaje,
    required this.datos,
  });

  factory ModelTramitelist.fromJson(Map<String, dynamic> json) => ModelTramitelist(
    finalizado: json["finalizado"] ?? false,
    mensaje: json["mensaje"]?.isNotEmpty == true ? json["mensaje"] : "-", // Asigna "-" si mensaje es nulo o vacío
    datos: json["datos"] != null ? Datos.fromJson(json["datos"]) : Datos(total: 0, filas: []), // Maneja datos nulo
  );

  Map<String, dynamic> toJson() => {
    "finalizado": finalizado,
    "mensaje": mensaje,
    "datos": datos.toJson(),
  };
}

class Datos {
  int total;
  List<Fila> filas;

  Datos({
    required this.total,
    required this.filas,
  });

  factory Datos.fromJson(Map<String, dynamic> json) => Datos(
    total: json["total"] ?? 0, // Asigna 0 si total es nulo
    filas: json["filas"] != null
        ? List<Fila>.from(json["filas"].map((x) => Fila.fromJson(x)))
        : [], // Asigna una lista vacía si filas es nulo
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "filas": List<dynamic>.from(filas.map((x) => x.toJson())),
  };
}

class Fila {
  int id;
  String tramite;

  Fila({
    required this.id,
    required this.tramite,
  });

  factory Fila.fromJson(Map<String, dynamic> json) => Fila(
    id: json["id"] ?? 0, // Asigna 0 si id es nulo
    tramite: json["tramite"]?.isNotEmpty == true ? json["tramite"] : "-", // Asigna "-" si tramite es nulo o vacío
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "tramite": tramite,
  };
}