import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../page_menu/Estado_Tramite.dart';
import '../page_menu/guia_tramites.dart';
import '../page_menu/unidades_cerca.dart';
import '../page_menu/unidades_economicas.dart';
import '../widgets/seprec_tech_background.dart';

class InicioScreen extends StatefulWidget {
  @override
  _InicioScreenState createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  // ==========================================
  // MENÚ PRINCIPAL
  // ==========================================

  final List<MenuItem> menuItems = [
    MenuItem(
      title: 'Guía de Trámites',
      description: 'Consulta los requisitos,\npasos y documentos.',
      screen: GuiaTramites(),
      icon: 'assets/images/icono_guia_de_tramites.png',
      accent: const Color(0xFF087C76),
    ),
    MenuItem(
      title: 'Estado del Trámite',
      description: 'Verifica el estado\nde tu trámite.',
      screen: EstadoTramite(),
      icon: 'assets/images/icono_estado_del_tramite.png',
      accent: const Color(0xFF087C76),
    ),
    MenuItem(
      title: 'Gaceta Electrónica',
      description: 'Accede a las publicaciones\nde la Gaceta.',
      url: 'https://gacetadecomercio.gob.bo/#/',
      icon: 'assets/images/icono_gaceta_electronica.png',
      accent: const Color(0xFF07558D),
    ),
    MenuItem(
      title: 'Directorio Empresarial',
      description: 'Busca empresas\nregistradas en SEPREC.',
      screen: BuscarEmpresasPage(),
      icon: 'assets/images/icono_directorio_empresarial.png',
      accent: const Color(0xFF7F244E),
    ),
  ];

  // ==========================================
  // ABRIR ENLACES EXTERNOS
  // ==========================================

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  // ==========================================
  // TARJETAS DEL MENÚ
  // ==========================================

  Widget _buildMenuItem(MenuItem item, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return GestureDetector(
      onTap: () {
        if (item.url != null) {
          _launchUrl(item.url!);
        } else if (item.screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => item.screen!,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF54758D),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // FONDO DEGRADADO DE LA TARJETA
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(
                          item.accent,
                          Colors.white,
                          0.08,
                        )!,
                        const Color(0xFF061523),
                      ],
                    ),
                  ),
                ),
              ),

              // ONDA INFERIOR
              Positioned.fill(
                child: ClipPath(
                  clipper: _BottomWaveClipper(),
                  child: Container(
                    color: item.accent.withOpacity(0.22),
                  ),
                ),
              ),

              // CONTENIDO DE LA TARJETA
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double iconHeight = (constraints.maxHeight * 0.45)
                        .clamp(60.0, 105.0)
                        .toDouble();

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        8,
                        8,
                        8,
                        8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ICONO / IMAGEN
                          SizedBox(
                            height: iconHeight,
                            width: double.infinity,
                            child: Image.asset(
                              item.icon,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // TÍTULO
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              height: 1.05,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // DESCRIPCIÓN
                          Expanded(
                            child: Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: isMobile ? 12 : 13,
                                height: 1.18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // BOTÓN DE ACCESO
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF102B3D).withOpacity(0.9),
                    border: Border.all(
                      color: const Color(0xFF6D8CA0),
                      width: 0.8,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CONSTRUCCIÓN DE PANTALLA
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    int crossAxisCount = 2;

    if (screenWidth > 650) {
      crossAxisCount = 3;
    }

    if (screenWidth > 1200) {
      crossAxisCount = 4;
    }

    double logoHeight = screenHeight * 0.14;

    if (logoHeight > 170) {
      logoHeight = 170;
    }

    return Scaffold(
      body: Stack(
        children: [
          // ======================================
          // FONDO TECNOLÓGICO SEPREC
          // ======================================

          const Positioned.fill(
            child: SeprecTechBackground(
              child: SizedBox.shrink(),
            ),
          ),

          // ======================================
          // CONTENIDO PRINCIPAL
          // ======================================

          SafeArea(
            child: Column(
              children: [
                // ==================================
                // CABECERA ESTÁTICA
                // ==================================

                Center(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 18),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFF1F5F9),
                          Color(0xFFE8F0F5),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFF30BFA5).withOpacity(0.55),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF30BFA5).withOpacity(0.13),
                          blurRadius: 18,
                          spreadRadius: 1,
                          offset: const Offset(0, 5),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Líneas tecnológicas decorativas
                        Positioned(
                          left: 0,
                          top: 5,
                          child: Container(
                            width: 35,
                            height: 2,
                            decoration: BoxDecoration(
                              color: const Color(0xFF159E8A),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 5,
                          child: Container(
                            width: 35,
                            height: 2,
                            decoration: BoxDecoration(
                              color: const Color(0xFF159E8A),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/Logo_SEPREC.png',
                          height: logoHeight,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================
                // CUERPO SCROLLABLE
                // ==================================

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      14,
                      12,
                      14,
                      78,
                    ),
                    child: Column(
                      children: [
                        // GRID DE MÓDULOS
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: menuItems.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: screenWidth < 600 ? 10 : 14,
                            mainAxisSpacing: screenWidth < 600 ? 10 : 14,
                            childAspectRatio: screenWidth < 360
                                ? 0.90
                                : screenWidth < 600
                                    ? 0.92
                                    : screenWidth < 950
                                        ? 1.12
                                        : 1.18,
                          ),
                          itemBuilder: (context, index) {
                            return _buildMenuItem(
                              menuItems[index],
                              index,
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // ==================================
                        // EXPLORAR CERCA DE MÍ
                        // ==================================

                        InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UnidadesCerca(),
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF142838),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFF4BA8C8),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF2DAFD2).withOpacity(0.14),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // ICONO UBICACIÓN
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF223D50),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 23,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // TEXTO
                                Expanded(
                                  child: Text(
                                    'Explorar cerca de mí',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.95),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),

                                // FLECHA
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF1E4054)
                                        .withOpacity(0.95),
                                    border: Border.all(
                                      color: const Color(0xFF4BA8C8),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 23,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),
                      ],
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
}

// ==============================================
// MODELO DE DATOS DEL MENÚ
// ==============================================

class MenuItem {
  final String title;
  final String description;
  final Widget? screen;
  final String? url;
  final String icon;
  final Color accent;

  MenuItem({
    required this.title,
    required this.description,
    this.screen,
    this.url,
    required this.icon,
    required this.accent,
  });
}

// ==============================================
// CLIPPER DE ONDA INFERIOR
// ==============================================

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.70)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.88,
        size.width * 0.72,
        size.height,
      )
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(
    covariant CustomClipper<Path> oldClipper,
  ) =>
      false;
}
