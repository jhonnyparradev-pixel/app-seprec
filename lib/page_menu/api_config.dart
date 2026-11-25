class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://test-servicios.seprec.gob.bo/api',
  );

  static String buscarTramite(String codigo) =>
      "$baseUrl/tramites/buscarTramite?codigo=$codigo";

  static String informacionTramites(String id) =>
      "$baseUrl/informacion-tramites/$id";

  static String informacionBasicaEmpresa(String id, String idEstablecimiento) =>
      "$baseUrl/empresas/informacionBasicaEmpresa/$id/establecimiento/$idEstablecimiento";

  static String buscarEmpresas(
          String filtro, String tipoFiltro, int limite, int pagina) =>
      "$baseUrl/empresas/buscarEmpresas?filtro=$filtro&tipoFiltro=$tipoFiltro&limite=$limite&pagina=$pagina";

  static String listarTramites(int pagina, int limite, {String filtro = ""}) =>
      "$baseUrl/informacion-tramites?pagina=$pagina&limite=$limite&filtro=$filtro";

  static String buscarMatriculaActividad(String id) =>
      '$baseUrl/empresas/buscarMatriculaActividad/$id';

  static String buscarEmpresasGeo(
      {required String filtro,
      required String tipoFiltro,
      double? lat,
      double? lon,
      int limite = 10,
      int pagina = 1}) {
    var url = buscarEmpresas(filtro, tipoFiltro, limite, pagina);

    if (tipoFiltro == 'geo' && lat != null && lon != null) {
      url += '&lat=$lat&lon=$lon';
    }
    return url;
  }

  static String ubicaciones({String? query}) {
    final uri = Uri.parse('$baseUrl/parametros/plataformas-ubicaciones');
    if (query == null || query.isEmpty) return uri.toString();
    return uri.replace(queryParameters: {'q': query}).toString();
  }
}

// https://servicios.seprec.gob.bo/api/tramites/buscarTramite?codigo=$codigo
// https://servicios.seprec.gob.bo/api/informacion-tramites
// https://servicios.seprec.gob.bo/api/informacion-tramites/$id
// https://servicios.seprec.gob.bo/api/empresas/informacionBasicaEmpresa/$id/establecimiento/$idEstablecimiento
// https://servicios.seprec.gob.bo/api/empresas/buscarEmpresas?filtro=$filtro&tipoFiltro=$tipoFiltro&limite=$limite&pagina=$pagina
