import 'dart:io';

void main() {
  var file = File(r'c:\Users\danro\Desktop\acls_guide_backup\acls_guide\lib\ui\screens\cpr_dashboard_screen.dart');
  var lines = file.readAsLinesSync();

  // 1. Insert the "Outras Drogas" button before the ROSC button.
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains("label: '✅ ROSC',") && lines[i-1].contains("_ActionBtn(")) {
      lines.insertAll(i - 1, [
        "                _ActionBtn(",
        "                  label: '💊 Outras Drogas',",
        "                  icon: Icons.local_pharmacy_rounded,",
        "                  color: const Color(0xFF0EA5E9), // Light blue",
        "                  onTap: () {",
        "                    HapticFeedback.mediumImpact();",
        "                    _showOtherDrugsModal(context, notifier);",
        "                  },",
        "                ),",
      ]);
      break;
    }
  }

  // 2. Insert the `_showOtherDrugsModal` function at the end of the class, before the closing brace of `_CprDashboardScreenState`.
  // First, find `_showTachycardiaModal` to place it right after.
  int insertIdx = -1;
  for (int i = lines.length - 1; i >= 0; i--) {
    if (lines[i].contains("void _showTachycardiaModal(")) {
      // Find the end of this method
      int braces = 0;
      bool started = false;
      for (int j = i; j < lines.length; j++) {
        if (lines[j].contains("{")) {
          braces += '{'.allMatches(lines[j]).length;
          started = true;
        }
        if (lines[j].contains("}")) {
          braces -= '}'.allMatches(lines[j]).length;
        }
        if (started && braces == 0) {
          insertIdx = j + 1;
          break;
        }
      }
      break;
    }
  }

  if (insertIdx != -1) {
    lines.insertAll(insertIdx, [
      "",
      "  void _showOtherDrugsModal(BuildContext context, CprDynamicNotifier notifier) {",
      "    showModalBottomSheet(",
      "      context: context,",
      "      backgroundColor: AppColors.cardBg,",
      "      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),",
      "      builder: (ctx) => SafeArea(",
      "        child: Padding(",
      "          padding: const EdgeInsets.symmetric(vertical: 24),",
      "          child: Column(",
      "            mainAxisSize: MainAxisSize.min,",
      "            children: [",
      "              Text(",
      "                'Drogas Adicionais (AHA)',",
      "                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),",
      "              ),",
      "              const SizedBox(height: 16),",
      "              ListTile(",
      "                leading: const Icon(Icons.medication_liquid_rounded, color: AppColors.info),",
      "                title: Text('Bicarbonato de Sódio 8,4%', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),",
      "                subtitle: Text('1 mEq/kg IV bolus', style: GoogleFonts.inter(color: AppColors.textSecondary)),",
      "                onTap: () {",
      "                  notifier.registerDrug('Bicarbonato de Sódio 8,4% (1 mEq/kg)');",
      "                  Navigator.pop(ctx);",
      "                },",
      "              ),",
      "              ListTile(",
      "                leading: const Icon(Icons.medication_liquid_rounded, color: AppColors.info),",
      "                title: Text('Gluconato de Cálcio 10%', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),",
      "                subtitle: Text('15-30 mL IV (ou Cloreto 10% 5-10mL)', style: GoogleFonts.inter(color: AppColors.textSecondary)),",
      "                onTap: () {",
      "                  notifier.registerDrug('Cálcio (Gluconato 15-30mL ou Cloreto 5-10mL)');",
      "                  Navigator.pop(ctx);",
      "                },",
      "              ),",
      "              ListTile(",
      "                leading: const Icon(Icons.medication_liquid_rounded, color: AppColors.info),",
      "                title: Text('Sulfato de Magnésio 10%', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),",
      "                subtitle: Text('1-2 g IV/IO (Torsades)', style: GoogleFonts.inter(color: AppColors.textSecondary)),",
      "                onTap: () {",
      "                  notifier.registerDrug('Sulfato de Magnésio 1-2g IV');",
      "                  Navigator.pop(ctx);",
      "                },",
      "              ),",
      "            ],",
      "          ),",
      "        ),",
      "      ),",
      "    );",
      "  }",
    ]);
  }

  file.writeAsStringSync(lines.join('\n'));
  print('done - other drugs modal added');
}
