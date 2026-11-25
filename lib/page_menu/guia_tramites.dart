import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../main.dart';
import '../model/model_tramite_list.dart';
import 'api_config.dart';
import 'api_service.dart';
import 'mas_info_tramite.dart';
import '../widgets/seprec_loading_overlay.dart';
import '../widgets/seprec_service_state.dart';
import '../widgets/seprec_tech_background.dart';

class GuiaTramites extends StatefulWidget {
  @override
  _GuiaTramitesState createState() => _GuiaTramitesState();
}

class _GuiaTramitesState extends State<GuiaTramites> {
  late Future<ModelTramitelist> _tramiteListFuture;
  Future<ModelTramitelist> fetchTramites(int pagina, int limite,
      {String filtro = ""}) async {
    final apiService = ApiService();
    final url = ApiConfig.listarTramites(pagina, limite, filtro: filtro);

    final data = await apiService.get(url);

    if (data == null) {
      throw Exception('No se recibió una respuesta del servicio de trámites.');
    }

    return modelTramitelistFromJson(json.encode(data));
  }

  @override
  void initState() {
    super.initState();
    _tramiteListFuture = fetchTramites(1, 200);
  }

  Future<void> _recargarTramites() async {
    final future = fetchTramites(1, 200);
    setState(() {
      _tramiteListFuture = future;
    });
    await future.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1C),
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarForeground,
        elevation: 0,
        title: const Text(
          'Lista de Trámites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
              child: FutureBuilder<ModelTramitelist>(
                future: _tramiteListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SeprecLoadingOverlay(
                      isLoading: true,
                      child: SizedBox.expand(),
                    );
                  }

                  if (snapshot.hasError) {
                    return RefreshIndicator(
                      onRefresh: _recargarTramites,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SeprecServiceState(
                            isError: true,
                            onRetry: _recargarTramites,
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.data == null || !snapshot.data!.finalizado) {
                    return const SeprecServiceState(
                      details: 'No hay trámites disponibles.',
                    );
                  }

                  final tramites = snapshot.data!.datos.filas;
                  if (tramites.isEmpty) {
                    return const SeprecServiceState(
                      details: 'No hay trámites disponibles.',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _recargarTramites,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 30 : 10,
                        vertical: 10,
                      ),
                      child: isTablet
                          ? GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 👈 2 columnas en tablet
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 3,
                              ),
                              itemCount: tramites.length,
                              itemBuilder: (context, index) {
                                return _buildCard(tramites, index, isTablet);
                              },
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: tramites.length,
                              itemBuilder: (context, index) {
                                return _buildCard(tramites, index, isTablet);
                              },
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

  Widget _buildCard(tramites, int index, bool isTablet) {
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
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: EdgeInsets.all(isTablet ? 12 : 10),
        title: Text(
          'Trámite - ${tramites[index].id}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: isTablet ? 18 : 14,
          ),
        ),
        subtitle: Text(
          tramites[index].tramite,
          style: TextStyle(
            fontSize: isTablet ? 16 : 13,
            color: Colors.white,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.white,
          size: isTablet ? 30 : 24,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InfoTramitePage(
                id: tramites[index].id.toString(),
              ),
            ),
          );
        },
      ),
    );
  }
}
