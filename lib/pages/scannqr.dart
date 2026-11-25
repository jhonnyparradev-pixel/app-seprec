import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../page_menu.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  _BarcodeScannerState createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner>
    with SingleTickerProviderStateMixin {
  static const _dialogActionColor = Color(0xFF50E4D6);
  static const _accentColor = Color(0xFF50E4D6);
  static const _buttonTealColor = Color(0xFF108A8A);

  final ImagePicker _imagePicker = ImagePicker();
  late final MobileScannerController controller;
  late final AnimationController _scanLineController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  Future<void> _toggleTorch() async {
    HapticFeedback.selectionClick();
    try {
      await controller.toggleTorch();
    } catch (error) {
      if (mounted) _showErrorDialog(error.toString());
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La lectura de imágenes no está disponible en web.'),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();

    try {
      await controller.stop();
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (image == null) {
        await controller.start();
        return;
      }

      final capture = await controller.analyzeImage(image.path);
      if (capture == null || capture.barcodes.isEmpty) {
        await controller.start();
        _showNoBarcodeDialog();
        return;
      }

      final openedResult = await _handleDetection(capture);
      if (!openedResult && mounted) await controller.start();
    } catch (error) {
      if (!mounted) return;
      try {
        await controller.start();
      } catch (restartError) {
        _showErrorDialog(restartError.toString());
      }
      _showErrorDialog(error.toString());
    }
  }

  void _showNoBarcodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Código no encontrado'),
        content: const Text('Selecciona una imagen que contenga un código.'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: _dialogActionColor,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<bool> _handleDetection(BarcodeCapture barcodeCapture) async {
    if (_isProcessing) return false;
    _isProcessing = true;

    final barcodeValue = barcodeCapture.barcodes.isEmpty
        ? null
        : barcodeCapture.barcodes.first.rawValue;

    if (barcodeValue != null && barcodeValue.contains('seprec.gob.bo')) {
      final uri = Uri.tryParse(barcodeValue);
      if (uri == null) {
        if (mounted) _showInvalidUrlDialog();
        _isProcessing = false;
        return false;
      }

      HapticFeedback.mediumImpact();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => PageMenu()),
          (Route<dynamic> route) => false,
        );
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    } else {
      if (mounted) _showInvalidUrlDialog();
      _isProcessing = false;
      return false;
    }
  }

  void _showInvalidUrlDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('URL inválida'),
          content: const Text('El código escaneado no es una URL válida.'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: _dialogActionColor,
              ),
              child: const Text('Aceptar'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: _dialogActionColor,
              ),
              child: const Text('Aceptar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final frameSize = math.min(
            math.min(width * 0.72, height * 0.30),
            460.0,
          );
          final scanWindow = Rect.fromCenter(
            center: Offset(width / 2, height * 0.45),
            width: frameSize,
            height: frameSize,
          );

          return ColoredBox(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: controller,
                  scanWindow: kIsWeb ? null : scanWindow,
                  onDetect: (capture) async {
                    await _handleDetection(capture);
                  },
                  errorBuilder: (context, error) {
                    final message = switch (error.errorCode) {
                      MobileScannerErrorCode.permissionDenied =>
                        'Permiso de cámara denegado. Activa la cámara en los ajustes de la aplicación.',
                      MobileScannerErrorCode.unsupported =>
                        'Este dispositivo no permite escanear códigos.',
                      MobileScannerErrorCode.controllerUninitialized =>
                        'La cámara todavía no está lista.',
                      _ => error.errorDetails?.message ??
                          'No se pudo iniciar la cámara.',
                    };

                    return ColoredBox(
                      color: Colors.black,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.videocam_off_outlined,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: () async {
                                  try {
                                    await controller.start();
                                  } catch (error) {
                                    if (mounted) {
                                      _showErrorDialog(error.toString());
                                    }
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: _accentColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color:
                                          _accentColor.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Reintentar',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Overlay con viñeta + marco de escaneo animado
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _scanLineController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _ScanWindowPainter(
                            scanWindow: scanWindow,
                            scanProgress: _scanLineController.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SafeArea(
                  child: Stack(
                    children: [
                      // Barra superior con botones flotantes
                      Positioned(
                        top: 8,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ScannerControlButton(
                              icon: Icons.arrow_back_rounded,
                              onPressed: widget.onBack ??
                                  () => Navigator.of(context).maybePop(),
                            ),
                            ValueListenableBuilder(
                              valueListenable: controller,
                              builder: (context, state, _) {
                                final isTorchOn =
                                    state.torchState == TorchState.on;
                                final isUnavailable =
                                    state.torchState == TorchState.unavailable;
                                return _ScannerControlButton(
                                  icon: isTorchOn
                                      ? Icons.flashlight_on_rounded
                                      : Icons.flashlight_off_rounded,
                                  active: isTorchOn,
                                  onPressed:
                                      isUnavailable ? null : _toggleTorch,
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Chip indicador "Escaneando…" y LOGO SEPREC
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 64),
                          child: Column(
                            children: [
                              _StatusChip(
                                label: 'Escaneando',
                                color: _accentColor,
                              ),
                              const SizedBox(height: 20),
                              // Logo de SEPREC
                              Container(
                                height: 72,
                                width: 72,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Image.asset(
                                    'assets/aplicacion-icon.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.verified_user_rounded,
                                        color: _accentColor,
                                        size: 30,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Texto de ayuda inferior (Ajustado al no tener el botón)
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 40, // Antes era 104, ahora está más abajo
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Esta opción te ayudará a escanear documentos\ny ver la validez del mismo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black87,
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    controller.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────
// Botón flotante con estilo "glass"
// ─────────────────────────────────────────────────────────────
class _ScannerControlButton extends StatelessWidget {
  const _ScannerControlButton({
    required this.icon,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? const Color(0xFF50E4D6).withValues(alpha: 0.22)
            : Colors.black.withValues(alpha: 0.35),
        border: Border.all(
          color: active
              ? const Color(0xFF50E4D6).withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: active ? const Color(0xFF50E4D6) : Colors.white,
          size: 26,
        ),
        style: IconButton.styleFrom(
          disabledForegroundColor: Colors.white38,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Chip de estado con punto pulsante
// ─────────────────────────────────────────────────────────────
class _StatusChip extends StatefulWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  State<_StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<_StatusChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final scale = 0.75 + (_pulse.value * 0.25);
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(
                    alpha: 0.5 + (_pulse.value * 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(
                        alpha: 0.4 + (_pulse.value * 0.4),
                      ),
                      blurRadius: 6 * scale,
                      spreadRadius: 1.5 * scale,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            widget.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Pintor del overlay: viñeta + marco con esquinas + línea animada
// ─────────────────────────────────────────────────────────────
class _ScanWindowPainter extends CustomPainter {
  _ScanWindowPainter({
    required this.scanWindow,
    required this.scanProgress,
  });

  final Rect scanWindow;
  final double scanProgress;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 24.0;
    final rrect = RRect.fromRectAndRadius(
      scanWindow,
      const Radius.circular(radius),
    );

    final overlayPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(rrect);

    final overlayPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: [
          Colors.black.withValues(alpha: 0.55),
          Colors.black.withValues(alpha: 0.82),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(overlayPath, overlayPaint);

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.12),
    );

    final cornerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF50E4D6);

    final cornerLength = scanWindow.width * 0.16;
    final left = scanWindow.left;
    final top = scanWindow.top;
    final right = scanWindow.right;
    final bottom = scanWindow.bottom;

    // Top-left
    canvas.drawLine(Offset(left, top + radius),
        Offset(left, top + cornerLength), cornerPaint);
    canvas.drawLine(Offset(left + radius, top),
        Offset(left + cornerLength, top), cornerPaint);

    // Top-right
    canvas.drawLine(Offset(right - cornerLength, top),
        Offset(right - radius, top), cornerPaint);
    canvas.drawLine(Offset(right, top + radius),
        Offset(right, top + cornerLength), cornerPaint);

    // Bottom-left
    canvas.drawLine(Offset(left, bottom - cornerLength),
        Offset(left, bottom - radius), cornerPaint);
    canvas.drawLine(Offset(left + radius, bottom),
        Offset(left + cornerLength, bottom), cornerPaint);

    // Bottom-right
    canvas.drawLine(Offset(right - cornerLength, bottom),
        Offset(right - radius, bottom), cornerPaint);
    canvas.drawLine(Offset(right, bottom - cornerLength),
        Offset(right, bottom - radius), cornerPaint);

    final lineY = scanWindow.top +
        (scanWindow.height * scanProgress).clamp(0.0, scanWindow.height);
    final lineRect = Rect.fromLTWH(
      scanWindow.left + 6,
      lineY - 1.5,
      scanWindow.width - 12,
      3,
    );

    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF50E4D6).withValues(alpha: 0.0),
          const Color(0xFF50E4D6).withValues(alpha: 0.9),
          const Color(0xFF50E4D6).withValues(alpha: 0.0),
        ],
      ).createShader(lineRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lineRect.left, lineRect.top - 3, lineRect.width, 9),
        const Radius.circular(6),
      ),
      glowPaint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(lineRect, const Radius.circular(2)),
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF50E4D6).withValues(alpha: 0.0),
            const Color(0xFF8FF5EB),
            const Color(0xFF50E4D6).withValues(alpha: 0.0),
          ],
        ).createShader(lineRect),
    );
  }

  @override
  bool shouldRepaint(_ScanWindowPainter old) =>
      old.scanWindow != scanWindow || old.scanProgress != scanProgress;
}
