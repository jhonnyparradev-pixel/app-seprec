import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../model/ubicacion.dart';
import '../page_menu/ubicaciones_service.dart';
import '../widgets/seprec_loading_overlay.dart';
import '../widgets/seprec_service_state.dart';
import '../widgets/seprec_tech_background.dart';

class GeoreferenciacionScreen extends StatefulWidget {
  const GeoreferenciacionScreen({super.key});

  @override
  State<GeoreferenciacionScreen> createState() =>
      _GeoreferenciacionScreenState();
}

class _GeoreferenciacionScreenState extends State<GeoreferenciacionScreen> {
  Future<List<Ubicacion>>? _ubicaciones;

  @override
  void initState() {
    super.initState();
    _ubicaciones = obtenerUbicaciones();
  }

  Future<void> _recargarUbicaciones() async {
    final future = obtenerUbicaciones();
    setState(() {
      _ubicaciones = future;
    });
    await future.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
  }

  Future<List<Ubicacion>> obtenerUbicaciones() async {
    return UbicacionesService().obtenerUbicaciones();
  }

  // ---------------------------------------------------------------------------
  // Estado "Abierto ahora" (hora de Bolivia = UTC-4, Lun. a Vie. | 08:30–16:00 h)
  // ---------------------------------------------------------------------------
  bool _estaAbierto() {
    final ahora = DateTime.now().toUtc().subtract(
          const Duration(hours: 4),
        );
    if (ahora.weekday > DateTime.friday) return false;
    final minutos = ahora.hour * 60 + ahora.minute;
    return minutos >= 510 && minutos < 960;
  }

  // ---------------------------------------------------------------------------
  // Imagen de la sede
  // ---------------------------------------------------------------------------
  Widget _placeholder() => Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.panel,
        child: Icon(
          Icons.apartment_rounded,
          size: 48,
          color: AppColors.icon.withOpacity(0.6),
        ),
      );

  Widget _buildLocationImage(Ubicacion location) {
    if (location.imageBase64.isNotEmpty) {
      String base64 = location.imageBase64;
      if (base64.contains(',')) base64 = base64.split(',').last;

      try {
        return Image.memory(
          base64Decode(base64),
          fit: BoxFit.cover,
          width: double.infinity,
        );
      } catch (_) {}
    }

    if (location.image.startsWith('http')) {
      return Image.network(
        location.image,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return Image.asset(
      location.image,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Future<void> _openUrl(Ubicacion location, {bool directions = false}) async {
    var url = location.map;
    if (directions && location.latitude != 0 && location.longitude != 0) {
      url =
          'https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}';
    }

    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  Widget _statusChip(bool abierto) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: abierto
              ? const [
                  Color(0xFF104A48),
                  Color(0xFF092E38),
                ]
              : const [
                  Color(0xFF303B49),
                  Color(0xFF172535),
                ],
        ),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: abierto
              ? const Color(0xFF28CFC0).withOpacity(0.65)
              : Colors.white24,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (abierto ? const Color(0xFF20D6BC) : Colors.black)
                .withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: abierto
                ? const Color(0xFF45F5C1)
                : const Color.fromARGB(255, 225, 9, 9),
          ),
          const SizedBox(width: 5),
          Text(
            abierto ? 'Abierto ahora' : 'Cerrado',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              color:
                  abierto ? const Color(0xFF8FFFE0) : const Color(0xFFB0BAC5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required Ubicacion location,
    required String label,
    required IconData icon,
    required bool directions,
  }) {
    final bool filled = !directions;

    return Expanded(
      child: SizedBox(
        height: 38,
        child: OutlinedButton.icon(
          onPressed: () => _openUrl(
            location,
            directions: directions,
          ),
          icon: Icon(
            icon,
            size: 16,
          ),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 0.1,
              ),
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: filled ? Colors.white : const Color(0xFF50E4D6),
            backgroundColor:
                filled ? const Color(0xFF087F78) : const Color(0xFF102B3D),
            side: BorderSide(
              color: filled ? const Color(0xFF20CFC0) : const Color(0xFF258F91),
              width: 1.2,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Ubicacion location) {
    final direccion = location.address;
    final abierto = _estaAbierto();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 420;
          final cardHeight = narrow ? 260.0 : 290.0;
          final availableWidth = constraints.maxWidth - 24;

          // IMAGEN
          final photo = ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              bottomLeft: Radius.circular(18),
            ),
            child: SizedBox(
              height: cardHeight,
              width: availableWidth * 0.50,
              child: _buildLocationImage(location),
            ),
          );

          // DESCRIPCIÓN
          final details = Expanded(
            child: Container(
              height: cardHeight,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF075B58),
                    Color(0xFF073B43),
                    Color(0xFF082536),
                    Color(0xFF061523),
                  ],
                  stops: [0.0, 0.35, 0.70, 1.0],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(
                  color: const Color(0xFF287F86).withOpacity(0.65),
                  width: 1.2,
                ),
              ),
              padding: EdgeInsets.all(narrow ? 12 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ESTADO: ABIERTO / CERRADO
                  Align(
                    alignment: Alignment.topRight,
                    child: Transform.translate(
                      offset: const Offset(8, -6),
                      child: _statusChip(abierto),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // CIUDAD
                  Text(
                    location.city.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: narrow ? 14 : 22,
                      height: 0.95,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // HORARIO
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 17,
                        color: Color(0xFF45F59D),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          location.hours,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF50E4D6),
                            fontSize: 11,
                            height: 1.25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // DIRECCIÓN
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 17,
                        color: Color(0xFF45F59D),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: RichText(
                          maxLines: narrow ? 4 : 5,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              height: 1.25,
                            ),
                            children: [
                              TextSpan(
                                text: '$direccion\n',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (location.phone.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 15,
                          color: Color(0xFF45F59D),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Teléfono: ${location.phone}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const Spacer(),

                  // BOTONES
                  Row(
                    children: [
                      _actionButton(
                        location: location,
                        label: 'Ver mapa',
                        icon: Icons.map_outlined,
                        directions: false,
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        location: location,
                        label: 'Cómo llegar',
                        icon: Icons.alt_route_rounded,
                        directions: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );

          // TARJETA COMPLETA
          return ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: cardHeight + 24,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF080D1C),
                    Color(0xFF061523),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF54758D),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  photo,
                  details,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarForeground,
        centerTitle: true,
        title: const Text(
          'Ubicaciones',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: SeprecTechBackground(child: SizedBox.shrink()),
          ),
          FutureBuilder<List<Ubicacion>>(
            future: _ubicaciones,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SeprecLoadingOverlay(
                  isLoading: true,
                  child: SizedBox.expand(),
                );
              }

              if (snapshot.hasError) {
                return RefreshIndicator(
                  onRefresh: _recargarUbicaciones,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SeprecServiceState(
                        isError: true,
                        onRetry: _recargarUbicaciones,
                      ),
                    ],
                  ),
                );
              }

              final ubicaciones = snapshot.data ?? [];
              if (ubicaciones.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _recargarUbicaciones,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SeprecServiceState(
                        details: 'No hay ubicaciones disponibles.',
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _recargarUbicaciones,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: ubicaciones.length,
                  itemBuilder: (context, index) =>
                      _buildCard(ubicaciones[index]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
