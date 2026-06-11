import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'ecg_painter.dart';

class EcgCard extends StatefulWidget {
  /// Identificador do tipo de ECG (ex: 'vf', 'svt', 'asystole'...)
  final String ecgTypeId;
  final String title;
  final List<String>? findings;

  const EcgCard({
    super.key,
    required this.ecgTypeId,
    required this.title,
    this.findings,
  });

  @override
  State<EcgCard> createState() => _EcgCardState();
}

class _EcgCardState extends State<EcgCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ecgType = ecgTypeFromString(widget.ecgTypeId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF060E06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monitor_heart_outlined,
                          color: AppColors.info, size: 12),
                      const SizedBox(width: 5),
                      Text(
                        'ECG',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.info,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (widget.findings != null)
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.info,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),

          // ── Waveform (CustomPainter) ──────────────────────────
          GestureDetector(
            onTap: () => _showFullscreen(context, ecgType),
            child: ClipRRect(
              borderRadius: widget.findings == null || _expanded
                  ? BorderRadius.zero
                  : const BorderRadius.vertical(bottom: Radius.circular(18)),
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 130,
                    child: CustomPaint(
                      painter: EcgPainter(type: ecgType),
                    ),
                  ),
                  Positioned(
                    bottom: 7,
                    right: 9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.zoom_out_map_rounded,
                              color: Colors.white70, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'Ampliar',
                            style: GoogleFonts.inter(
                                fontSize: 10, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Achados diagnósticos ──────────────────────────────
          if (widget.findings != null) ...{
            if (!_expanded)
              TextButton(
                onPressed: () => setState(() => _expanded = true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.info,
                  minimumSize: const Size(double.infinity, 36),
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(18)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      'Ver achados diagnósticos',
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF1A3A1A))),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achados Diagnósticos',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.info,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.findings!.map(
                      (f) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('▸  ',
                                style: TextStyle(
                                    color: AppColors.info,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                f,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 200.ms),
          },
        ],
      ),
    );
  }

  void _showFullscreen(BuildContext context, EcgType ecgType) {
    showDialog(
      context: context,
      barrierColor: const Color(0xE6000000),
      builder: (_) => GestureDetector(
        onTap: Navigator.of(context).pop,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF00E676).withValues(alpha: 0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomPaint(
                      painter: EcgPainter(type: ecgType),
                      child: const SizedBox(
                          width: double.infinity, height: 220),
                    ),
                  ),
                ),
                if (widget.findings != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.findings!
                          .map((f) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text('▸  ',
                                        style: TextStyle(
                                            color: Color(0xFF00E676),
                                            fontSize: 12)),
                                    Expanded(
                                      child: Text(f,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Colors.white70,
                                            height: 1.4,
                                          )),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Toque para fechar',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.white38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
