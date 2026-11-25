import 'dart:convert';

InformacionEmpresa informacionEmpresaFromJson(String str) => InformacionEmpresa.fromJson(json.decode(str));

String informacionEmpresaToJson(InformacionEmpresa data) => json.encode(data.toJson());

class InformacionEmpresa {
  bool finalizado;
  String mensaje;
  Datos datos;

  InformacionEmpresa({
    required this.finalizado,
    required this.mensaje,
    required this.datos,
  });

  factory InformacionEmpresa.fromJson(Map<String, dynamic> json) => InformacionEmpresa(
    finalizado: json["finalizado"] ?? false,  // Maneja booleano por defecto
    mensaje: json["mensaje"] ?? '-',  // Reemplaza null por '-'
    datos: Datos.fromJson(json["datos"] ?? {}),  // Maneja objeto vacío como predeterminado
  );

  Map<String, dynamic> toJson() => {
    "finalizado": finalizado,
    "mensaje": mensaje,
    "datos": datos.toJson(),
  };
}

class Datos {
  String estado;
  String id;
  String nit;
  String matricula;
  String matriculaAnterior;
  String razonSocial;
  Cod codTipoUnidadEconomica;
  String mesCierreGestion;
  int ultimoAnioActualizacion;
  List<ObjetosSociale> objetosSociales;
  Cod codEstadoActualizacion;
  Direccion direccion;
  List<Contacto> contactos;

  Datos({
    required this.estado,
    required this.id,
    required this.nit,
    required this.matricula,
    required this.matriculaAnterior,
    required this.razonSocial,
    required this.codTipoUnidadEconomica,
    required this.mesCierreGestion,
    required this.ultimoAnioActualizacion,
    required this.objetosSociales,
    required this.codEstadoActualizacion,
    required this.direccion,
    required this.contactos,
  });

  factory Datos.fromJson(Map<String, dynamic> json) => Datos(
    estado: json["estado"] ?? '-',  // Reemplaza null por '-'
    id: json["id"]?.toString() ?? '-',  // Convierte a String y reemplaza null
    nit: json["nit"] ?? '-',
    matricula: json["matricula"] ?? '-',
    matriculaAnterior: json["matriculaAnterior"] ?? '-',
    razonSocial: json["razonSocial"] ?? '-',
    codTipoUnidadEconomica: Cod.fromJson(json["codTipoUnidadEconomica"] ?? {}),
    mesCierreGestion: json["mesCierreGestion"] ?? '-',
    ultimoAnioActualizacion: json["ultimoAnioActualizacion"] ?? 0,  // Valor entero predeterminado
    objetosSociales: List<ObjetosSociale>.from(json["objetos_sociales"]?.map((x) => ObjetosSociale.fromJson(x)) ?? []),
    codEstadoActualizacion: Cod.fromJson(json["codEstadoActualizacion"] ?? {}),
    direccion: Direccion.fromJson(json["direccion"] ?? {}),
    contactos: List<Contacto>.from(json["contactos"]?.map((x) => Contacto.fromJson(x)) ?? []),
  );

  Map<String, dynamic> toJson() => {
    "estado": estado,
    "id": id,
    "nit": nit,
    "matricula": matricula,
    "matriculaAnterior": matriculaAnterior,
    "razonSocial": razonSocial,
    "codTipoUnidadEconomica": codTipoUnidadEconomica.toJson(),
    "mesCierreGestion": mesCierreGestion,
    "ultimoAnioActualizacion": ultimoAnioActualizacion,
    "objetos_sociales": List<dynamic>.from(objetosSociales.map((x) => x.toJson())),
    "codEstadoActualizacion": codEstadoActualizacion.toJson(),
    "direccion": direccion.toJson(),
    "contactos": List<dynamic>.from(contactos.map((x) => x.toJson())),
  };
}

class Cod {
  int id;
  String nombre;

  Cod({
    required this.id,
    required this.nombre,
  });

  factory Cod.fromJson(Map<String, dynamic> json) => Cod(
    id: json["id"] ?? 0,  // Asegura un valor entero predeterminado
    nombre: json["nombre"] ?? '-',  // Reemplaza null por '-'
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
  };
}

class Contacto {
  String estado;
  String id;
  String tipoContacto;
  List<Descripcion> descripcion;
  dynamic persona;

