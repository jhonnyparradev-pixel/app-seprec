import 'dart:convert';

ModelTramite modelTramiteFromJson(String str) {
  final jsonData = json.decode(str);
  return ModelTramite.fromJson(jsonData);
}

class ModelTramite {
  ModelTramite({
    required this.finalizado,
    required this.mensaje,
    required this.datos,
  });

  final bool finalizado;
  final String mensaje;
  final Datos? datos; // Nullable

  factory ModelTramite.fromJson(Map<String, dynamic> json) => ModelTramite(
    finalizado: json["finalizado"] ?? false,
    mensaje: json["mensaje"] ?? "-",
    datos: json["datos"] != null ? Datos.fromJson(json["datos"]) : null,
  );
}

class Datos {
  Datos({
    required this.fechaCreacion,
    required this.nombre,
    required this.estado,
    required this.bitacoras,
    this.empresa,
  });

  final String fechaCreacion;
  final Nombre nombre;
  final String? estado; // Nullable
  final List<Bitacora> bitacoras;
  final Empresa? empresa; // Define empresa as nullable

  factory Datos.fromJson(Map<String, dynamic> json) => Datos(
    fechaCreacion: json["fechaCreacion"] ?? "-",
    nombre: Nombre.fromJson(json["nombre"]),
    estado: json["estado"] ?? "-",
    bitacoras: List<Bitacora>.from(
        json["bitacoras"].map((x) => Bitacora.fromJson(x))),
    empresa: json["empresa"] != null ? Empresa.fromJson(json["empresa"]) : null,
  );

  // Acceso seguro a propiedades que puedan ser nulas o vacías.
  String get fechaCreacionSafe => fechaCreacion.isNotEmpty ? fechaCreacion : "-";
  String get estadoSafe => estado ?? "-";
  String get empresaIdSafe => empresa?.id ?? "-";
}

class Bitacora {
  int id;
  String operacion;
  DateTime fecha;
  int fechaMiliSegundos;

  Bitacora({
    required this.id,
    required this.operacion,
    required this.fecha,
    required this.fechaMiliSegundos,
  });

  factory Bitacora.fromJson(Map<String, dynamic> json) => Bitacora(
    id: json["id"] ?? 0,
    operacion: json["operacion"] ?? "-",
    fecha: DateTime.tryParse(json["fecha"] ?? "") ?? DateTime.now(),
    fechaMiliSegundos: json["fechaMiliSegundos"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "operacion": operacion,
    "fecha": fecha.toIso8601String(),
    "fechaMiliSegundos": fechaMiliSegundos,
  };
}

class Empresa {
  String id;
  String matricula;
  String razonSocial;

  Empresa({
    required this.id,
    required this.matricula,
    required this.razonSocial,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) => Empresa(
    id: json["id"] ?? "-",
    matricula: json["matricula"] ?? "-",
    razonSocial: json["razonSocial"] ?? "-",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "matricula": matricula,
    "razonSocial": razonSocial,
  };

  // Acceso seguro a propiedades que puedan ser nulas o vacías.
  String get idSafe => id.isNotEmpty ? id : "-";
  String get matriculaSafe => matricula.isNotEmpty ? matricula : "-";
  String get razonSocialSafe => razonSocial.isNotEmpty ? razonSocial : "-";
}

class Nombre {
  int id;
  String nombre;
  String codigo;

  Nombre({
    required this.id,
    required this.nombre,
    required this.codigo,
  });

  factory Nombre.fromJson(Map<String, dynamic> json) => Nombre(
    id: json["id"] ?? 0,
    nombre: json["nombre"] ?? "-",
    codigo: json["codigo"] ?? "-",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "codigo": codigo,
  };

  // Acceso seguro a propiedades que puedan ser nulas o vacías.
  String get nombreSafe => nombre.isNotEmpty ? nombre : "-";
  String get codigoSafe => codigo.isNotEmpty ? codigo : "-";
}

class Sucursal {
  String descripcion;

  Sucursal({
    required this.descripcion,
  });

  factory Sucursal.fromJson(Map<String, dynamic> json) => Sucursal(
    descripcion: json["descripcion"] ?? "-",
  );

  Map<String, dynamic> toJson() => {
    "descripcion": descripcion,
  };

  // Acceso seguro a propiedades que puedan ser nulas o vacías.
  String get descripcionSafe => descripcion.isNotEmpty ? descripcion : "-";
}