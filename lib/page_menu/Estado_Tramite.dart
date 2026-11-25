import 'dart:convert';

import 'package:flutter/material.dart';

import '../main.dart';
import '../model/model_tramite.dart';
import 'api_config.dart';
import 'api_service.dart';
import '../widgets/seprec_loading_overlay.dart';
import '../widgets/seprec_service_state.dart';
import '../widgets/seprec_tech_background.dart';

class EstadoTramite extends StatefulWidget {
  @override
  _EstadoTramiteState createState() => _EstadoTramiteState();
}

const background = Color(0xFF1F3A3A);
const panel = Color(0xFF2F5D50);
const card = Color(0xFF5E8F78);
const textPrimary = Color(0xFFEAF5F0);
const header = Color(0xFF7FBF9F);

class _EstadoTramiteState extends State<EstadoTramite> {
  final TextEditingController _controller = TextEditingController();
  String _resultado = '';
  List<Bitacora> _historial = [];
  bool _cargando = false;
  bool _haBuscado = false;
  String? _errorCarga;

  // Variables para los datos del trámite
  String _tramiteNumero = '';
  String _matricula = '-';
  String _nombre = '-';
  String _fechaIngreso = '-';
  String _estadoTramite = '-';

  Future<void> _buscarTramite(String codigo) async {
    final apiService = ApiService();
    final url = ApiConfig.buscarTramite(codigo);

    setState(() {
      _cargando = true;
      _haBuscado = true;
      _errorCarga = null;
      _historial.clear();
    });

    try {
      final data = await apiService.get(url);

      if (data == null) {
        if (mounted) {
          setState(() {
            _errorCarga = 'No se recibió una respuesta del servicio.';
          });
        }
        return;
      }

      final ModelTramite tramite = modelTramiteFromJson(json.encode(data));

      if (tramite.finalizado && tramite.datos != null) {
        if (!mounted) return;
        setState(() {
          _resultado = tramite.mensaje;
          _historial = tramite.datos!.bitacoras ?? [];

          // Extraer datos con manejo seguro de nulos
          _tramiteNumero = tramite.datos!.nombre != null
              ? "Trámite ${tramite.datos!.nombre.codigo} - ${tramite.datos!.nombre.nombre}"
              : '-';
          _matricula = tramite.datos!.empresa?.matricula ?? '-';
          _nombre = tramite.datos!.empresa?.razonSocial ?? '-';

          // Manejo de fecha segura
          DateTime? fechaCreacion =
              DateTime.tryParse(tramite.datos!.fechaCreacion ?? '');
          _fechaIngreso = fechaCreacion != null
              ? fechaCreacion.toLocal().toString().split(' ')[0]
              : '-';
          _estadoTramite = tramite.datos!.estado ?? '-';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorCarga = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _clearText() {
    setState(() {
      _controller.clear();
      _historial.clear();
      _resultado = '';
      _haBuscado = false;
      _errorCarga = null;
      _tramiteNumero = '';
      _matricula = '-';
      _nombre = '-';
      _fechaIngreso = '-';
      _estadoTramite = '-';
    });
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
          'Estado del Trámite',
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
              child: SeprecLoadingOverlay(
                isLoading: _cargando,
                child: RefreshIndicator(
                  onRefresh: () {
                    if (_controller.text.trim().isNotEmpty) {
                      return _buscarTramite(_controller.text);
                    }
                    return Future<void>.value();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 20,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        // INPUT
                        TextField(
                          controller: _controller,
                          cursorColor: const Color(0xFF50E4D6),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            labelText: "Código del trámite",
                            labelStyle: const TextStyle(
                              color: Color(0xFFD0E3DA),
                            ),
                            filled: true,
                            fillColor:
                                const Color(0xFF080D1C).withOpacity(0.82),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF50E4D6),
                              size: 22,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Color(0xFF50E4D6),
                                size: 22,
                              ),
                              onPressed: _clearText,
                            ),
                            isDense: false,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF50E4D6),
                                width: 1.2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF50E4D6),
                                width: 1.2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF50E4D6),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // BOTÓN
                        SizedBox(
                          width: isTablet ? 300 : double.infinity,
                          height: isTablet ? 60 : 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_controller.text.isNotEmpty) {
                                _buscarTramite(_controller.text);
                              } else {
                                _mostrarError('Ingresa un código');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF087C76),
                              elevation: 6,
                              shadowColor:
                                  const Color(0xFF30BFA5).withOpacity(0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  size: 22,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Buscar',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // INFO DEL TRÁMITE
                        if (_historial.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isTablet ? 20 : 14),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _tramiteNumero,
                                  style: TextStyle(
                                    fontSize: isTablet ? 20 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _infoRow("Matrícula", _matricula, isTablet,
                                    Icons.badge_outlined),
                                _infoRow("Nombre", _nombre, isTablet,
                                    Icons.business_outlined),
                                _infoRow("Fecha", _fechaIngreso, isTablet,
                                    Icons.calendar_today_outlined),
                                _infoRow("Estado", _estadoTramite, isTablet,
                                    Icons.verified_outlined),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        // HISTORIAL
                        if (_errorCarga != null)
                          SeprecServiceState(
                            isError: true,
                            onRetry: () => _buscarTramite(_controller.text),
                          )
                        else if (_historial.isEmpty && _haBuscado)
                          const SeprecServiceState(
                            details:
                                'No se encontró información para ese código.',
                          )
                        else if (_historial.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _historial.length,
                            itemBuilder: (context, index) {
                              final bitacora = _historial[index];
                              final isLast = index == _historial.length - 1;

                              return SizedBox(
                                height: 66,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 42,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 34,
                                            height: 34,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(
                                                colors: [
                                                  Color(0xFF50E4D6),
                                                  Color(0xFF087C76),
                                                ],
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          if (!isLast)
                                            Expanded(
                                              child: Container(
                                                width: 2,
                                                color: const Color(0xFF50E4D6),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              bitacora.operacion ?? '-',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isTablet ? 16 : 13,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              bitacora.fecha
                                                  .toLocal()
                                                  .toString()
                                                  .split('.')
                                                  .first,
                                              style: const TextStyle(
                                                color: Color(0xFF50E4D6),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
    bool isTablet,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color: const Color(0xFF50E4D6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: $value",
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 16 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