  Contacto({
    required this.estado,
    required this.id,
    required this.tipoContacto,
    required this.descripcion,
    required this.persona,
  });

  factory Contacto.fromJson(Map<String, dynamic> json) => Contacto(
    estado: json["estado"] ?? '-',  // Reemplaza null por '-'
    id: json["id"] ?? '-',  // Reemplaza null por '-'
    tipoContacto: json["tipoContacto"] ?? '-',  // Reemplaza null por '-'
    descripcion: List<Descripcion>.from(json["descripcion"]?.map((x) => Descripcion.fromJson(x)) ?? []),
    persona: json["persona"] ?? '-',  // Reemplaza null por '-'
  );

  Map<String, dynamic> toJson() => {
    "estado": estado,
    "id": id,
    "tipoContacto": tipoContacto,
    "descripcion": List<dynamic>.from(descripcion.map((x) => x.toJson())),
    "persona": persona,
  };
}

class Descripcion {
  String tipo;
  String? correo;
  String? numero;

  Descripcion({
    required this.tipo,
    this.correo,
    this.numero,
  });

  factory Descripcion.fromJson(Map<String, dynamic> json) => Descripcion(
    tipo: json["tipo"] ?? '-',  // Reemplaza null por '-'
    correo: json["correo"] ?? '-',  // Reemplaza null por '-'
    numero: json["numero"] ?? '-',  // Reemplaza null por '-'
  );

  Map<String, dynamic> toJson() => {
    "tipo": tipo,
    "correo": correo,
    "numero": numero,
  };
}

class Direccion {
  String id;
  String nombreVia;
  String numeroDomicilio;
  String edificio;
  String piso;
  String latitud;
  String longitud;
  Cod codDepartamento;
  Cod codProvincia;
  Cod codMunicipio;
  CodTipoVia codTipoVia;

  Direccion({
    required this.id,
    required this.nombreVia,
    required this.numeroDomicilio,
    required this.edificio,
    required this.piso,
    required this.latitud,
    required this.longitud,
    required this.codDepartamento,
    required this.codProvincia,
    required this.codMunicipio,
    required this.codTipoVia,
  });

  factory Direccion.fromJson(Map<String, dynamic> json) => Direccion(
    id: json["id"] ?? '-',  // Reemplaza null por '-'
    nombreVia: json["nombreVia"] ?? '-',  // Reemplaza null por '-'
    numeroDomicilio: json["numeroDomicilio"] ?? '-',  // Reemplaza null por '-'
    edificio: json["edificio"] ?? '-',  // Reemplaza null por '-'
    piso: json["piso"] ?? '-',  // Reemplaza null por '-'
    latitud: json["latitud"] ?? '-',  // Reemplaza null por '-'
    longitud: json["longitud"] ?? '-',  // Reemplaza null por '-'
    codDepartamento: Cod.fromJson(json["codDepartamento"] ?? {}),
    codProvincia: Cod.fromJson(json["codProvincia"] ?? {}),
    codMunicipio: Cod.fromJson(json["codMunicipio"] ?? {}),
    codTipoVia: CodTipoVia.fromJson(json["codTipoVia"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombreVia": nombreVia,
    "numeroDomicilio": numeroDomicilio,
    "edificio": edificio,
    "piso": piso,
    "latitud": latitud,
    "longitud": longitud,
    "codDepartamento": codDepartamento.toJson(),
    "codProvincia": codProvincia.toJson(),
    "codMunicipio": codMunicipio.toJson(),
    "codTipoVia": codTipoVia.toJson(),
  };
}

class CodTipoVia {
  String nombre;

  CodTipoVia({
    required this.nombre,
  });

  factory CodTipoVia.fromJson(Map<String, dynamic> json) => CodTipoVia(
    nombre: json["nombre"] ?? '-',  // Reemplaza null por '-'
  );

  Map<String, dynamic> toJson() => {
    "nombre": nombre,
  };
}

class ObjetosSociale {
  String objetoSocial;

  ObjetosSociale({
    required this.objetoSocial,
  });

  factory ObjetosSociale.fromJson(Map<String, dynamic> json) => ObjetosSociale(
    objetoSocial: json["objetoSocial"] ?? '-',  // Reemplaza null por '-'
  );

  Map<String, dynamic> toJson() => {
    "objetoSocial": objetoSocial,
  };
}