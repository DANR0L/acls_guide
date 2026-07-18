import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/ecg_patterns.dart';
import '../../painters/ecg_painter.dart';

// =================================================================
// TELA PRINCIPAL - Lista de Ritmos ECG
// =================================================================

class TelaDeRitmos extends StatelessWidget {
  const TelaDeRitmos({super.key});

  @override
  Widget build(BuildContext context) {
    final ritmos = taquicardias.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        title: Text(
          'Ritmos ECG - ACLS',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ritmos.length,
        itemBuilder: (context, index) {
          final ritmo = ritmos[index];
          return _RitmoCard(ritmo: ritmo);
        },
      ),
    );
  }
}

// =================================================================
// CARD de cada ritmo
// =================================================================

class _RitmoCard extends StatelessWidget {
  final ECGPattern ritmo;
  const _RitmoCard({required this.ritmo});

  Color _cardColor() {
    switch (ritmo.type) {
      case TaquicardiaType.sinusal:
        return const Color(0xFF1B5E20);
      case TaquicardiaType.atrial:
      case TaquicardiaType.flutter:
        return const Color(0xFF1A237E);
      case TaquicardiaType.svt:
        return const Color(0xFF4A148C);
      case TaquicardiaType.faComWpw:
        return const Color(0xFFE65100);
      case TaquicardiaType.vtMonomorfica:
        return const Color(0xFFB71C1C);
      case TaquicardiaType.vtPolimorfica:
        return const Color(0xFF880E4F);
    }
  }

  IconData _cardIcon() {
    switch (ritmo.type) {
      case TaquicardiaType.sinusal:
        return Icons.favorite;
      case TaquicardiaType.atrial:
      case TaquicardiaType.flutter:
        return Icons.waves;
      case TaquicardiaType.svt:
        return Icons.electric_bolt;
      case TaquicardiaType.faComWpw:
        return Icons.warning_amber;
      case TaquicardiaType.vtMonomorfica:
        return Icons.monitor_heart;
      case TaquicardiaType.vtPolimorfica:
        return Icons.dangerous;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _cardColor().withValues(alpha: 0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TelaDetalheRitmo(ritmo: ritmo),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomPaint(
                    painter: ECGPainter(
                      type: ritmo.type,
                      stElevation: ritmo.stElevation,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_cardIcon(), color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ritmo.nome,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ritmo.descricao,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _InfoChip(
                          label: 'FC: ${ritmo.frequencia.toInt()} bpm',
                          color: Colors.white24,
                        ),
                        _InfoChip(
                          label: ritmo.regular ? 'Regular' : 'Irregular',
                          color: ritmo.regular
                              ? const Color(0x4D4CAF50)
                              : const Color(0x4DFF9800),
                        ),
                        _InfoChip(
                          label: ritmo.complexoAlargado ? 'QRS Largo' : 'QRS Estreito',
                          color: ritmo.complexoAlargado
                              ? const Color(0x4DF44336)
                              : const Color(0x4D2196F3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// =================================================================
// TELA DE DETALHES - ECG animado + informacoes do ritmo
// =================================================================

class TelaDetalheRitmo extends StatefulWidget {
  final ECGPattern ritmo;
  const TelaDetalheRitmo({super.key, required this.ritmo});

  @override
  State<TelaDetalheRitmo> createState() => _TelaDetalheRitmoState();
}

class _TelaDetalheRitmoState extends State<TelaDetalheRitmo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ritmo = widget.ritmo;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        title: Text(
          ritmo.nome,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ECG ANIMADO
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0x4D00FF41),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A00FF41),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: ECGPainter(
                        type: ritmo.type,
                        stElevation: ritmo.stElevation,
                        animationValue: _controller.value,
                      ),
                      size: const Size(double.infinity, 180),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'ECG - ${ritmo.nome}',
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF00FF41),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // DESCRICAO
            _DetailSection(
              icon: Icons.info_outline,
              title: 'Descricao',
              content: ritmo.descricao,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            // PARAMETROS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parametros',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ParamRow('Frequencia', '${ritmo.frequencia.toInt()} bpm'),
                  _ParamRow('QRS', '${ritmo.duracaoQrs.toInt()} ms (${ritmo.complexoAlargado ? "LARGO" : "estreito"})'),
                  _ParamRow('Ritmo', ritmo.regular ? 'Regular' : 'Irregular'),
                  _ParamRow('Amplitude R', '${ritmo.amplitudeR.toInt()} px'),
                  if (ritmo.stElevation != 0)
                    _ParamRow('Segmento ST', ritmo.stElevation > 0
                        ? 'Supra (${ritmo.stElevation} mm)'
                        : 'Infra (${ritmo.stElevation} mm)'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // CONDUTA
            _DetailSection(
              icon: Icons.medical_services,
              title: 'Conduta ACLS',
              content: ritmo.conduta,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParamRow extends StatelessWidget {
  final String label;
  final String value;
  const _ParamRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
