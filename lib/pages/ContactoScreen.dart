import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../main.dart';
import '../model/ubicacion.dart';
import '../page_menu/ubicaciones_service.dart';
import '../widgets/seprec_loading_overlay.dart';
import '../widgets/seprec_service_state.dart';
import '../widgets/seprec_tech_background.dart';

class ContactoScreen extends StatefulWidget {
  const ContactoScreen({super.key});

  @override
  State<ContactoScreen> createState() => _ContactoScreenState();
}

class _ContactoScreenState extends State<ContactoScreen> {
  static const String _locationQuery = 'LA PAZ - CENTRAL';
  static const String email = 'info@seprec.gob.bo';
  static const String website = 'www.seprec.gob.bo';
  static const String phoneNumberCST = '72017493';
  static const String phoneNumberSBP = '72017434';
  static const String phoneNumberLOP = '72017472';

  late Future<Ubicacion> _ubicacionCentral;

  final Uri _urlFacebook =
      Uri.parse('http://www.facebook.com/SEPRECBolivia/?locale=es_LA');
  final Uri _urlInstagram =
      Uri.parse('https://www.instagram.com/seprecbolivia/');
  final Uri _urlTwitter = Uri.parse('https://x.com/SEPRECBolivia');
  final Uri _urlYouTube =
      Uri.parse('https://www.youtube.com/@servicioplurinacionaldereg4383');
  final Uri _urlTikTok =
      Uri.parse('https://www.tiktok.com/@seprecbolivia?_r=1&_t=ZS-95tNMOY6aVJ');
  final Uri _linkedin = Uri.parse(
      'https://www.linkedin.com/in/servicio-plurinacional-de-registro-de-comercio-seprec-8593233b7?utm_source=share_via&utm_content=profile&utm_medium=member_android');

  @override
  void initState() {
    super.initState();
    _ubicacionCentral = _obtenerUbicacionCentral();
  }

  Future<Ubicacion> _obtenerUbicacionCentral() async {
    final ubicaciones = await UbicacionesService().obtenerUbicaciones(
      query: _locationQuery,
    );
    final ubicacion = ubicaciones.firstWhere(
      (item) => item.city.trim().toUpperCase() == _locationQuery,
      orElse: () => throw StateError('No se encontró la oficina central.'),
    );

    if (!ubicacion.latitude.isFinite ||
        !ubicacion.longitude.isFinite ||
        ubicacion.latitude < -90 ||
        ubicacion.latitude > 90 ||
        ubicacion.longitude < -180 ||
        ubicacion.longitude > 180) {
      throw const FormatException('Coordenadas de ubicación inválidas.');
    }

    return ubicacion;
  }

  Future<void> _recargarUbicacionCentral() async {
    final future = _obtenerUbicacionCentral();
    setState(() {
      _ubicacionCentral = future;
    });
    await future.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
  }

