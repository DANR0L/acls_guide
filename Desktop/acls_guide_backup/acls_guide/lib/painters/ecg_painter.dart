import 'package:flutter/material.dart';
import '../models/ecg_patterns.dart';
import 'dart:math';

class ECGBeat {
  final List<Offset> pontosDeControle;
  final double intervaloRR;
  final bool irregular;

  ECGBeat({
    required this.pontosDeControle,
    required this.intervaloRR,
    this.irregular = false,
  });
}

class ECGBeats {
  static ECGBeat sinusal({double stElevation = 0}) {
    List<Offset> pts = [
      const Offset(0, 0),
      // P: 0->70->120 (2mm)
      const Offset(35, 2), const Offset(70, 2), const Offset(100, 2), const Offset(120, 0),
      // PR
      const Offset(200, 0),
      // QRS: Q=-1mm(210ms), R=10mm(225ms), S=-2mm(240ms)
      const Offset(205, 0), const Offset(210, -1), const Offset(217, 5), const Offset(225, 10),
      const Offset(232, -1), const Offset(240, -2),
      // ST: 240->290
      Offset(245, stElevation), Offset(290, stElevation),
      // T: 290->360->420 (4mm)
      const Offset(325, 2), const Offset(360, 4), const Offset(390, 2), const Offset(420, 0),
      const Offset(500, 0),
    ];
    return ECGBeat(pontosDeControle: pts, intervaloRR: 500);
  }

  static ECGBeat fibrilacaoAtrial({required int cicloIndex}) {
    final intervalos = [380.0, 460.0, 410.0];
    double rr = intervalos[cicloIndex % 3];
    List<Offset> pts = [];
    
    // Fibrilação na linha base (ondas f finas, 0.5mm a cada 50ms)
    double t = 0;
    while (t < 200) {
      pts.add(Offset(t, (t % 100 == 0) ? 0.5 : -0.5));
      t += 25;
    }
    pts.add(const Offset(200, 0));
    
    // QRS
    pts.addAll([
      const Offset(205, 0), const Offset(210, -1), const Offset(217, 5), const Offset(225, 10),
      const Offset(232, -1), const Offset(240, -2),
      const Offset(245, 0), const Offset(290, 0),
      const Offset(325, 2), const Offset(360, 4), const Offset(390, 2), const Offset(420, 0),
    ]);
    
    t = 420;
    while (t < rr) {
      pts.add(Offset(t, (t % 100 == 0) ? 0.5 : -0.5));
      t += 25;
    }
    pts.add(Offset(rr, 0));
    
    return ECGBeat(pontosDeControle: pts, intervaloRR: rr, irregular: true);
  }

  static ECGBeat flutterAtrial() {
    List<Offset> pts = [];
    // 4 ondas F (100ms cada)
    for (int i = 0; i < 4; i++) {
      double start = i * 100.0;
      pts.addAll([
        Offset(start, 0),
        Offset(start + 50, 2),
        Offset(start + 70, -1),
        Offset(start + 100, 0),
      ]);
    }
    
    // QRS no ciclo atual (sobrepõe a onda F entre 200 e 240)
    // Vamos substituir a área 200-240
    pts.removeWhere((p) => p.dx >= 200 && p.dx <= 240);
    pts.addAll([
      const Offset(200, 0),
      const Offset(207, 5), const Offset(215, 10),
      const Offset(222, 4), const Offset(230, -2),
      const Offset(240, 0),
    ]);
    pts.sort((a, b) => a.dx.compareTo(b.dx));
    
    return ECGBeat(pontosDeControle: pts, intervaloRR: 400);
  }

  static ECGBeat svt({required bool first}) {
    List<Offset> pts = [];
    double offsetTime = first ? 600.0 : 0.0; // Pausa no início
    
    if (first) {
      pts.add(const Offset(0, 0));
      pts.add(const Offset(600, 0));
    }
    
    pts.addAll([
      Offset(offsetTime + 0, 0),
      Offset(offsetTime + 10, -1),
      Offset(offsetTime + 20, 10),
      Offset(offsetTime + 30, -2),
      Offset(offsetTime + 50, 0),
      // T
      Offset(offsetTime + 100, 3),
      Offset(offsetTime + 150, 0),
      Offset(offsetTime + 330, 0),
    ]);
    
    return ECGBeat(pontosDeControle: pts, intervaloRR: offsetTime + 330);
  }

  static ECGBeat faComWpw({required int cicloIndex}) {
    final intervalos = [240.0, 280.0, 260.0];
    double rr = intervalos[cicloIndex % 3];
    List<Offset> pts = [];
    
    // Fibrilação
    pts.add(const Offset(0, 0));
    pts.add(const Offset(25, 0.5));
    pts.add(const Offset(50, -0.5));
    
    // QRS com onda delta (largo, 140ms total: 50 -> 190)
    pts.addAll([
      const Offset(50, 0),
      const Offset(80, 3),   // delta
      const Offset(130, 12), // R
      const Offset(190, -3), // S
      const Offset(210, 0),
    ]);
    
    double t = 210;
    while (t < rr) {
      pts.add(Offset(t, (t % 100 == 0) ? 0.5 : -0.5));
      t += 25;
    }
    pts.add(Offset(rr, 0));
    
    return ECGBeat(pontosDeControle: pts, intervaloRR: rr, irregular: true);
  }

