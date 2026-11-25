import 'dart:convert';

ModelInfoTramite modelInfoTramiteFromJson(String str) => ModelInfoTramite.fromJson(json.decode(str));

String modelInfoTramiteToJson(ModelInfoTramite data) => json.encode(data.toJson());

class ModelInfoTramite {
  final bool finalizado;
  final String mensaje;
  final Datos datos;

  ModelInfoTramite({
    required this.finalizado,
    required this.mensaje,
    required this.datos,
  });

  factory ModelInfoTramite.fromJson(Map<String, dynamic> json) => ModelInfoTramite(
    finalizado: json["finalizado"],
    mensaje: json["mensaje"],
    datos: Datos.fromJson(json["datos"]),
  );

  Map<String, dynamic> toJson() => {
    "finalizado": finalizado,
    "mensaje": mensaje,
    "datos": datos.toJson(),
  };
}

class Datos {
  final int id;
  final String tramite;
  final dynamic modalidad;
  final String requisitoInicial;
  final String concepto;
  final String requisitos;
  final String costo;
  final String plazo;
  final String marcoLegal;
  final String procedimiento;
  final String documentoEmitido;

  Datos({
    required this.id,
    required this.tramite,
    this.modalidad,
    required this.requisitoInicial,
    required this.concepto,
    required this.requisitos,
    required this.costo,
    required this.plazo,
    required this.marcoLegal,
    required this.procedimiento,
    required this.documentoEmitido,
  });

  factory Datos.fromJson(Map<String, dynamic> json) => Datos(
    id: json["id"],
    tramite: _checkNullOrEmpty(json["tramite"]),
    modalidad: json["modalidad"] ?? "-",
    requisitoInicial: _checkNullOrEmpty(json["requisitoInicial"]),
    concepto: _checkNullOrEmpty(json["concepto"]),
    requisitos: _checkNullOrEmpty(json["requisitos"]),
    costo: _checkNullOrEmpty(json["costo"]),
    plazo: _checkNullOrEmpty(json["plazo"]),
    marcoLegal: _checkNullOrEmpty(json["marcoLegal"]),
    procedimiento: _checkNullOrEmpty(json["procedimiento"]),
    documentoEmitido: _checkNullOrEmpty(json["documentoEmitido"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "tramite": tramite,
    "modalidad": modalidad,
    "requisitoInicial": requisitoInicial,
    "concepto": concepto,
    "requisitos": requisitos,
    "costo": costo,
    "plazo": plazo,
    "marcoLegal": marcoLegal,
    "procedimiento": procedimiento,
    "documentoEmitido": documentoEmitido,
  };

  // Función auxiliar para verificar si un valor es nulo o vacío y devolver "-"
  static String _checkNullOrEmpty(String? value) {
    return (value == null || value.isEmpty) ? "-" : value;
  }
}