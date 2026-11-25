import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../model/model_actividad_eco.dart';
import '../model/model_informacion_empresa.dart';
import 'api_config.dart';
import 'api_service.dart';
import '../widgets/seprec_loading_overlay.dart';
import '../widgets/seprec_service_state.dart';
import '../widgets/seprec_tech_background.dart';

class MasInfoEmpresa extends StatefulWidget {
  final String id;
  final String idEstablecimiento;

  const MasInfoEmpresa({
    super.key,
    required this.id,
    required this.idEstablecimiento,
  });

  @override
  State<MasInfoEmpresa> createState() => _MasInfoEmpresaState();
}

class _MasInfoEmpresaState extends State<MasInfoEmpresa> {
  late Future<InformacionEmpresa> _empresaFuture;
  ActividadEconomica? actividadR;
  bool isLoadingActividad = true;

  @override
  void initState() {
    super.initState();
    _empresaFuture = obtenerInformacionEmpresa(
      widget.id,
      widget.idEstablecimiento,
    );
    cargarActividad();
  }

  Future<void> cargarActividad() async {
    final actividad = await fetchActividadMasEspecifica(widget.id);

    if (!mounted) return;

    setState(() {
      actividadR = actividad;
      isLoadingActividad = false;
    });
  }

  Future<void> _recargarEmpresa() async {
    final future = obtenerInformacionEmpresa(
      widget.id,
      widget.idEstablecimiento,
    );
    setState(() {
      _empresaFuture = future;
      isLoadingActividad = true;
    });
    cargarActividad();
    await future.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InformacionEmpresa>(
      future: _empresaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            isLoadingActividad) {
          return Scaffold(
            backgroundColor: Color(0xFF080D1C),
            appBar: _buildAppBar(),
            body: SafeArea(
              child: SeprecTechBackground(
                child: const SeprecLoadingOverlay(
                  isLoading: true,
                  child: SizedBox.expand(),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(),
            body: SafeArea(
              child: SeprecTechBackground(
                child: SeprecServiceState(
                  isError: true,
                  onRetry: _recargarEmpresa,
                ),
              ),
            ),
          );
        }

        final empresa = snapshot.data;
        if (empresa == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(),
            body: const SafeArea(
              child: SeprecTechBackground(
                child: SeprecServiceState(
                  details: 'No se encontró información de la empresa.',
                ),
              ),
            ),
          );
        }

        final datos = empresa.datos;

        return Scaffold(
          backgroundColor: const Color(0xFF080D1C),
          appBar: _buildAppBar(),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                return SeprecTechBackground(
                  child: RefreshIndicator(
                    onRefresh: _recargarEmpresa,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 40,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          Text(
                            datos.razonSocial,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(datos, isMobile),
                          const SizedBox(height: 16),
                          _buildMap(datos, isMobile),
                          const SizedBox(height: 12),
                          _buildDirectionsButton(datos),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.appBarBackground,
      elevation: 0,
      foregroundColor: AppColors.appBarForeground,
      centerTitle: true,
      title: const Text(
        'Detalle Empresa',
        style: TextStyle(
          color: AppColors.appBarForeground,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.appBarForeground,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Image.asset(
            'assets/Aplicacion-MOVIL-SEPREC-SEPREC.png',
            height: 40,
            width: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionsButton(Datos datos) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _openDirections(datos),
        icon: const Icon(Icons.alt_route_rounded, size: 18),
        label: const Text('Cómo llegar'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF50E4D6),
          backgroundColor: const Color(0xFF102B3D),
          side: const BorderSide(
            color: Color(0xFF258F91),
            width: 1.2,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Future<void> _openDirections(Datos datos) async {
    final latitude = double.tryParse(datos.direccion.latitud);
    final longitude = double.tryParse(datos.direccion.longitud);
    final hasCoordinates = latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        (latitude != 0 || longitude != 0);
    final destination = hasCoordinates
        ? '$latitude,$longitude'
        : [
            datos.direccion.nombreVia,
            datos.direccion.numeroDomicilio,
            datos.direccion.codDepartamento.nombre,
          ]
            .where((part) => part.trim().isNotEmpty && part.trim() != '-')
            .join(', ');

    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay una dirección disponible')),
      );
      return;
    }

    final uri = Uri.https(
      'www.google.com',
      '/maps/dir/',
      {'api': '1', 'destination': destination},
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la ruta')),
      );
    }
  }

  Widget _buildInfoCard(Datos datos, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF087C76),
            Color(0xFF061523),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF54758D),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF30BFA5).withOpacity(0.16),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRow("Matrícula:", datos.matricula, isMobile),
          _buildRow("Matrícula anterior:", datos.matriculaAnterior, isMobile),
          _buildRow("Estado:", datos.estado, isMobile),
          _buildRow("NIT:", datos.nit, isMobile),
          _buildRow(
            "Dirección:",
            "${datos.direccion.codDepartamento.nombre}, ${datos.direccion.nombreVia}",
            isMobile,
          ),
          _buildRow(
            "Actividad:",
            actividadR?.descripcion ?? 'No disponible',
            isMobile,
          ),
          _buildRow(
            "Correos:",
            obtenerCorreos(datos.contactos).join(', '),
            isMobile,
          ),
          _buildRow(
            "Teléfonos:",
            obtenerTelefonos(datos.contactos).join(', '),
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildMap(Datos datos, bool isMobile) {
    final lat = double.tryParse(datos.direccion.latitud) ?? 0;
    final lng = double.tryParse(datos.direccion.longitud) ?? 0;

    return SizedBox(
      height: isMobile ? 250 : 350,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF54758D),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(lat, lng),
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.seprec.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80,
                    height: 80,
                    point: LatLng(lat, lng),
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFF087C76),
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String? value, bool isMobile) {
    final displayValue =
        (value?.trim().isNotEmpty ?? false) ? value! : 'No disponible';
    final cleanLabel = label.replaceAll(':', '').trim();

    IconData icon;
    switch (cleanLabel) {
      case 'Matrícula':
      case 'Matrícula anterior':
      case 'NIT':
        icon = Icons.badge_outlined;
        break;
      case 'Estado':
        icon = Icons.verified_outlined;
        break;
      case 'Dirección':
        icon = Icons.location_on_outlined;
        break;
      case 'Actividad':
        icon = Icons.work_outline_rounded;
        break;
      case 'Correos':
        icon = Icons.email_outlined;
        break;
      case 'Teléfonos':
        icon = Icons.phone_outlined;
        break;
      default:
        icon = Icons.info_outline_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF102B3D).withOpacity(0.38),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF54758D).withOpacity(0.60),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF50E4D6),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.35,
                  ),
                  children: [
                    TextSpan(
                      text: '$label ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD0E3DA),
                      ),
                    ),
                    TextSpan(text: displayValue),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<InformacionEmpresa> obtenerInformacionEmpresa(
    String id,
    String idEstablecimiento,
  ) async {
    final url = ApiConfig.informacionBasicaEmpresa(id, idEstablecimiento);

    final response = await http.get(Uri.parse(url));

    imprimirConsumoServicio(
      url: url,
      statusCode: response.statusCode,
      respuesta: response.body,
      parametros: {
        'id': id,
        'idEstablecimiento': idEstablecimiento,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error HTTP: ${response.statusCode}');
    }

    final jsonResponse = json.decode(response.body);

    if (jsonResponse['datos'] == null) {
      throw Exception('Empresa no encontrada o inactiva.');
    }

    return InformacionEmpresa.fromJson(jsonResponse);
  }

  Future<ActividadEconomica?> fetchActividadMasEspecifica(String id) async {
    try {
      final url = ApiConfig.buscarMatriculaActividad(id);

      final response = await http.get(Uri.parse(url));

      imprimirConsumoServicio(
        url: url,
        statusCode: response.statusCode,
        respuesta: response.body,
        parametros: {
          'id': id,
        },
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final actividades = data['datos']?['actividadesEconomicas'];

      if (actividades is List && actividades.isNotEmpty) {
        final innerList = actividades.last;

        if (innerList is List && innerList.isNotEmpty) {
          final ultimaActividad = innerList.last;

          if (ultimaActividad is Map<String, dynamic>) {
            return ActividadEconomica.fromJson(ultimaActividad);
          }
        }
      }
    } catch (_) {}

    return null;
  }

  List<String> obtenerCorreos(List<Contacto> contactos) {
    return contactos
        .expand((c) => c.descripcion)
        .where((d) =>
            (d.tipo.toLowerCase().contains('correo') || d.correo != null) &&
            d.correo != null &&
            d.correo != '-')
        .map((d) => d.correo!)
        .toList();
  }

  List<String> obtenerTelefonos(List<Contacto> contactos) {
    return contactos
        .expand((c) => c.descripcion)
        .where((d) =>
            (d.tipo.toLowerCase().contains('telefono') ||
                d.tipo.toLowerCase().contains('celular')) &&
            d.numero != null &&
            d.numero != '-')
        .map((d) => d.numero!)
        .toList();
  }
}