  static ECGBeat tvMonomorfica({required int cicloIndex}) {
    List<Offset> pts = [
      const Offset(0, 0),
      // QRS Largo: Q(-3, 10), R(+8, 40), platô, S(-4, 130)
      const Offset(10, -3),
      const Offset(40, 8),
      const Offset(80, 8),
      const Offset(130, -4),
      const Offset(160, 0),
      // ST/T opostos
      const Offset(180, -2),
      const Offset(250, -3),
      const Offset(300, 0),
      const Offset(350, 0),
    ];
    
    // Onda P isolada a cada 3 ciclos
    if (cicloIndex % 3 == 0) {
      // Inserir onda P perto do fim do ciclo
      pts.addAll([
        const Offset(310, 0),
        const Offset(330, 2),
        const Offset(350, 0),
      ]);
      pts.sort((a, b) => a.dx.compareTo(b.dx));
    }
    
    return ECGBeat(pontosDeControle: pts, intervaloRR: 350);
  }

  static ECGBeat tvPolimorfica({required int cicloIndex}) {
    final intervalos = [280.0, 300.0, 270.0, 290.0, 310.0, 280.0];
    final amplitudesR = [5.0, 8.0, 12.0, 10.0, 6.0, 3.0];
    final direcoes = [1.0, 1.0, 1.0, -1.0, -1.0, -1.0];
    
    int idx = cicloIndex % 6;
    double rr = intervalos[idx];
    double ampR = amplitudesR[idx] * direcoes[idx];
    double dir = direcoes[idx];
    
    List<Offset> pts = [
      const Offset(0, 0),
      Offset(10, -3 * dir),
      Offset(40, ampR),
      Offset(80, ampR * 0.8),
      Offset(130, -4 * dir),
      const Offset(160, 0),
      Offset(180, -2 * dir),
      Offset(250, -3 * dir),
      const Offset(270, 0),
      Offset(rr, 0),
    ];
    
    return ECGBeat(pontosDeControle: pts, intervaloRR: rr, irregular: true);
  }
}

class ECGPainter extends CustomPainter {
  final TaquicardiaType type;
  final double stElevation;

  ECGPainter({required this.type, this.stElevation = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    // Fundo
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0A0E1A));

    // Grid
    final gridPaintFino = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;
    final gridPaintMedio = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 10) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), x % 50 == 0 ? gridPaintMedio : gridPaintFino);
    }
    for (double y = 0; y < size.height; y += 10) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), y % 50 == 0 ? gridPaintMedio : gridPaintFino);
    }

    final pathPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    double xOffset = 0;
    int cicloIndex = 0;
    Path path = Path();
    bool firstPoint = true;
    double baseY = size.height / 2;

    while (xOffset < size.width * 4) { // Gera pontos suficientes
      ECGBeat beat = _getBeatForType(type, cicloIndex, stElevation);
      
      _drawBeat(path, beat, xOffset, baseY, firstPoint);
      firstPoint = false;
      
      xOffset += beat.intervaloRR * 0.25; // 25mm/s -> 0.25px/ms
      cicloIndex++;
    }

    canvas.drawPath(path, pathPaint);
  }

  ECGBeat _getBeatForType(TaquicardiaType t, int index, double st) {
    switch (t) {
      case TaquicardiaType.sinusal:
        return ECGBeats.sinusal(stElevation: st);
      case TaquicardiaType.atrial: // Fallback
      case TaquicardiaType.faComWpw:
        return ECGBeats.faComWpw(cicloIndex: index);
      case TaquicardiaType.flutter:
        return ECGBeats.flutterAtrial();
      case TaquicardiaType.svt:
        return ECGBeats.svt(first: index == 0);
      case TaquicardiaType.vtMonomorfica:
        return ECGBeats.tvMonomorfica(cicloIndex: index);
      case TaquicardiaType.vtPolimorfica:
        return ECGBeats.tvPolimorfica(cicloIndex: index);
      default:
        return ECGBeats.fibrilacaoAtrial(cicloIndex: index);
    }
  }

  void _drawBeat(Path path, ECGBeat beat, double startX, double baseY, bool first) {
    for (int i = 0; i < beat.pontosDeControle.length; i++) {
      Offset p = beat.pontosDeControle[i];
      // x em ms -> x em px (* 0.25)
      // y em mm -> y em px (* 10)
      double px = startX + (p.dx * 0.25);
      double py = baseY - (p.dy * 10);

      if (first && i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ECGPainter oldDelegate) => 
      oldDelegate.type != type || oldDelegate.stElevation != stElevation;
}
