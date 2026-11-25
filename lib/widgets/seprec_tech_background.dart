import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

// Paleta original (sin cambios)
const _teal = Color(0xFF30BFA5);
const _tealLight = Color(0xFF35C6B0);
const _blue = Color(0xFF215B82);
const _grid = Color(0xFF50E4D6);
const _tau = math.pi * 2;

/// Fondo tecnológico SEPREC.
///
/// - Anillo central discreto (anillos finos que giran lento y marcas).
/// - Logo SEPREC completo en el centro: isotipo en formato circuito (capas que
///   flotan y pulso en el contorno), texto SEPREC, franja tricolor y subtítulo.
/// - Circuitos que nacen del anillo y se abren hacia los bordes.
/// - Chips y matrices de puntos discretos.
/// - Pulsos de luz que viajan por los circuitos (suaves).
///
/// [focus] es la posición del anillo (0..1). Por defecto, en el centro.
/// Con [animated] = false el fondo queda estático.
class SeprecTechBackground extends StatefulWidget {
  final Widget child;
  final bool animated;
  final Offset focus;

  const SeprecTechBackground({
    super.key,
    required this.child,
    this.animated = true,
    this.focus = const Offset(0.5, 0.5),
  });

  @override
  State<SeprecTechBackground> createState() => _SeprecTechBackgroundState();
}

class _SeprecTechBackgroundState extends State<SeprecTechBackground>
    with SingleTickerProviderStateMixin {
  // Ciclo largo: todas las rotaciones usan múltiplos enteros, el bucle es continuo.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  void _syncAnimation() {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (widget.animated && !reduceMotion) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant SeprecTechBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pulses = widget.animated && !MediaQuery.disableAnimationsOf(context);

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        // Fondo principal
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF071D2D),
                Color(0xFF081727),
                Color(0xFF040E1A),
                Color(0xFF020812),
              ],
              stops: [0.0, 0.38, 0.72, 1.0],
            ),
          ),
        ),

        // Iluminaciones de esquina
        Positioned(
          top: -180,
          right: -150,
          child: _glow(430, const [
            Color(0x3330BFA5),
            Color(0x1530BFA5),
            Colors.transparent,
          ]),
        ),
        Positioned(
          bottom: -190,
          left: -170,
          child: _glow(440, const [
            Color(0x22215B82),
            Color(0x10215B82),
            Colors.transparent,
          ]),
        ),

        // Capa estática: cuadrícula + circuitos (se pinta una sola vez)
        Positioned.fill(
          child: RepaintBoundary(
            child: IgnorePointer(
              child: CustomPaint(
                painter: SeprecGridPainter(widget.focus),
                foregroundPainter: SeprecCircuitPainter(widget.focus),
              ),
            ),
          ),
        ),

        // Capa animada: anillo + pulsos (solo esta capa se repinta)
        Positioned.fill(
          child: RepaintBoundary(
            child: IgnorePointer(
              child: CustomPaint(
                painter: SeprecMotionPainter(
                  _controller,
                  widget.focus,
                  pulses: pulses,
                ),
              ),
            ),
          ),
        ),

        // Viñeta de profundidad
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.3),
                  radius: 1.25,
                  colors: [
                    Color(0x00020A12),
                    Color(0x00020A12),
                    Color(0x66020A12),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Contenido
        widget.child,
      ],
    );
  }

  static Widget _glow(double size, List<Color> colors) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Geometría compartida (se calcula una vez por tamaño)
// ─────────────────────────────────────────────────────────────

class _Trace {
  final List<Offset> pts;
  final Path path;
  final PathMetric metric;
  final bool pulse;
  final double phase;
  final bool chip;
  final bool endVisible;

  _Trace(
    this.pts,
    this.path,
    this.metric,
    this.pulse,
    this.phase,
    this.chip,
    this.endVisible,
  );
}

class _Geometry {
  final Size size;
  final Offset focus;
  final Offset center;
  final double ringR;
  final List<_Trace> traces;
  final List<Offset> dotClusters;
  final _Logo logo;

