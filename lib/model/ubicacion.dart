class Ubicacion {
  final String city;
  final String hours;
  final String address;
  final String map;
  final String image;
  final String imageBase64;
  final String phone;
  final double latitude;
  final double longitude;

  Ubicacion({
    required this.city,
    required this.hours,
    required this.address,
    required this.map,
    required this.image,
    required this.imageBase64,
    this.phone = '',
    required this.latitude,
    required this.longitude,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      city: json['plataformaNombre']?.toString() ?? '',
      hours: json['horario']?.toString() ?? '',
      address: json['direccion']?.toString() ?? '',
      map: json['mapa_url']?.toString() ?? '',
      image: json['imagen_url']?.toString() ?? '',
      imageBase64: json['imagen_base64']?.toString() ?? '',
      phone: json['telefono']?.toString() ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0,
    );
  }
}
