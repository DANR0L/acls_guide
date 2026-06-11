import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Sobre', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: const Center(
                        child: Text('🫀', style: TextStyle(fontSize: 40))),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ACLS Guide 2025',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Versão 1.0.0 · AHA Guidelines 2025',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppColors.danger, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Aviso Importante',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Este aplicativo é uma ferramenta de APOIO À DECISÃO CLÍNICA destinada a profissionais de saúde treinados. Não substitui o julgamento clínico, o treinamento formal em ACLS, nem as diretrizes oficiais da AHA. '
                    'Sempre consulte as publicações oficiais da American Heart Association para as orientações mais atualizadas.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // Content info
            _InfoSection(
              title: 'Conteúdo Clínico',
              items: [
                '📋 Baseado nas diretrizes AHA 2025 para RCP e ECC',
                '🫀 PCR — VF/pVT, Assistolia, AESP',
                '🐢 Bradicardia com pulso',
                '⚡ Taquicardia com pulso (estreita/larga)',
                '🟢 Cuidados pós-PCR (ROSC)',
                '❤️‍🔥 SCA — IAMCSST',
                '💊 Referência completa de fármacos ACLS',
                '⏱️ Timer integrado para ciclos de CPR',
              ],
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 16),

            _InfoSection(
              title: 'Recursos',
              items: [
                '🌙 Interface dark mode — otimizada para emergências',
                '📱 Botões grandes — uso com luvas cirúrgicas',
                '⚡ Funciona 100% offline',
                '🔄 Árvore de decisão dinâmica',
                '🔙 Navegação para voltar passos',
              ],
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

            const SizedBox(height: 16),

            _InfoSection(
              title: 'Referências',
              items: [
                'AHA 2025 Guidelines for CPR and ECC',
                'Circulation. 2025 (Novembro — edição especial)',
                'ACLS Provider Manual — AHA 2025',
                'ILCOR CoSTR 2025',
              ],
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _InfoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