  _Geometry._(
    this.size,
    this.focus,
    this.center,
    this.ringR,
    this.traces,
    this.dotClusters,
    this.logo,
  );

  static _Geometry of(Size size, Offset focus) => _build(size, focus);

  static _Geometry _build(Size size, Offset focus) {
    final center = Offset(size.width * focus.dx, size.height * focus.dy);
    final ringR = math.min(size.width, size.height) * 0.27;
    final rng = math.Random(11); // semilla fija: siempre el mismo diseño
    const n = 30;
    const oct = math.pi / 4;
    final safe = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);

    final traces = <_Trace>[];
    int chips = 0;

    for (int i = 0; i < n; i++) {
      if (rng.nextDouble() < 0.12) continue; // huecos para romper la simetría

      final a = _tau * i / n + (rng.nextDouble() - 0.5) * 0.05;
      final dir = Offset(math.cos(a), math.sin(a));
      final snapped = (a / oct).round() * oct; // dirección a 0/45/90°
      final turn = rng.nextBool() ? oct : -oct;
      final d2 = Offset(math.cos(snapped), math.sin(snapped));
      final d3 = Offset(math.cos(snapped + turn), math.sin(snapped + turn));

      final p0 = center + dir * (ringR * 1.22);
      final p1 = center + dir * (ringR * (1.34 + rng.nextDouble() * 0.25));
      final p2 = p1 + d2 * (ringR * (0.25 + rng.nextDouble() * 0.7));
      final p3 = p2 + d3 * (ringR * (0.3 + rng.nextDouble() * 1.1));

      final pts = [p0, p1, p2, p3];
      final path = _roundedPath(pts);
      final visible = safe.contains(p3);
      final chip = visible && chips < 4 && rng.nextDouble() < 0.22;
      if (chip) chips++;

      traces.add(_Trace(
        pts,
        path,
        path.computeMetrics().first,
        i % 3 == 0,
        rng.nextDouble(),
        chip,
        visible,
      ));
    }

    final clusters = <Offset>[];
    for (final ang in const [0.55, 2.35, 4.2]) {
      final p = center + Offset(math.cos(ang), math.sin(ang)) * (ringR * 2.1);
      if (safe.contains(p)) clusters.add(p);
    }

