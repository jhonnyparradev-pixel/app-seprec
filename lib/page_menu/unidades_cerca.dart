import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:seprec/page_menu/api_config.dart';
import '../main.dart';
import '../model/model_empresa.dart';
import 'mas_informacio_empresa.dart';
import '../widgets/seprec_pagination_controls.dart';
import '../widgets/seprec_loading_overlay.dart';
import '../widgets/seprec_service_state.dart';
import '../widgets/seprec_tech_background.dart';

class UnidadesCerca extends StatefulWidget {
  @override
  _UnidadesCercaState createState() => _UnidadesCercaState();
}

class _UnidadesCercaState extends State<UnidadesCerca> {
  final TextEditingController _controller = TextEditingController();
  String _tipoFiltro = 'cerca de mí';
  List<Empresa> _resultados = [];
  String? _errorCarga;
  bool _cargando = false;
  Position? _ubicacionUsuario;
  String _ubicacionTexto = '';
  String _departamentoUsuario = '';
  int _paginaActual = 1;
  final int _limiteResultados = 10;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_controller.text.isEmpty || _errorCarga != null) {
      setState(() {
        if (_controller.text.isEmpty) {
          _resultados.clear();
          _paginaActual = 1;
        }
        _errorCarga = null;
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
      permission = await Geolocator.checkPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await _obtenerUbicacion();
    } else if (permission == LocationPermission.deniedForever) {
      _mostrarSnackBar(
          'Los permisos de ubicación están denegados de forma permanente.');
    }
  }

  Future<void> _obtenerUbicacion() async {
    try {
      _ubicacionUsuario = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await _obtenerCiudadYPais(
          _ubicacionUsuario!.latitude, _ubicacionUsuario!.longitude);
    } catch (e) {
      _mostrarSnackBar('Error al obtener la ubicación: $e');
    }
  }

  Future<void> _obtenerCiudadYPais(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          _ubicacionTexto =
              '${placemarks.first.locality}, ${placemarks.first.country}';
          _departamentoUsuario = placemarks.first.locality?.toLowerCase() ?? '';
        });
      }
    } catch (e) {
      _mostrarSnackBar('Error al obtener la dirección');
    }
  }

  Future<void> _buscar() async {
    setState(() {
      _cargando = true;
      _resultados.clear();
      _errorCarga = null;
    });

    try {
      List<Empresa> empresas;
      if (_tipoFiltro == 'cerca de mí' && _ubicacionUsuario != null) {
        empresas = await buscarEmpresas(
          _controller.text,
          'geo',
          lat: _ubicacionUsuario!.latitude,
          lon: _ubicacionUsuario!.longitude,
          limite: _limiteResultados,
          pagina: _paginaActual,
        );
      } else {
        empresas = await buscarEmpresas(
          _controller.text,
          _tipoFiltro,
          limite: _limiteResultados,
          pagina: _paginaActual,
        );
      }
      if (!mounted) return;
      setState(() {
        _resultados = empresas;
      });
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

  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _siguientePagina() {
    setState(() {
      _paginaActual++;
      _buscar();
    });
  }

  void _paginaAnterior() {
    if (_paginaActual > 1) {
      setState(() {
        _paginaActual--;
        _buscar();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarForeground,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Buscar Empresas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                right:
                    16.0), // Espaciado opcional para separar el logo del borde
            child: Image.asset(
              'assets/Aplicacion-MOVIL-SEPREC-SEPREC.png', // Cambia la ruta al logo que quieres usar
              height: 40, // Puedes ajustar el tamaño
              width: 40,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SeprecTechBackground(
          child: SeprecLoadingOverlay(
            isLoading: _cargando,
            child: Stack(
              children: [
                /*Positioned.fill(
                child: Image.asset(
                  'assets/images/APP_FONDO_GENERAL1.png',
                  fit: BoxFit.cover,
                ),
              ),*/
                Column(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // UBICACIÓN ACTUAL - COMPACTA
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF102B3D),
                                  Color(0xFF061523),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    const Color(0xFF50E4D6).withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFF50E4D6),
                                  size: 18,
                                ),
                                const SizedBox(width: 7),
                                const Text(
                                  'Ubicación:',
                                  style: TextStyle(
                                    color: Color(0xFF70CFC4),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    _ubicacionTexto.isNotEmpty
                                        ? _ubicacionTexto
                                        : 'Obteniendo ubicación...',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _ubicacionTexto.isNotEmpty
                                      ? Icons.check_circle_rounded
                                      : Icons.radar_rounded,
                                  color: _ubicacionTexto.isNotEmpty
                                      ? const Color(0xFF50E4A5)
                                      : const Color(0xFFE8B86D),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
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
                                      const Color(0xFF30BFA5).withOpacity(0.14),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Busca actividades económicas cerca de tu ubicación',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFD0E3DA),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildSearchInput(),
                                const SizedBox(height: 12),
                                _buildSearchButton(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      flex: 3,
                      child: _buildResultsList(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SeprecPaginationControls(
                        currentPage: _paginaActual,
                        onPrevious: _paginaActual > 1 ? _paginaAnterior : null,
                        onNext:
                            _resultados.length < 9 ? null : _siguientePagina,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return TextField(
      controller: _controller,
      cursorColor: const Color(0xFF50E4D6),
      style: TextStyle(
        color: Colors.white,
        fontSize: isMobile ? 15 : 17,
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF50E4D6),
          size: 22,
        ),
        labelText: 'Actividad económica o rubro',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: const TextStyle(color: Color(0xFFD0E3DA)),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF50E4D6),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: const Color(0xFF080D1C).withOpacity(0.82),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF50E4D6),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF50E4D6),
            width: 2,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.clear,
            color: Color(0xFF50E4D6),
            size: isMobile ? 22 : 24,
          ),
          onPressed: () {
            _controller.clear();
            setState(() {
              _resultados.clear();
            });
          },
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 18,
          vertical: isMobile ? 16 : 18,
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SizedBox(
      width: double.infinity,
      height: isMobile ? 46 : 52,
      child: ElevatedButton.icon(
        icon: const Icon(
          Icons.search_rounded,
          size: 20,
        ),
        label: Text(
          'Buscar',
          style: TextStyle(
            fontSize: isMobile ? 15 : 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: _buscar,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF087C76),
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: const Color(0xFF30BFA5).withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RefreshIndicator(
        onRefresh: _buscar,
        child: _errorCarga != null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SeprecServiceState(
                    isError: true,
                    onRetry: _buscar,
                  ),
                ],
              )
            : _resultados.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SeprecServiceState(
                        details: 'No se encontraron empresas para la búsqueda.',
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _resultados.length,
                    itemBuilder: (_, index) {
                      return _buildEmpresaCard(_resultados[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmpresaCard(Empresa empresa) {
    final bool inhabilitada = empresa.codigo == '1';

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 4,
      ),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF54758D),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.business,
                  color: Color(0xFF50E4D6),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    empresa.razonSocial,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // INFO
            _infoItem(
              Icons.location_on_outlined,
              'Departamento',
              empresa.nombreDepartamento,
            ),

            const SizedBox(height: 8),

            _infoItem(
              Icons.verified_user_outlined,
              'Estado',
              empresa.estadoActualizacionNombre,
            ),

            const SizedBox(height: 14),

            // STATUS / BUTTON
            if (inhabilitada)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B86D).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE8B86D),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFE8B86D),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Inhabilitada para el ejercicio del comercio',
                        style: TextStyle(
                          color: Color(0xFFE8B86D),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.icon,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MasInfoEmpresa(
                          id: empresa.id,
                          idEstablecimiento: empresa.idEstablecimiento,
                        ),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ver detalle',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.header,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

Future<List<Empresa>> buscarEmpresas(String filtro, String tipoFiltro,
    {double? lat, double? lon, int limite = 10, int pagina = 1}) async {
  final url = ApiConfig.buscarEmpresasGeo(
    filtro: filtro,
    tipoFiltro: tipoFiltro,
    lat: lat,
    lon: lon,
    limite: limite,
    pagina: pagina,
  );

  final response = await http.get(Uri.parse(url));
  print('Código de estado de respuesta: ${response.statusCode}');

  if (response.statusCode != 200) {
    throw Exception('Error al cargar empresas: ${response.statusCode}');
  }

  print('Respuesta completa: ${response.body}');
  final jsonResponse = json.decode(response.body);
  print('Estructura JSON decodificada: $jsonResponse');

  if (jsonResponse['datos'] != null && jsonResponse['datos']['filas'] is List) {
    final filasJson = jsonResponse['datos']['filas'];
    print('Contenido de filasJson: $filasJson');
    final empresas =
        List<Empresa>.from(filasJson.map((data) => Empresa.fromJson(data)));
    print('Lista de empresas final: $empresas');
    return empresas;
  }

  throw Exception('Estructura de respuesta inesperada');
}
