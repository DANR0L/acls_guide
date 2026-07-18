import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/ecg_patterns.dart';
import '../../painters/ecg_painter.dart';

class TelaDeRitmos extends StatefulWidget {
  const TelaDeRitmos({super.key});

  @override
  State<TelaDeRitmos> createState() => _TelaDeRitmosState();
}

class _TelaDeRitmosState extends State<TelaDeRitmos> {
  TaquicardiaType _selectedType = TaquicardiaType.sinusal;
  double _stElevation = 0.0;

  final Map<TaquicardiaType, String> _ritmosLabels = {
    TaquicardiaType.sinusal: 'Taquicardia Sinusal',
    TaquicardiaType.atrial: 'Fibrilação Atrial', // FA
    TaquicardiaType.flutter: 'Flutter Atrial',
    TaquicardiaType.svt: 'TSV / TRN',
    TaquicardiaType.faComWpw: 'FA com WPW',
    TaquicardiaType.vtMonomorfica: 'TV Monomórfica',
    TaquicardiaType.vtPolimorfica: 'TV Polimórfica (Torsades)',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        title: Text(
          'Ritmos ECG',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
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
            // Container do ECG: 400x150
            Center(
              child: Container(
                width: 400,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color: const Color(0xFF2E7D32).withOpacity(0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomPaint(
                    size: const Size(400, 150),
                    painter: ECGPainter(
                      type: _selectedType,
                      stElevation: _stElevation,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Dropdown para selecionar o ritmo
            Text(
              'Selecione o Ritmo:',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TaquicardiaType>(
                  value: _selectedType,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF111827),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                  items: _ritmosLabels.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text(
                        e.value,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedType = val;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Slider para ST Elevation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Desnível ST (mm):',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _stElevation > 0
                      ? '+${_stElevation.toStringAsFixed(1)} mm'
                      : '${_stElevation.toStringAsFixed(1)} mm',
                  style: GoogleFonts.inter(
                    color: _stElevation == 0
                        ? Colors.white
                        : (_stElevation > 0 ? Colors.redAccent : Colors.blueAccent),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF00FF41),
                inactiveTrackColor: Colors.white12,
                thumbColor: Colors.white,
                overlayColor: const Color(0xFF00FF41).withOpacity(0.2),
              ),
              child: Slider(
                value: _stElevation,
                min: -5.0,
                max: 5.0,
                divisions: 20,
                onChanged: (val) {
                  setState(() {
                    _stElevation = val;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Info Adicional do Ritmo Atual
            _buildRitmoInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildRitmoInfo() {
    final info = taquicardias[_selectedType];
    if (info == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Características',
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
            info.descricao,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Conduta ACLS',
            style: GoogleFonts.inter(
              color: Colors.redAccent,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            info.conduta,
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
