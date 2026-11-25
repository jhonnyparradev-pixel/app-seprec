class Empresa {
  final String estado;
  final String id;
  final String matricula;
  final String razonSocial;
  final String nombreDepartamento;
  final String estadoActualizacionNombre;
  final String codigo;
  final String idEstablecimiento;  // Nuevo campo

  Empresa({
    required this.estado,
    required this.id,
    required this.matricula,
    required this.razonSocial,
    required this.nombreDepartamento,
    required this.estadoActualizacionNombre,
    required this.codigo,
    required this.idEstablecimiento,  // Nuevo campo
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      estado: json['estado'] ?? "-", // Reemplaza null por "-"
      id: json['id'] ?? "-", // Reemplaza null por "-"
      matricula: json['matricula'] ?? "-", // Reemplaza null por "-"
      razonSocial: json['razonSocial'] ?? "-", // Reemplaza null por "-"
      nombreDepartamento: json['direccion']['codDepartamento']['nombre'] ?? "-", // Reemplaza null por "-"
      estadoActualizacionNombre: json['codEstadoActualizacion']['nombre'] ?? "-", // Reemplaza null por "-"
      codigo: json['codEstadoActualizacion']['codigo'] ?? "-",
      idEstablecimiento: json['idEstablecimiento'] ?? "-", // Reemplaza null por "-"
    );
  }
}