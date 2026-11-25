import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/ubicacion.dart';
import 'api_config.dart';
import 'api_service.dart';

class UbicacionesService {
  Future<List<Ubicacion>> obtenerUbicaciones({String? query}) async {
    final url = ApiConfig.ubicaciones(query: query);
    final response = await http.get(Uri.parse(url));

    imprimirConsumoServicio(
      url: url,
      statusCode: response.statusCode,
      respuesta: response.body,
      parametros: query == null ? null : {'q': query},
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar las ubicaciones.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['datos'] is! List) {
      throw const FormatException('Respuesta inválida del servicio.');
    }

    return (decoded['datos'] as List).map((item) {
      if (item is! Map) {
        throw const FormatException('Registro de ubicación inválido.');
      }
      return Ubicacion.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }
}
