import 'dart:math';
import 'package:flutter/material.dart';

/// Tipo de padrão ECG a ser desenhado
enum EcgType {
  vf,
  asystole,
  vt,
  svt,
  afib,
  flutterWave,
  bradycardia,
  wenckebach,
  mobitz2,
  avb3,
  torsades,
  stemi,
  normal,
  pea,
}

/// Converte string usada em algorithms.dart para o enum
EcgType ecgTypeFromString(String s) {
  switch (s) {
    case 'vf':         return EcgType.vf;
    case 'asystole':   return EcgType.asystole;
    case 'vt':         return EcgType.vt;
    case 'svt':        return EcgType.svt;
    case 'afib':       return EcgType.afib;
    case 'flutter':    return EcgType.flutterWave;
    case 'bradycardia':return EcgType.bradycardia;
    case 'wenckebach': return EcgType.wenckebach;
    case 'mobitz2':    return EcgType.mobitz2;
    case 'avb3':       return EcgType.avb3;
    case 'torsades':   return EcgType.torsades;
    case 'stemi':      return EcgType.stemi;
    case 'pea':        return EcgType.pea;
    default:           return EcgType.normal;
  }
}

class EcgPainter extends CustomPainter {
  final EcgType type;
  final Color waveColor;

  const EcgPainter({
    required this.type,
    this.waveColor = const Color(0xFF00E676),
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fundo escuro
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(0),
      ),
      Paint()..color = const Color(0xFF060E06),
    );

    _drawGrid(canvas, size);