  Widget _buildLocationContent() {
    return FutureBuilder<Ubicacion>(
      future: _ubicacionCentral,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 250,
            child: SeprecLoadingOverlay(
              isLoading: true,
              child: SizedBox.expand(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return SeprecServiceState(
            isError: true,
            onRetry: _recargarUbicacionCentral,
          );
        }

        final ubicacion = snapshot.data!;
        final location = LatLng(ubicacion.latitude, ubicacion.longitude);

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF080D1C).withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF54758D),
                  width: 1.2,
                ),
              ),
              child: Text(
                ubicacion.address,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            if (ubicacion.phone.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF080D1C).withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF54758D),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF50E4D6),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Teléfono: ${ubicacion.phone}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openDirections(ubicacion),
                icon: const Icon(Icons.alt_route_rounded, size: 18),
                label: const Text('Cómo llegar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF102B3D),
                  side: const BorderSide(
                    color: Color(0xFF258F91),
                    width: 1.2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: location,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.seprec.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80,
                          height: 80,
                          point: location,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openDirections(Ubicacion ubicacion) async {
    final Uri? uri;
    if (ubicacion.latitude != 0 && ubicacion.longitude != 0) {
      uri = Uri.https(
        'www.google.com',
        '/maps/dir/',
        {
          'api': '1',
          'destination': '${ubicacion.latitude},${ubicacion.longitude}',
        },
      );
    } else {
      final mapUrl = ubicacion.map.trim();
      uri = mapUrl.isEmpty ? null : Uri.tryParse(mapUrl);
    }

    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la ruta')),
        );
      }
    }
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final Uri whatsappUrl = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: '/$phoneNumber',
    );
    await _launchUrl(whatsappUrl);
  }

  Widget _buildContactCard(
      IconData icon, String title, Function onTap, bool isTablet) {
    return Card(
      color: AppColors.panel.withOpacity(0.60), // 🔥 fondo semi-transparente
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: const Color(0xFF54758D),
          width: 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 12,
            vertical: isTablet ? 14 : 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppColors.icon, // 🔥 color principal de iconos
                size: isTablet ? 26 : 18,
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary, // 🔥 texto claro
                    fontSize: isTablet ? 16 : 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsAppButton(String phone, String lineText) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.50),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            padding: const EdgeInsets.all(14),
            onPressed: () => _launchWhatsApp(phone),
            icon: const FaIcon(
              FontAwesomeIcons.whatsapp,
              size: 30,
              color: AppColors.icon,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          lineText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1C),

      /// 🔹 APPBAR (CABECERA PRINCIPAL)
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarForeground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Contáctanos',
          style: TextStyle(
            color: AppColors.appBarForeground,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/Aplicacion-MOVIL-SEPREC-SEPREC.png',
              height: 40,
              width: 40,
            ),
          ),
        ],
      ),

      /// 🔹 BODY
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF080D1C),
            ),
            child: Column(
              children: [
                Text(
                  'Sigenos en:',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                /// REDES
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  children: [
                    _buildSocialIcon(
                        FontAwesomeIcons.facebook, _urlFacebook, false),
                    _buildSocialIcon(
                        FontAwesomeIcons.instagram, _urlInstagram, false),
                    _buildSocialIcon(
                        FontAwesomeIcons.xTwitter, _urlTwitter, false),
                    _buildSocialIcon(FontAwesomeIcons.youtube, _urlYouTube,
                        false), //_linkedin
                    _buildSocialIcon(
                        FontAwesomeIcons.tiktok, _urlTikTok, false),
                    _buildSocialIcon(
                        FontAwesomeIcons.linkedin, _linkedin, false),
                  ],
                ),
              ],
            ),
          ),

          /// 🔹 CONTENIDO
          Expanded(
            child: Stack(
              children: [
                const Positioned.fill(
                  child: SeprecTechBackground(
                    child: SizedBox.shrink(),
                  ),
                ),
                SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _recargarUbicacionCentral,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            /// EMAIL + WEB
                            Row(
                              children: [
                                Expanded(
                                  child: _buildContactCard(
                                    Icons.email,
                                    email,
                                    () async {
                                      final Uri emailUrl =
                                          Uri(scheme: 'mailto', path: email);
                                      await _launchUrl(emailUrl);
                                    },
                                    false,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildContactCard(
                                    Icons.public,
                                    website,
                                    () async {
                                      final Uri websiteUrl =
                                          Uri.parse('https://$website');
                                      await _launchUrl(websiteUrl);
                                    },
                                    false,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            /// 🔹 WHATSAPP MÁS CLARO
                            Container(
                              margin: const EdgeInsets.all(1),
                              padding: const EdgeInsets.all(10),
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
                                    color: const Color(0xFF30BFA5)
                                        .withOpacity(0.16),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Atención Nacional',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: _buildWhatsAppButton(
                                            phoneNumberLOP,
                                            'Línea 1',
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: _buildWhatsAppButton(
                                            phoneNumberCST,
                                            'Línea 2',
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: _buildWhatsAppButton(
                                            phoneNumberSBP,
                                            'Línea 3',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 50),

                            _buildLocationContent(),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(FaIconData icon, Uri url, bool isTablet) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: FaIcon(
        icon,
        color: AppColors.icon,
        size: isTablet ? 40 : 28,
      ),
    );
  }
}
