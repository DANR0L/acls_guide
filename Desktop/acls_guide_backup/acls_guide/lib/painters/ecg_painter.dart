import 'dart:math';
import 'package:flutter/material.dart';
import '../models/ecg_patterns.dart';

class ECGPainter extends CustomPainter {
  final TaquicardiaType type;
  final double stElevation;
  final double animationValue; // 0.0 to 1.0 for scrolling animation

  ECGPainter({
    required this.type,
    this.stElevation = 0.0,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawECG(canvas, size);
  }

  // ── Grid de fundo ──
  void _drawGrid(Canvas canvas, Size size) {
    final paintLight = Paint()
      ..color = const Color(0xFF1A2A1A)
      ..strokeWidth = 0.3;

    final paintMedium = Paint()
      ..color = const Color(0xFF1E3A1E)
      ..strokeWidth = 0.6;

    // Small grid (1mm = ~10px)
    for (double x = 0; x < size.width; x += 10) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintLight);
    }
    for (double y = 0; y < size.height; y += 10) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintLight);
    }

    // Large grid (5mm = 50px)
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintMedium);
    }
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintMedium);
    }
  }

  // ── Desenho do traçado ──
  void _drawECG(Canvas canvas, Size size) {
    final ecgPaint = Paint()
      ..color = const Color(0xFF00FF41)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final baseline = size.height * 0.5;
    final offset = animationValue * 100;

    switch (type) {
      case TaquicardiaType.sinusal:
        _drawSinusal(path, size, baseline, offset);
        break;
      case TaquicardiaType.atrial:
        _drawFA(path, size, baseline, offset);
        break;
      case TaquicardiaType.flutter:
        _drawFlutter(path, size, baseline, offset);
        break;
      case TaquicardiaType.svt:
        _drawSVT(path, size, baseline, offset);
        break;
      case TaquicardiaType.faComWpw:
        _drawWPW(path, size, baseline, offset);
        break;
      case TaquicardiaType.vtMonomorfica:
        _drawVTMono(path, size, baseline, offset);
        break;
      case TaquicardiaType.vtPolimorfica:
        _drawVTPoli(path, size, baseline, offset);
        break;
    }

    // Clip to canvas
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, ecgPaint);
    canvas.restore();
  }

  // ── TAQUICARDIA SINUSAL (FC ~120) ──
  void _drawSinusal(Path path, Size size, double baseline, double offset) {
    final cycleWidth = size.width / 3.5; // ~3.5 cycles visible
    final stShift = stElevation * 5;

    path.moveTo(-offset % cycleWidth, baseline);

    for (double x = -cycleWidth; x < size.width + cycleWidth; x += cycleWidth) {
      final startX = x - (offset % cycleWidth);

      // P wave
      _drawPWave(path, startX + cycleWidth * 0.1, baseline, 8, cycleWidth * 0.12);

      // Baseline to Q
      path.lineTo(startX + cycleWidth * 0.28, baseline);

      // Q wave (small dip)
      path.lineTo(startX + cycleWidth * 0.30, baseline + 5);

      // R wave (tall spike)
      path.lineTo(startX + cycleWidth * 0.33, baseline - 55);

      // S wave (dip below)
      path.lineTo(startX + cycleWidth * 0.36, baseline + 12);

      // Back to baseline + ST segment
      path.lineTo(startX + cycleWidth * 0.40, baseline - stShift);

      // T wave
      _drawTWave(path, startX + cycleWidth * 0.55, baseline - stShift, 15, cycleWidth * 0.15);

      // Return to baseline
      path.lineTo(startX + cycleWidth * 0.75, baseline);
      path.lineTo(startX + cycleWidth, baseline);
    }
  }

  // ── FIBRILAÇÃO ATRIAL (FC ~140, irregular) ──
  void _drawFA(Path path, Size size, double baseline, double offset) {
    final rng = Random(42); // seed fixo para consistência
    final avgCycleWidth = size.width / 4.0;

    path.moveTo(0, baseline);
    double x = -offset % avgCycleWidth;

    while (x < size.width + avgCycleWidth) {
      final cycleWidth = avgCycleWidth * (0.6 + rng.nextDouble() * 0.8); // irregular R-R

      // Fibrillatory baseline (ondulação fina irregular)
      for (double fx = 0; fx < cycleWidth * 0.28; fx += 3) {
        final fib = sin((x + fx) * 0.8) * 3 + sin((x + fx) * 1.5) * 2;
        path.lineTo(x + fx, baseline + fib);
      }

      // QRS (narrow, random amplitude variation)
      final amp = 40.0 + rng.nextDouble() * 25;
      path.lineTo(x + cycleWidth * 0.28, baseline);
      path.lineTo(x + cycleWidth * 0.30, baseline + 4);
      path.lineTo(x + cycleWidth * 0.33, baseline - amp);
      path.lineTo(x + cycleWidth * 0.36, baseline + 8);
      path.lineTo(x + cycleWidth * 0.40, baseline);

      // More fibrillation after QRS
      for (double fx = cycleWidth * 0.40; fx < cycleWidth; fx += 3) {
        final fib = sin((x + fx) * 0.9) * 3 + sin((x + fx) * 1.7) * 2;
        path.lineTo(x + fx, baseline + fib);
      }

      x += cycleWidth;
    }
  }

  // ── FLUTTER ATRIAL (padrão dente de serra) ──
  void _drawFlutter(Path path, Size size, double baseline, double offset) {
    final flutterWidth = size.width / 12; // ondas F rápidas
    final cycleWidth = flutterWidth * 4; // cada 4 ondas F = 1 QRS (condução 4:1)

    path.moveTo(0, baseline);
    double x = -offset % cycleWidth;
    int flutterCount = 0;

    while (x < size.width + cycleWidth) {
      // Onda F (sawtooth)
      final sawStart = x;
      path.lineTo(sawStart, baseline + 12); // descida abrupta
      path.lineTo(sawStart + flutterWidth * 0.7, baseline - 10); // subida gradual
      path.lineTo(sawStart + flutterWidth, baseline + 12); // próxima descida

      flutterCount++;

      // A cada 4 ondas F, inserir QRS
      if (flutterCount % 4 == 2) {
        final qrsX = x + flutterWidth * 0.3;
        path.lineTo(qrsX, baseline + 4);
        path.lineTo(qrsX + 4, baseline - 50);
        path.lineTo(qrsX + 8, baseline + 10);
        path.lineTo(qrsX + 12, baseline);
      }

      x += flutterWidth;
    }
  }

  // ── SVT / AVNRT (FC ~180, regular, estreita) ──
  void _drawSVT(Path path, Size size, double baseline, double offset) {
    final cycleWidth = size.width / 5; // mais ciclos (FC alta)
    final stShift = stElevation * 5;

    path.moveTo(0, baseline);

    for (double x = -cycleWidth; x < size.width + cycleWidth; x += cycleWidth) {
      final startX = x - (offset % cycleWidth);

      // Sem onda P visível - direto para QRS
      path.lineTo(startX + cycleWidth * 0.15, baseline);

      // QRS estreito
      path.lineTo(startX + cycleWidth * 0.18, baseline + 3);
      path.lineTo(startX + cycleWidth * 0.21, baseline - 48);
      path.lineTo(startX + cycleWidth * 0.24, baseline + 8);
      path.lineTo(startX + cycleWidth * 0.28, baseline - stShift);

      // T wave (pode ter P retrógrada embutida)
      _drawTWave(path, startX + cycleWidth * 0.40, baseline - stShift, 10, cycleWidth * 0.12);

      // Baseline
      path.lineTo(startX + cycleWidth * 0.60, baseline);
      path.lineTo(startX + cycleWidth, baseline);
    }
  }

  // ── FA com WPW (irregular, QRS largo, onda delta) ──
  void _drawWPW(Path path, Size size, double baseline, double offset) {
    final rng = Random(77);
    final avgCycleWidth = size.width / 5;

    path.moveTo(0, baseline);
    double x = -offset % avgCycleWidth;

    while (x < size.width + avgCycleWidth) {
      final cycleWidth = avgCycleWidth * (0.5 + rng.nextDouble() * 1.0);
      final amp = 45.0 + rng.nextDouble() * 30;
      final direction = rng.nextBool() ? 1.0 : -0.3; // predominantemente positivo

      // Fibrillatory baseline
      for (double fx = 0; fx < cycleWidth * 0.15; fx += 3) {
        final fib = sin((x + fx) * 1.2) * 2;
        path.lineTo(x + fx, baseline + fib);
      }

      // ONDA DELTA (subida suave = pré-excitação)
      final deltaStart = x + cycleWidth * 0.15;
      path.lineTo(deltaStart, baseline);
      // Subida gradual (slurred upstroke) - característica do WPW
      path.lineTo(deltaStart + cycleWidth * 0.06, baseline - amp * 0.3 * direction);
      path.lineTo(deltaStart + cycleWidth * 0.10, baseline - amp * 0.5 * direction);

      // QRS largo (continua do delta)
      path.lineTo(deltaStart + cycleWidth * 0.14, baseline - amp * direction);
      path.lineTo(deltaStart + cycleWidth * 0.20, baseline + amp * 0.3);
      path.lineTo(deltaStart + cycleWidth * 0.26, baseline - 5);

      // T wave invertida
      _drawTWave(path, x + cycleWidth * 0.55, baseline + 5, -12, cycleWidth * 0.12);

      path.lineTo(x + cycleWidth * 0.75, baseline);

      // Fill to next cycle
      for (double fx = cycleWidth * 0.75; fx < cycleWidth; fx += 3) {
        final fib = sin((x + fx) * 1.1) * 2;
        path.lineTo(x + fx, baseline + fib);
      }

      x += cycleWidth;
    }
  }

  // ── TV MONOMÓRFICA (FC ~170, regular, QRS largo) ──
  void _drawVTMono(Path path, Size size, double baseline, double offset) {
    final cycleWidth = size.width / 4.5;
    final stShift = stElevation * 5;

    path.moveTo(0, baseline);

    for (double x = -cycleWidth; x < size.width + cycleWidth; x += cycleWidth) {
      final startX = x - (offset % cycleWidth);

      // QRS largo - subida mais lenta
      path.lineTo(startX + cycleWidth * 0.05, baseline);
      path.lineTo(startX + cycleWidth * 0.10, baseline - 15);
      path.lineTo(startX + cycleWidth * 0.15, baseline - 60);
      path.lineTo(startX + cycleWidth * 0.22, baseline - 65);
      path.lineTo(startX + cycleWidth * 0.28, baseline - 30);
      path.lineTo(startX + cycleWidth * 0.32, baseline + 20);
      path.lineTo(startX + cycleWidth * 0.38, baseline + 15);

      // ST depression/elevation
      path.lineTo(startX + cycleWidth * 0.45, baseline - stShift + 5);

      // T wave (discordante - invertida)
      _drawTWave(path, startX + cycleWidth * 0.55, baseline - stShift, 18, cycleWidth * 0.15);

      // Return to baseline
      path.lineTo(startX + cycleWidth * 0.80, baseline);
      path.lineTo(startX + cycleWidth, baseline);
    }
  }

  // ── TV POLIMÓRFICA / TORSADES (amplitude variável) ──
  void _drawVTPoli(Path path, Size size, double baseline, double offset) {
    path.moveTo(0, baseline);

    // Torsades: amplitude varia sinusoidalmente (twisting pattern)
    final totalWidth = size.width;
    final stepSize = 2.0;
    final torsadesFreq = 0.025; // frequência da modulação
    final qrsFreq = 0.15; // frequência do QRS

    for (double x = 0; x < totalWidth; x += stepSize) {
      final xShifted = x + offset;

      // Envelope sinusoidal (modulação de amplitude)
      final envelope = sin(xShifted * torsadesFreq) * 55;

      // QRS rápido (complexo largo)
      final qrs = sin(xShifted * qrsFreq) * envelope;

      // Adicionar ruído de alta frequência para aspecto de QRS largo
      final noise = sin(xShifted * 0.5) * 5;

      path.lineTo(x, baseline - qrs - noise);
    }
  }

  // ── Helpers ──
  void _drawPWave(Path path, double centerX, double baseline, double amplitude, double width) {
    path.lineTo(centerX - width, baseline);
    path.quadraticBezierTo(centerX, baseline - amplitude, centerX + width, baseline);
  }

  void _drawTWave(Path path, double centerX, double baseline, double amplitude, double width) {
    path.lineTo(centerX - width, baseline);
    path.quadraticBezierTo(centerX, baseline - amplitude, centerX + width, baseline);
  }

  @override
  bool shouldRepaint(covariant ECGPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.stElevation != stElevation ||
        oldDelegate.animationValue != animationValue;
  }
}