    final paint = Paint()
      ..color = waveColor
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    switch (type) {
      case EcgType.vf:         _drawVF(canvas, size, paint); break;
      case EcgType.asystole:   _drawAsystole(canvas, size, paint); break;
      case EcgType.vt:         _drawVT(canvas, size, paint); break;
      case EcgType.svt:        _drawSVT(canvas, size, paint); break;
      case EcgType.afib:       _drawAFib(canvas, size, paint); break;
      case EcgType.flutterWave:_drawFlutter(canvas, size, paint); break;
      case EcgType.bradycardia:_drawBradycardia(canvas, size, paint); break;
      case EcgType.wenckebach: _drawWenckebach(canvas, size, paint); break;
      case EcgType.mobitz2:    _drawMobitz2(canvas, size, paint); break;
      case EcgType.avb3:       _drawAVB3(canvas, size, paint); break;
      case EcgType.torsades:   _drawTorsades(canvas, size, paint); break;
      case EcgType.stemi:      _drawSTEMI(canvas, size, paint); break;
      case EcgType.pea:        _drawBradycardia(canvas, size, paint); break;
      case EcgType.normal:     _drawNormal(canvas, size, paint); break;
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final minor = Paint()
      ..color = const Color(0xFF0D2B0D)
      ..strokeWidth = 0.5;
    final major = Paint()
      ..color = const Color(0xFF143814)
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += 10) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        y % 50 == 0 ? major : minor,
      );
    }
    for (double x = 0; x < size.width; x += 10) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        x % 50 == 0 ? major : minor,
      );
    }
  }

  // ── Helper: desenha um complexo PQRST ──────────────────────
  void _pqrst(
    Path path,
    double x0,        // início do ciclo
    double cy,        // baseline y
    double W,         // largura total do ciclo
    double H,         // amplitude
    {
    double prOffset = 0,   // atraso do PR (Wenckebach)
    double stElev = 0,     // elevação ST (STEMI)
    bool noQRS = false,    // só onda P (bloqueio)
    double qrsScale = 1.0, // largura do QRS (>1 = alargado, TV)
  }) {
    // Baseline até início do P
    path.lineTo(x0, cy);

    // Onda P
    double pCx = x0 + W * 0.14;
    path.quadraticBezierTo(
      pCx - W * 0.05, cy - H * 0.14,
      pCx, cy - H * 0.17,
    );
    path.quadraticBezierTo(
      pCx + W * 0.05, cy - H * 0.14,
      x0 + W * 0.28 + prOffset, cy,
    );

    if (!noQRS) {
      double qx = x0 + W * 0.30 + prOffset;
      // Q
      path.lineTo(qx, cy + H * 0.05);
      // R
      path.lineTo(qx + W * 0.02 * qrsScale, cy - H * 0.80);
      // S
      path.lineTo(qx + W * 0.04 * qrsScale, cy + H * 0.15);
      // ST
      double stEnd = qx + W * 0.16 * qrsScale;
      path.lineTo(stEnd, cy - stElev * H);
      // Onda T
      double tCx = stEnd + W * 0.10;
      path.quadraticBezierTo(
        tCx - W * 0.03, cy - H * (0.22 + stElev),
        tCx, cy - H * (0.20 + stElev),
      );
      path.quadraticBezierTo(
        tCx + W * 0.05, cy - H * 0.05,
        x0 + W * 0.72 + prOffset * 0.5, cy,
      );
    }

    path.lineTo(x0 + W, cy);
  }

  // ── Ritmos ─────────────────────────────────────────────────

  void _drawNormal(Canvas canvas, Size size, Paint paint) {
    double cy = size.height * 0.58;
    double W = size.width / 3.0;
    double H = size.height * 0.52;
    final path = Path()..moveTo(0, cy);
    for (int i = 0; i < 3; i++) _pqrst(path, W * i, cy, W, H);
    canvas.drawPath(path, paint);
  }

  void _drawBradycardia(Canvas canvas, Size size, Paint paint) {
    double cy = size.height * 0.58;
    double W = size.width / 2.0;
    double H = size.height * 0.52;
    final path = Path()..moveTo(0, cy);
    for (int i = 0; i < 2; i++) _pqrst(path, W * i, cy, W, H);
    canvas.drawPath(path, paint);
  }

  void _drawSVT(Canvas canvas, Size size, Paint paint) {
    double cy = size.height * 0.55;
    double W = size.width / 7.0;
    double H = size.height * 0.50;
    final path = Path()..moveTo(0, cy);
    for (int i = 0; i < 7; i++) _pqrst(path, W * i, cy, W, H);
    canvas.drawPath(path, paint);
  }

  void _drawVT(Canvas canvas, Size size, Paint paint) {
    double cy = size.height * 0.55;
    double W = size.width / 4.0;
    double H = size.height * 0.50;
    final path = Path()..moveTo(0, cy);
    for (int i = 0; i < 4; i++) {
      double x0 = W * i;
      path.lineTo(x0, cy);
      // Complexo largo e bizarro
      path.quadraticBezierTo(x0 + W * 0.10, cy + H * 0.10, x0 + W * 0.18, cy + H * 0.08);
      path.lineTo(x0 + W * 0.32, cy - H * 0.82);
      path.lineTo(x0 + W * 0.36, cy - H * 0.60);
      path.lineTo(x0 + W * 0.42, cy + H * 0.18);
      path.quadraticBezierTo(x0 + W * 0.55, cy + H * 0.22, x0 + W * 0.70, cy + H * 0.12);
      path.quadraticBezierTo(x0 + W * 0.85, cy + H * 0.02, x0 + W, cy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawVF(Canvas canvas, Size size, Paint paint) {
    double cy = size.height * 0.50;
    double H = size.height * 0.42;
    final rand = Random(42);
    final path = Path()..moveTo(0, cy);
    int n = 90;
    for (int i = 1; i <= n; i++) {
      double x = size.width * i / n;
      double amp = H * (0.35 + 0.65 * (0.5 + 0.5 * sin(i * 0.8)));
      double y = cy + (rand.nextDouble() - 0.5) * 2 * amp;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  void _drawAsystole(Canvas canvas, Size size, Paint paint) {
    double cy = size.height * 0.50;
    final rand = Random(7);
    final path = Path()..moveTo(0, cy);
    for (double x = 0; x <= size.width; x += 4) {
      path.lineTo(x, cy + (rand.nextDouble() - 0.5) * 3);
    }
    canvas.drawPath(path, paint);
  }

  void _drawAFib(Canvas canvas, Size size, Paint paint) {
    double cy = size.height * 0.56;
    double H = size.height * 0.50;
    final rand = Random(9);

    // Linha de base fibrilatória
    final basePaint = Paint()
      ..color = waveColor.withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final basePath = Path()..moveTo(0, cy);
    for (double x = 0; x <= size.width; x += 3) {
      basePath.lineTo(x, cy + (rand.nextDouble() - 0.5) * H * 0.13);
    }
    canvas.drawPath(basePath, basePaint);

    // QRS estreitos irregulares
    final timings = [0.07, 0.19, 0.29, 0.44, 0.54, 0.68, 0.78, 0.90];
    for (double t in timings) {
      double qx = size.width * t;
      double dy = (rand.nextDouble() - 0.5) * H * 0.07;
      final p = Path()..moveTo(qx - 4, cy + dy);
      p.lineTo(qx - 2, cy + H * 0.05 + dy);
      p.lineTo(qx, cy - H * 0.62 + dy);
      p.lineTo(qx + 2, cy + H * 0.13 + dy);
      p.lineTo(qx + 5, cy + dy);
      canvas.drawPath(p, paint);
    }
  }

  void _drawFlutter(Canvas canvas, Size size, Paint paint) {
    double cy = size.height * 0.58;
    double H = size.height * 0.50;
    double toothW = size.width / 13.0;
    final path = Path()..moveTo(0, cy);

    for (int i = 0; i < 13; i++) {
      double x0 = toothW * i;
      double mid = x0 + toothW / 2;
      // "Dente de serra"
      path.quadraticBezierTo(x0 + toothW * 0.25, cy - H * 0.26, mid, cy - H * 0.28);
      path.quadraticBezierTo(x0 + toothW * 0.75, cy + H * 0.03, x0 + toothW, cy + H * 0.04);

      // A cada 3 dentes: QRS
      if (i % 3 == 2) {
        double qx = x0 + toothW * 0.5;
        path.moveTo(qx - 3, cy + H * 0.04);
        path.lineTo(qx, cy - H * 0.72);
        path.lineTo(qx + 3, cy + H * 0.14);
        path.lineTo(qx + 7, cy);
        path.moveTo(x0 + toothW, cy + H * 0.04);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawWenckebach(Canvas canvas, Size size, Paint paint) {
    double cy = size.height * 0.58;
    double W = size.width / 4.3;
    double H = size.height * 0.50;
    final path = Path()..moveTo(0, cy);

    // 3 batimentos com PR progressivo + 1 onda P bloqueada
    _pqrst(path, W * 0.0, cy, W, H, prOffset: 0);
    _pqrst(path, W * 1.0, cy, W, H, prOffset: W * 0.07);
    _pqrst(path, W * 2.0, cy, W, H, prOffset: W * 0.14);
    _pqrst(path, W * 3.0, cy, W, H, noQRS: true); // P bloqueado

    canvas.drawPath(path, paint);
  }

  void _drawMobitz2(Canvas canvas, Size size, Paint paint) {
    double cy = size.height * 0.58;
    double W = size.width / 4.6;
    double H = size.height * 0.50;
    final path = Path()..moveTo(0, cy);

    // PR CONSTANTE — 2 batimentos normais, 1 bloqueado, 2 normais
    _pqrst(path, W * 0.0, cy, W, H);
    _pqrst(path, W * 1.0, cy, W, H);
    _pqrst(path, W * 2.0, cy, W, H, noQRS: true); // bloqueio súbito
    _pqrst(path, W * 3.0, cy, W, H);

    canvas.drawPath(path, paint);
  }

  void _drawAVB3(Canvas canvas, Size size, Paint paint) {
    double cy = size.height * 0.58;
    double H = size.height * 0.50;

    // Ondas P (ritmo atrial: ~75bpm)
    double pW = size.width / 8.5;
    final pPath = Paint()
      ..color = waveColor
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 9; i++) {
      double px = pW * i + pW * 0.5;
      final p = Path()..moveTo(px - pW * 0.25, cy);
      p.quadraticBezierTo(px - pW * 0.08, cy - H * 0.18, px, cy - H * 0.20);
      p.quadraticBezierTo(px + pW * 0.08, cy - H * 0.18, px + pW * 0.25, cy);
      canvas.drawPath(p, pPath);
    }

    // QRS (ritmo ventricular: ~35bpm — mais lento e independente)
    final qrsTimings = [0.16, 0.46, 0.78];
    for (double t in qrsTimings) {
      double qx = size.width * t;
      final q = Path()..moveTo(qx - 4, cy);
      q.lineTo(qx - 2, cy + H * 0.07);
      q.lineTo(qx, cy - H * 0.55);
      q.lineTo(qx + 2, cy + H * 0.15);
      q.lineTo(qx + 8, cy);
      q.quadraticBezierTo(qx + 20, cy - H * 0.14, qx + 28, cy - H * 0.12);
      q.quadraticBezierTo(qx + 36, cy - H * 0.03, qx + 44, cy);
      canvas.drawPath(q, paint);
    }
  }

  void _drawTorsades(Canvas canvas, Size size, Paint paint) {
    double cy = size.height * 0.50;
    double W = size.width / 7.5;
    double H = size.height * 0.44;
    final path = Path()..moveTo(0, cy);

    for (int i = 0; i < 8; i++) {
      double x0 = W * i;
      double amp = sin(i * pi / 3.8); // amplitude gira
      double peakY = cy - amp * H * 0.88;

      path.lineTo(x0, cy);
      path.quadraticBezierTo(
        x0 + W * 0.18, cy + amp * H * 0.12,
        x0 + W * 0.28, peakY + amp * H * 0.32,
      );
      path.lineTo(x0 + W * 0.36, peakY);
      path.lineTo(x0 + W * 0.44, cy + amp * H * 0.16);
      path.quadraticBezierTo(
        x0 + W * 0.70, cy + amp * H * 0.05,
        x0 + W, cy,
      );
    }
    canvas.drawPath(path, paint);
  }

  void _drawSTEMI(Canvas canvas, Size size, Paint paint) {
    double cy = size.height * 0.62;
    double W = size.width / 3.0;
    double H = size.height * 0.52;
    final path = Path()..moveTo(0, cy);
    for (int i = 0; i < 3; i++) {
      _pqrst(path, W * i, cy, W, H, stElev: 0.38);
    }
    canvas.drawPath(path, paint);

    // Label "↑ ST" em vermelho
    final tp = TextPainter(
      text: const TextSpan(
        text: '↑ ST',
        style: TextStyle(
          color: Color(0xFFFF6B6B),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.width * 0.32, size.height * 0.18));
  }

  @override
  bool shouldRepaint(EcgPainter old) =>
      old.type != type || old.waveColor != waveColor;
}
