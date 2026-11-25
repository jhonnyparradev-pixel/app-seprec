import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart'; // 👈 AppColors
import '../widgets/seprec_tech_background.dart';

class MasInfo extends StatefulWidget {
  @override
  State<MasInfo> createState() => _MasInfoState();
}

class _MasInfoState extends State<MasInfo> {

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      /// 🔹 APPBAR
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarForeground,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'SEPREC',
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

      /// 🔹 BODY CON IMAGEN
      body: Stack(
        children: [

          /// FONDO HEREDADO
          const Positioned.fill(
            child: SeprecTechBackground(
              child: SizedBox.shrink(),
            ),
          ),

          /// 🔹 CONTENIDO
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [

              const SizedBox(height: 10),

              _buildInfoCard(),

              const SizedBox(height: 16),

              _buildSectionTitle('Objetivos Estratégicos Institucionales'),

              const SizedBox(height: 10),

              ..._buildObjectives(),

              const SizedBox(height: 10),

              /// 🔹 PRIVACIDAD
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    const url =
                        'https://www.seprec.gob.bo/index.php/politicas-de-privacidad/';
                    _launchUrl(url);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, color: AppColors.icon, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        'Política de Privacidad',
                        style: TextStyle(
                          color: AppColors.icon,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 CARD PRINCIPAL
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Creación del SEPREC',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El Servicio Plurinacional de Registro de Comercio (SEPREC) es la entidad pública descentralizada encargada de administrar el Registro de Comercio en Bolivia.',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFFD0E3DA),
              ),
              textAlign: TextAlign.justify,
            ),
          ],
      ),
    );
  }

  /// 🔹 TITULO SECCIÓN
  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF075B58),
            Color(0xFF082536),
            Color(0xFF061523),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF54758D),
          width: 1.2,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// 🔹 OBJETIVOS
  List<Widget> _buildObjectives() {
    final objectivesData = [
      {
        'text':
        '1. Constituir al SEPREC como entidad referente en el Registro de Comercio.',
        'image': 'assets/images/Aplicacion-MOVIL-SEPREC-33.png',
      },
      {
        'text':
        '2. Implementar un sistema integral de Registro de Comercio.',
        'image': 'assets/images/Aplicacion-MOVIL-SEPREC-34.png',
      },
      {
        'text':
        '3. Desarrollar el Programa de Educación Empresarial.',
        'image': 'assets/images/Aplicacion-MOVIL-SEPREC-35.png',
      },
      {
        'text':
        '4. Establecer mecanismos de control eficientes.',
        'image': 'assets/images/Aplicacion-MOVIL-SEPREC-36.png',
      },
    ];

    return objectivesData
        .map((data) => _buildObjectiveCard(data['image']!, data['text']!))
        .toList();
  }

  /// 🔹 CARD OBJETIVO
  Widget _buildObjectiveCard(String imagePath, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF075B58),
            Color(0xFF082536),
            Color(0xFF061523),
          ],
          stops: [0.0, 0.65, 1.0],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF54758D),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(imagePath),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFFD0E3DA),
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ],
      ),
    );
  }
}