import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import '../main.dart';
import '../model/model_info_tramite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_config.dart';
import 'api_service.dart';
import '../widgets/seprec_loading_overlay.dart';
import '../widgets/seprec_service_state.dart';
import '../widgets/seprec_tech_background.dart';

class InfoTramitePage extends StatefulWidget {
  final String id;

  const InfoTramitePage({super.key, required this.id});

  @override
  State<InfoTramitePage> createState() => _InfoTramitePageState();
}

class _InfoTramitePageState extends State<InfoTramitePage> {
  late Future<ModelInfoTramite> _tramiteFuture;

  @override
  void initState() {
    super.initState();
    _tramiteFuture = fetchTramiteInfo(widget.id);
  }

  Future<void> _recargarTramite() async {
    final future = fetchTramiteInfo(widget.id);
    setState(() {
      _tramiteFuture = future;
    });
    await future.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1C),
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarForeground,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Información del Trámite',
          style: TextStyle(fontWeight: FontWeight.bold),
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;

            return SeprecTechBackground(
              child: FutureBuilder<ModelInfoTramite>(
                future: _tramiteFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SeprecLoadingOverlay(
                      isLoading: true,
                      child: SizedBox.expand(),
                    );
                  }

                  if (snapshot.hasError) {
                    return RefreshIndicator(
                      onRefresh: _recargarTramite,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SeprecServiceState(
                            isError: true,
                            onRetry: _recargarTramite,
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const SeprecServiceState(
                      details: 'No se encontró información del trámite.',
                    );
                  }

                  final info = snapshot.data!;
                  final title =
                      "Trámite ${info.datos.id} - ${info.datos.tramite}";

                  return RefreshIndicator(
                    onRefresh: _recargarTramite,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 40 : 16,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 24 : 16,
                              vertical: isTablet ? 18 : 14,
                            ),
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
                                  color:
                                      const Color(0xFF30BFA5).withOpacity(0.16),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isTablet ? 22 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.25,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSection(
                              'CONCEPTO', info.datos.concepto, isTablet),
                          _buildSection(
                              'MARCO LEGAL', info.datos.marcoLegal, isTablet),
                          _buildSection(
                              'REQUISITOS', info.datos.requisitos, isTablet),
                          _buildSection('PROCEDIMIENTO',
                              info.datos.procedimiento, isTablet),
                          _buildSection('DOCUMENTO',
                              info.datos.documentoEmitido, isTablet),
                          _buildSection('PLAZO', info.datos.plazo, isTablet),
                          _buildSection('COSTO', info.datos.costo, isTablet),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: isTablet ? 400 : double.infinity,
                            height: isTablet ? 70 : 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF087C76),
                                foregroundColor: Colors.white,
                                elevation: 6,
                                shadowColor:
                                    const Color(0xFF30BFA5).withOpacity(0.35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                _launchUrl(
                                  'https://tramites.seprec.gob.bo/#/login',
                                );
                              },
                              child: Text(
                                "Iniciar trámite",
                                style: TextStyle(
                                  fontSize: isTablet ? 20 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<ModelInfoTramite> fetchTramiteInfo(String id) async {
    final url = ApiConfig.informacionTramites(id);
    final response = await http.get(Uri.parse(url));

    imprimirConsumoServicio(
      url: url,
      statusCode: response.statusCode,
      respuesta: response.body,
      parametros: {
        'id': id,
      },
    );

    if (response.statusCode == 200) {
      return modelInfoTramiteFromJson(response.body);
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  Widget _buildSection(String title, String content, bool isTablet) {
    return _ExpandableSection(
      title: title,
      content: content,
      isTablet: isTablet,
    );
  }
}

class _ExpandableSection extends StatefulWidget {
  final String title;
  final String content;
  final bool isTablet;

  const _ExpandableSection({
    required this.title,
    required this.content,
    required this.isTablet,
  });

  @override
  State<_ExpandableSection> createState() => __ExpandableSectionState();
}

class __ExpandableSectionState extends State<_ExpandableSection> {
  IconData get _sectionIcon {
    switch (widget.title) {
      case 'CONCEPTO':
        return Icons.info_outline_rounded;
      case 'MARCO LEGAL':
        return Icons.account_balance_outlined;
      case 'REQUISITOS':
        return Icons.fact_check_outlined;
      case 'PROCEDIMIENTO':
        return Icons.route_outlined;
      case 'DOCUMENTO':
        return Icons.description_outlined;
      case 'PLAZO':
        return Icons.schedule_rounded;
      case 'COSTO':
        return Icons.payments_outlined;
      default:
        return Icons.article_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF087C76),
            Color(0xFF061523),
          ],
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
      child: ExpansionTile(
        iconColor: const Color(0xFF50E4D6),
        collapsedIconColor: const Color(0xFF50E4D6),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        leading: Container(
          width: widget.isTablet ? 46 : 38,
          height: widget.isTablet ? 46 : 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF102B3D).withOpacity(0.55),
            border: Border.all(
              color: const Color(0xFF50E4D6).withOpacity(0.55),
              width: 1,
            ),
          ),
          child: Icon(
            _sectionIcon,
            color: const Color(0xFF50E4D6),
            size: widget.isTablet ? 23 : 20,
          ),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: widget.isTablet ? 18 : 13,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.all(
              widget.isTablet ? 16 : 10,
            ),
            child: Html(
              data: widget.content,
              style: {
                "p": Style(
                  textAlign: TextAlign.justify,
                  color: AppColors.textPrimary,
                  fontSize: FontSize(
                    widget.isTablet ? 16 : 13,
                  ),
                ),
                "li": Style(
                  textAlign: TextAlign.justify,
                  color: AppColors.textPrimary,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
