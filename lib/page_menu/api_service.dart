import 'package:http/http.dart' as http;
import 'dart:convert';

void imprimirConsumoServicio({
  required String url,
  required int statusCode,
  required String respuesta,
  Map<String, dynamic>? parametros,
}) {
  print('\x1B[1;93m⚡ ${'=' * 100} ⚡\x1B[0m');
  print('URL: $url');
  if (parametros != null) {
    const formateador = JsonEncoder.withIndent('  ');
    print('Parámetros enviados:');
    print(formateador.convert(parametros));
  }
  print('Estado: $statusCode');
  try {
    final jsonRespuesta = jsonDecode(respuesta);
    const formateador = JsonEncoder.withIndent('  ');
    print(formateador.convert(jsonRespuesta));
  } on FormatException {
    print(respuesta);
  }
  print('\x1B[1;93m⚡ ${'=' * 100} ⚡\x1B[0m');
}

class ApiService {
  Future<Map<String, dynamic>?> get(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}

// // Obtener información de una empresa
//   final empresa = await apiService.get(ApiConfig.informacionBasicaEmpresa("6789", "1011"));
//   print("Empresa encontrada: $empresa");
