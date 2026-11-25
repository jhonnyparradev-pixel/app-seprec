import 'package:flutter_test/flutter_test.dart';

import 'package:seprec/model/ubicacion.dart';
import 'package:seprec/page_menu/api_config.dart';

void main() {
  test('builds the filtered platforms location request', () {
    final uri = Uri.parse(
      ApiConfig.ubicaciones(query: 'LA PAZ - CENTRAL'),
    );

    expect(uri.path, endsWith('/parametros/plataformas-ubicaciones'));
    expect(uri.queryParameters['q'], 'LA PAZ - CENTRAL');
  });

  test('parses location fields when the image is null', () {
    final ubicacion = Ubicacion.fromJson({
      'plataformaNombre': 'LA PAZ - CENTRAL',
      'direccion': 'Avenida 20 de Octubre, edificio Bethesda, zona Sopocachi',
      'horario': 'Lun. a Vie. | 08:30–16:00',
      'mapa_url': 'https://maps.example/location',
      'imagen_url': 'assets/LA_PAZ.jpg',
      'imagen_base64': null,
      'telefono': '72017483',
      'latitude': '-16.5091670',
      'longitude': '-68.1273330',
    });

    expect(ubicacion.city, 'LA PAZ - CENTRAL');
    expect(ubicacion.address, contains('Avenida 20 de Octubre'));
    expect(ubicacion.latitude, closeTo(-16.509167, 0.000001));
    expect(ubicacion.longitude, closeTo(-68.127333, 0.000001));
    expect(ubicacion.imageBase64, isEmpty);
    expect(ubicacion.phone, '72017483');
  });
}