    return _Geometry._(
      size,
      focus,
      center,
      ringR,
      traces,
      clusters,
      _buildLogo(center, ringR),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Logo SEPREC (isotipo de 3 capas) en formato circuito
// ─────────────────────────────────────────────────────────────

class _Layer {
  final Path outline; // rombo de la capa
  final PathMetric metric;
  final Path? slab; // grosor (solo la capa inferior, como en el logo)
  final List<Path> legs; // pistas que conectan con el anillo
  final List<Offset> vertexNodes;
  final List<Offset> legEnds;

  _Layer(
    this.outline,
    this.metric,
    this.slab,
    this.legs,
    this.vertexNodes,
    this.legEnds,
  );
}

class _LogoText {
  final TextPainter painter;
  final Offset offset;
  _LogoText(this.painter, this.offset);
}

class _Logo {
  final List<_Layer> layers; // 0 = inferior, 1 = media, 2 = superior
  final List<_LogoText> texts; // SEPREC + subtítulo
  final Rect barRect; // franja tricolor
  final List<Path> textLegs; // pistas laterales del texto
  final List<Offset> textLegEnds;

  _Logo(this.layers, this.texts, this.barRect, this.textLegs, this.textLegEnds);
}

/// Contorno cerrado con esquinas suavizadas.
Path _roundedClosed(List<Offset> p, {double radius = 6}) {
  final n = p.length;

  Offset before(int i) {
    final prev = p[(i - 1 + n) % n];
    final cur = p[i];
    final d = (prev - cur).distance;
    return cur + (prev - cur) / d * math.min(radius, d / 2);
  }

  Offset after(int i) {
    final next = p[(i + 1) % n];
    final cur = p[i];
    final d = (next - cur).distance;
    return cur + (next - cur) / d * math.min(radius, d / 2);
  }

  final start = after(0);
  final path = Path()..moveTo(start.dx, start.dy);
  for (int k = 1; k <= n; k++) {
    final i = k % n;
    final a = before(i);
    final b = after(i);
    path.lineTo(a.dx, a.dy);
    path.quadraticBezierTo(p[i].dx, p[i].dy, b.dx, b.dy);
  }
  path.close();
  return path;
}

_Logo _buildLogo(Offset c, double r) {
  final s = r * 0.27; // semiancho del rombo
  final b = s * 0.55; // semialto del rombo
  final gap = s * 0.45; // separación vertical entre capas
  final thick = s * 0.25; // grosor de la capa inferior
  final rr = r * 0.8; // las pistas llegan hasta el anillo interior

  // Medidas del conjunto: isotipo + SEPREC + franja + subtítulo
  final isoH = s * 2.25;
  final titleFs = r * 0.17;
  final subFs = r * 0.062;
  final gap1 = r * 0.07;
  final gap2 = r * 0.045;
  final barH = math.max(1.5, r * 0.016);
  final gap3 = r * 0.035;
  final subW = r * 1.0;

  final title = TextPainter(
    text: TextSpan(
      text: 'SEPREC',
      style: TextStyle(
        fontSize: titleFs,
        fontWeight: FontWeight.w700,
        letterSpacing: r * 0.02,
        color: _tealLight.withValues(alpha: 0.92),
        shadows: [Shadow(color: _teal.withValues(alpha: 0.6), blurRadius: 10)],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  final sub = TextPainter(
    text: TextSpan(
      text: 'Servicio Plurinacional de\nRegistro de Comercio',
      style: TextStyle(
        fontSize: subFs,
        letterSpacing: 0.4,
        height: 1.25,
        color: _tealLight.withValues(alpha: 0.7),
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: subW, maxWidth: subW);

  final totalH = isoH + gap1 + title.height + gap2 + barH + gap3 + sub.height;
  final top = c.dy - totalH / 2;
  final yMid = top + s; // centro de la capa media
  final titleY = top + isoH + gap1;
  final barY = titleY + title.height + gap2;
  final subY = barY + barH + gap3;

  final layers = <_Layer>[];
  for (int i = 0; i < 3; i++) {
    final cy = yMid + gap * (1 - i); // i=0 abajo, i=2 arriba
    final pts = [
      Offset(c.dx, cy - b),
      Offset(c.dx + s, cy),
      Offset(c.dx, cy + b),
      Offset(c.dx - s, cy),
    ];
    final outline = _roundedClosed(pts, radius: s * 0.1);

    Path? slab;
    if (i == 0) {
      final l = pts[3];
      final bo = pts[2];
      final rg = pts[1];
      slab = Path()
        ..moveTo(l.dx, l.dy)
        ..lineTo(l.dx, l.dy + thick)
        ..lineTo(bo.dx, bo.dy + thick)
        ..lineTo(rg.dx, rg.dy + thick)
        ..lineTo(rg.dx, rg.dy)
        ..moveTo(bo.dx, bo.dy)
        ..lineTo(bo.dx, bo.dy + thick);
    }

    final legs = <Path>[];
    final nodes = <Offset>[];
    final ends = <Offset>[];
    final dy = cy - c.dy;
    final reach = math.sqrt(math.max(0.0, rr * rr - dy * dy));
    for (final sign in const [-1.0, 1.0]) {
      final v = Offset(c.dx + sign * s, cy);
      final e = Offset(c.dx + sign * reach, cy);
      legs.add(Path()
        ..moveTo(v.dx, v.dy)
        ..lineTo(e.dx, e.dy));
      nodes.add(v);
      ends.add(e);
    }

    layers.add(_Layer(
      outline,
      outline.computeMetrics().first,
      slab,
      legs,
      nodes,
      ends,
    ));
  }

  // Pistas laterales a la altura del texto SEPREC
  final titleCy = titleY + title.height / 2;
  final tdy = titleCy - c.dy;
  final treach = math.sqrt(math.max(0.0, rr * rr - tdy * tdy));
  final halfTw = title.width / 2 + r * 0.05;
  final textLegs = <Path>[];
  final textLegEnds = <Offset>[];
  if (treach > halfTw + 6) {
    for (final sign in const [-1.0, 1.0]) {
      final v = Offset(c.dx + sign * halfTw, titleCy);
      final e = Offset(c.dx + sign * treach, titleCy);
      textLegs.add(Path()
        ..moveTo(v.dx, v.dy)
        ..lineTo(e.dx, e.dy));
      textLegEnds.add(e);
    }
  }

  final barW = r * 0.34;

  return _Logo(
    layers,
    [
      _LogoText(title, Offset(c.dx - title.width / 2, titleY)),
      _LogoText(sub, Offset(c.dx - subW / 2, subY)),
    ],
    Rect.fromLTWH(c.dx - barW / 2, barY, barW, barH),
    textLegs,
    textLegEnds,
  );
}

// Texto del logo (SEPREC, franja tricolor y subtítulo) con sus pistas
void _drawLogoText(Canvas canvas, _Logo logo) {
  final legPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.1
    ..strokeCap = StrokeCap.round
    ..color = _teal.withValues(alpha: 0.5);
  final ring = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = _teal.withValues(alpha: 0.7);
  final core = Paint()..color = _tealLight;

  for (final leg in logo.textLegs) {
    canvas.drawPath(leg, legPaint);
  }
  for (final p in logo.textLegEnds) {
    canvas.drawCircle(p, 4, ring);
    canvas.drawCircle(p, 1.6, core);
  }

  for (final t in logo.texts) {
    t.painter.paint(canvas, t.offset);
  }

  const colors = [Color(0xFFD52B1E), Color(0xFFF9E300), Color(0xFF007934)];
  final w = logo.barRect.width / 3;
  for (int i = 0; i < 3; i++) {
    canvas.drawRect(
      Rect.fromLTWH(
          logo.barRect.left + w * i, logo.barRect.top, w, logo.barRect.height),
      Paint()..color = colors[i].withValues(alpha: 0.85),
    );
  }
}

void _drawLogoLayer(
  Canvas canvas,
  _Layer l,
  int i,
  double t,
  double breathe,
  bool animated,
) {
  final fills = <Color>[
    const Color(0x40020812),
    _teal.withValues(alpha: 0.14),
    _tealLight.withValues(alpha: 0.10),
  ];
  const strokeAlpha = [0.55, 0.85, 0.6];

  // Relleno translúcido (recuerda las capas del logo)
  canvas.drawPath(l.outline, Paint()..color = fills[i]);

  // Resplandor en la capa media
  if (i == 1) {
    canvas.drawPath(
      l.outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = _tealLight.withValues(alpha: 0.18 + 0.10 * breathe)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  canvas.drawPath(
    l.outline,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeJoin = StrokeJoin.round
      ..color = _tealLight.withValues(alpha: strokeAlpha[i]),
  );

  final slab = l.slab;
  if (slab != null) {
    canvas.drawPath(
      slab,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round
        ..color = _teal.withValues(alpha: 0.45),
    );
  }

  // Pistas hacia el anillo + nodos
  final legPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.1
    ..strokeCap = StrokeCap.round
    ..color = _teal.withValues(alpha: 0.5);
  final ring = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = _teal.withValues(alpha: 0.7);
  final core = Paint()..color = _tealLight;

  for (final leg in l.legs) {
    canvas.drawPath(leg, legPaint);
  }
  for (final p in l.vertexNodes) {
    canvas.drawCircle(p, 1.6, core);
  }
  for (final p in l.legEnds) {
    canvas.drawCircle(p, 4, ring);
    canvas.drawCircle(p, 1.6, core);
  }

  // Pulso de luz recorriendo el contorno de la capa
  if (animated) {
    final len = l.metric.length;
    final u = (t * 4 + i * 0.33) % 1.0; // ~6 s por vuelta
    final head = u * len;
    final tail = len * 0.28;
    final pulse = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = _tealLight.withValues(alpha: 0.65);

    canvas.drawPath(
      l.metric.extractPath(math.max(0.0, head - tail), head),
      pulse,
    );
    if (head < tail) {
      canvas.drawPath(l.metric.extractPath(len - (tail - head), len), pulse);
    }

    final tg = l.metric.getTangentForOffset(head);
    if (tg != null) {
      canvas.drawCircle(
        tg.position,
        4.5,
        Paint()
          ..color = _teal.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(tg.position, 1.9, Paint()..color = _tealLight);
    }
  }
}

/// Trazo con esquinas suavizadas.
Path _roundedPath(List<Offset> p, {double radius = 10}) {
  final path = Path()..moveTo(p.first.dx, p.first.dy);
  for (int i = 1; i < p.length - 1; i++) {
    final prev = p[i - 1];
    final cur = p[i];
    final next = p[i + 1];
    final d1 = (prev - cur).distance;
    final d2 = (next - cur).distance;
    final a = cur + (prev - cur) / d1 * math.min(radius, d1 / 2);
    final b = cur + (next - cur) / d2 * math.min(radius, d2 / 2);
    path.lineTo(a.dx, a.dy);
    path.quadraticBezierTo(cur.dx, cur.dy, b.dx, b.dy);
  }
  path.lineTo(p.last.dx, p.last.dy);
  return path;
}

// ─────────────────────────────────────────────────────────────
// Cuadrícula (se desvanece desde el anillo)
// ─────────────────────────────────────────────────────────────

class SeprecGridPainter extends CustomPainter {
  final Offset focus;

  SeprecGridPainter(this.focus);

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 32.0;
    const majorEvery = 4;

    final center = Offset(size.width * focus.dx, size.height * focus.dy);
    final area =
        Rect.fromCircle(center: center, radius: size.longestSide * 0.9);

    Paint shaderPaint(double width, int a0, int a1) => Paint()
      ..strokeWidth = width
      ..shader = RadialGradient(
        colors: [
          _grid.withAlpha(a0),
          _grid.withAlpha(a1),
          _grid.withAlpha(0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(area);

    final minor = Path();
    final major = Path();

    int i = 0;
    for (double x = 0; x <= size.width; x += spacing, i++) {
      (i % majorEvery == 0 ? major : minor)
        ..moveTo(x, 0)
        ..lineTo(x, size.height);
    }
    i = 0;
    for (double y = 0; y <= size.height; y += spacing, i++) {
      (i % majorEvery == 0 ? major : minor)
        ..moveTo(0, y)
        ..lineTo(size.width, y);
    }

    canvas.drawPath(
        minor, shaderPaint(0.5, 0x18, 0x08)..style = PaintingStyle.stroke);
    canvas.drawPath(
        major, shaderPaint(0.9, 0x30, 0x10)..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant SeprecGridPainter old) => old.focus != focus;
}

// ─────────────────────────────────────────────────────────────
// Circuitos radiales, chips y puntos (estático)
// ─────────────────────────────────────────────────────────────

class SeprecCircuitPainter extends CustomPainter {
  final Offset focus;

  SeprecCircuitPainter(this.focus);

  _Geometry? _geo;

  _Geometry _geometry(Size size) {
    final g = _geo;
    if (g != null && g.size == size && g.focus == focus) return g;
    return _geo = _Geometry.of(size, focus);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final g = _geometry(size);

    // Los trazos pierden intensidad al alejarse del anillo
    final fade =
        Rect.fromCircle(center: g.center, radius: size.longestSide * 0.75);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = RadialGradient(
        colors: [
          _teal.withAlpha(0x70),
          _teal.withAlpha(0x38),
          _teal.withAlpha(0x14),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(fade);

    final glowPaint = Paint()
      ..color = _teal.withAlpha(0x1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final nodeRing = Paint()
      ..color = _teal.withAlpha(0x70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final nodeCore = Paint()..color = _tealLight;

    for (final t in g.traces) {
      if (t.pulse) canvas.drawPath(t.path, glowPaint);
      canvas.drawPath(t.path, linePaint);

      // Inicio (junto al anillo)
      canvas.drawCircle(t.pts.first, 1.8, nodeCore);

      if (!t.endVisible) continue;
      if (t.chip) {
        _drawChip(canvas, t.pts.last);
      } else {
        canvas.drawCircle(t.pts.last, 4, nodeRing);
        canvas.drawCircle(t.pts.last, 1.6, nodeCore);
      }
    }

    // Matrices de puntos
    final dot = Paint()..color = _teal.withAlpha(0x55);
    for (final c in g.dotClusters) {
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 4; j++) {
          canvas.drawCircle(c + Offset(i * 5.0, j * 5.0), 0.9, dot);
        }
      }
    }

    _drawCornerMarks(canvas, size);
  }

  // Chip pequeño de 4 cuadros
  void _drawChip(Canvas canvas, Offset c) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 16, height: 16),
        const Radius.circular(3),
      ),
      Paint()
        ..color = _teal.withAlpha(0x40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 16, height: 16),
        const Radius.circular(3),
      ),
      Paint()
        ..color = _teal.withAlpha(0x70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final sq = Paint()..color = _tealLight.withAlpha(0xCC);
    for (final dx in const [-3.5, 3.5]) {
      for (final dy in const [-3.5, 3.5]) {
        canvas.drawRect(
          Rect.fromCenter(center: c + Offset(dx, dy), width: 4, height: 4),
          sq,
        );
      }
    }
  }

  // Marcas de esquina estilo HUD
  void _drawCornerMarks(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _teal.withAlpha(0x40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    const inset = 14.0;
    const len = 18.0;
    final w = size.width;
    final h = size.height;

    Path corner(Offset o, double dx, double dy) => Path()
      ..moveTo(o.dx + dx * len, o.dy)
      ..lineTo(o.dx, o.dy)
      ..lineTo(o.dx, o.dy + dy * len);

    canvas.drawPath(corner(const Offset(inset, inset), 1, 1), paint);
    canvas.drawPath(corner(Offset(w - inset, inset), -1, 1), paint);
    canvas.drawPath(corner(Offset(inset, h - inset), 1, -1), paint);
    canvas.drawPath(corner(Offset(w - inset, h - inset), -1, -1), paint);
  }

  @override
  bool shouldRepaint(covariant SeprecCircuitPainter old) => old.focus != focus;
}

// ─────────────────────────────────────────────────────────────
// Movimiento: anillo central + pulsos por los circuitos
// ─────────────────────────────────────────────────────────────

// (inicio, barrido) en radianes
const _innerSegs = <(double, double)>[
  (0.3, 1.1),
  (1.9, 0.5),
  (3.3, 1.6),
  (5.5, 0.5),
];
const _outerSegs = <(double, double)>[
  (0.2, 2.4),
  (3.0, 2.8),
];

class SeprecMotionPainter extends CustomPainter {
  final Animation<double> animation;
  final Offset focus;
  final bool pulses;

  SeprecMotionPainter(this.animation, this.focus, {required this.pulses})
      : super(repaint: animation);

  _Geometry? _geo;

  _Geometry _geometry(Size size) {
    final g = _geo;
    if (g != null && g.size == size && g.focus == focus) return g;
    return _geo = _Geometry.of(size, focus);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final g = _geometry(size);
    final c = g.center;
    final r = g.ringR;
    final t = animation.value;
    final breathe = 0.5 + 0.5 * math.sin(_tau * 4 * t); // respiración ~6 s

    // Halo suave alrededor del anillo
    final haloRect = Rect.fromCircle(center: c, radius: r * 1.9);
    canvas.drawCircle(
      c,
      r * 1.9,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            _teal.withValues(alpha: 0.05),
            _teal.withValues(alpha: 0.07 + 0.03 * breathe),
            _blue.withValues(alpha: 0.07),
            Colors.transparent,
          ],
          stops: const [0.0, 0.40, 0.54, 0.75, 1.0],
        ).createShader(haloRect),
    );

    // Interior más oscuro (da foco al anillo)
    canvas.drawCircle(c, r * 0.8, Paint()..color = const Color(0x55020812));

    // Anillo fino completo
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _teal.withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      c,
      r * 0.6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = _teal.withValues(alpha: 0.10),
    );

    // Anillo interior (sentido contrario, más rápido)
    final innerRect = Rect.fromCircle(center: c, radius: r * 0.82);
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..color = _tealLight.withValues(alpha: 0.45);
    for (final (s, sw) in _innerSegs) {
      canvas.drawArc(innerRect, -_tau * 3 * t + s, sw, false, innerPaint);
    }

    // Anillo exterior (muy lento)
    final outerRect = Rect.fromCircle(center: c, radius: r * 1.1);
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..color = _teal.withValues(alpha: 0.35);
    for (final (s, sw) in _outerSegs) {
      canvas.drawArc(outerRect, _tau * t + s, sw, false, outerPaint);
    }

    // Marcas graduadas
    final ticks = Path();
    const tickCount = 60;
    for (int i = 0; i < tickCount; i++) {
      final ang = -_tau * t + _tau * i / tickCount;
      final dir = Offset(math.cos(ang), math.sin(ang));
      final len = i % 5 == 0 ? 8.0 : 4.0;
      ticks
        ..moveTo(c.dx + dir.dx * r * 1.17, c.dy + dir.dy * r * 1.17)
        ..lineTo(
          c.dx + dir.dx * (r * 1.17 + len),
          c.dy + dir.dy * (r * 1.17 + len),
        );
    }
    canvas.drawPath(
      ticks,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _teal.withValues(alpha: 0.30),
    );

    // Tres puntos que orbitan
    for (int i = 0; i < 3; i++) {
      final ang = _tau * 2 * t + i * _tau / 3;
      final p = c + Offset(math.cos(ang), math.sin(ang)) * (r * 1.1);
      canvas.drawCircle(
        p,
        5,
        Paint()
          ..color = _tealLight.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(p, 1.8, Paint()..color = _tealLight);
    }

    // Logo SEPREC en formato circuito, centrado en el anillo.
    // Las capas flotan apenas y un pulso recorre cada contorno.
    final bobAmp = pulses ? 1.4 : 0.0;
    for (int i = 0; i < g.logo.layers.length; i++) {
      final bob = math.sin(_tau * 4 * t + i * 1.2) * bobAmp;
      canvas.save();
      canvas.translate(0, bob);
      _drawLogoLayer(canvas, g.logo.layers[i], i, t, breathe, pulses);
      canvas.restore();
    }
    _drawLogoText(canvas, g.logo);

    if (!pulses) return;

    // Pulsos que salen del anillo hacia los bordes
    const tail = 75.0;
    final tailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;
    final headGlow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final headCore = Paint();

    for (final tr in g.traces) {
      if (!tr.pulse) continue;

      final u = (t * 3 + tr.phase) % 1.0; // 8 s por recorrido
      final fade = math.sin(u * math.pi);
      final head = u * tr.metric.length;
      final seg = tr.metric.extractPath(math.max(0.0, head - tail), head);

      tailPaint.color = _tealLight.withValues(alpha: 0.5 * fade);
      canvas.drawPath(seg, tailPaint);

      final tangent = tr.metric.getTangentForOffset(head);
      if (tangent != null) {
        headGlow.color = _teal.withValues(alpha: 0.5 * fade);
        headCore.color = _tealLight.withValues(alpha: fade);
        canvas.drawCircle(tangent.position, 4.5, headGlow);
        canvas.drawCircle(tangent.position, 1.8, headCore);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SeprecMotionPainter old) =>
      old.focus != focus || old.pulses != pulses;
}
