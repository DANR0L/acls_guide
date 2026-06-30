import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/algorithm_node.dart';

class DrugCard extends StatelessWidget {
  final DrugInfo drug;
  const DrugCard({super.key, required this.drug});

  Color get _color {
    final hex = drug.color.replaceFirst('#', 'FF');
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _color.withOpacity(0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: badge de categoria + nome ──────────────
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  drug.category.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _color,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            drug.name,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),

          // ── Dados de dosagem ────────────────────────────────
          _DrugRow(
            icon: Icons.colorize_rounded,
            label: 'DOSE',
            value: drug.dose,
            color: _color,
          ),
          const SizedBox(height: 8),
          _DrugRow(
            icon: Icons.vaccines_rounded,
            label: 'VIA',
            value: drug.route,
            color: _color,
          ),
          if (drug.frequency != null) ...[
            const SizedBox(height: 8),
            _DrugRow(
              icon: Icons.schedule_rounded,
              label: 'FREQUÊNCIA',
              value: drug.frequency!,
              color: _color,
            ),
          ],
          if (drug.maxDose != null) ...[
            const SizedBox(height: 8),
            _DrugRow(
              icon: Icons.warning_amber_rounded,
              label: 'DOSE MÁXIMA',
              value: drug.maxDose!,
              color: AppColors.warning,
            ),
          ],

          // ── Notas ───────────────────────────────────────────
          if (drug.notes != null) ...[
            const SizedBox(height: 14),
            _InfoBox(
              icon: Icons.info_outline_rounded,
              text: drug.notes!,
              bgColor: AppColors.surfaceVariant,
              textColor: AppColors.textSecondary,
              iconColor: AppColors.textSecondary,
            ),
          ],

          // ── Indicações ──────────────────────────────────────
          if (drug.indications != null && drug.indications!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _SectionHeader(
              icon: Icons.check_circle_outline_rounded,
              label: 'INDICAÇÕES',
              color: AppColors.secondary,
            ),
            const SizedBox(height: 6),
            ...drug.indications!.map(
              (ind) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ind,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── Contraindicações ────────────────────────────────
          if (drug.contraindications != null) ...[
            const SizedBox(height: 10),
            _InfoBox(
              icon: Icons.block_rounded,
              text: drug.contraindications!,
              bgColor: AppColors.danger.withOpacity(0.08),
              textColor: AppColors.textPrimary,
              iconColor: AppColors.danger,
              label: 'CONTRAINDICAÇÕES',
            ),
          ],
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────

class _DrugRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DrugRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.9,
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bgColor;
  final Color textColor;
  final Color iconColor;
  final String? label;

  const _InfoBox({
    required this.icon,
    required this.text,
    required this.bgColor,
    required this.textColor,
    required this.iconColor,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null) ...[
                  Text(
                    label!,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                ],
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
