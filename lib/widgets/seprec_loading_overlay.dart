import 'package:flutter/material.dart';

class SeprecLoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;

  const SeprecLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  State<SeprecLoadingOverlay> createState() => _SeprecLoadingOverlayState();
}

class _SeprecLoadingOverlayState extends State<SeprecLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (widget.isLoading)
          Positioned.fill(
            child: Container(
              color: const Color(0xE6080D1C),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Imagen animada
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _opacityAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF14243A),
                                border: Border.all(
                                  color: const Color(0xFF50E4D6),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF50E4D6)
                                        .withValues(alpha: 0.24),
                                    blurRadius: 20,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/Aplicacion-MOVIL-SEPREC-SEPREC.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'SEPREC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Procesando información...',
                      style: TextStyle(
                        color: Color(0xFF50E4D6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const SizedBox(
                      width: 135,
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        backgroundColor: Color(0xFF26374B),
                        valueColor: AlwaysStoppedAnimation(
                          Color(0xFF50E4D6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Por favor, espere un momento',
                      style: TextStyle(
                        color: Color(0xFF9EACC0),
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
