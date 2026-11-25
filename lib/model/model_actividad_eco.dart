class ActividadEconomica {
  final String id;
  final String tipo;
  final String codigo;
  final String descripcion;

  ActividadEconomica({
    required this.id,
    required this.tipo,
    required this.codigo,
    required this.descripcion,
  });

  factory ActividadEconomica.fromJson(Map<String, dynamic> json) {
    return ActividadEconomica(
      id: json['id'],
      tipo: json['tipo'],
      codigo: json['codigo'],
      descripcion: json['descripcion'],
    );
  }
}
