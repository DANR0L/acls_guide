import 'dart:io';

void main() {
  var file = File(r'c:\Users\danro\Desktop\acls_guide_backup\acls_guide\lib\ui\screens\cpr_dashboard_screen.dart');
  var lines = file.readAsLinesSync();

  // Find the end of the Other Drugs modal list
  int insertIdx = -1;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains("notifier.registerDrug('Sulfato de Magnésio 1-2g IV');")) {
      for (int j = i; j < lines.length; j++) {
        if (lines[j].contains("),") && lines[j-1].contains("},")) {
          // This is the end of the ListTile for Magnesium
          insertIdx = j + 1;
          break;
        }
      }
      break;
    }
  }

  if (insertIdx != -1) {
    lines.insertAll(insertIdx, [
      "              ListTile(",
      "                leading: const Icon(Icons.water_drop_rounded, color: AppColors.info),",
      "                title: Text('Bolus de Cristaloides', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),",
      "                subtitle: Text('500 - 1000 mL IV (Hipovolemia)', style: GoogleFonts.inter(color: AppColors.textSecondary)),",
      "                onTap: () {",
      "                  notifier.registerDrug('Bolus de Cristaloides 500-1000 mL');",
      "                  Navigator.pop(ctx);",
      "                },",
      "              ),",
      "              ListTile(",
      "                leading: const Icon(Icons.medication_liquid_rounded, color: AppColors.info),",
      "                title: Text('Glicose 50%', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),",
      "                subtitle: Text('20 - 50 mL IV (Hipoglicemia)', style: GoogleFonts.inter(color: AppColors.textSecondary)),",
      "                onTap: () {",
      "                  notifier.registerDrug('Glicose 50% (20-50 mL) IV');",
      "                  Navigator.pop(ctx);",
      "                },",
      "              ),",
      "              ListTile(",
      "                leading: const Icon(Icons.vaccines_rounded, color: AppColors.info),",
      "                title: Text('Naloxona (Narcan)', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),",
      "                subtitle: Text('0,4 - 2 mg IV/IO/IN (Intoxicação Opioide)', style: GoogleFonts.inter(color: AppColors.textSecondary)),",
      "                onTap: () {",
      "                  notifier.registerDrug('Naloxona 0,4 - 2 mg');",
      "                  Navigator.pop(ctx);",
      "                },",
      "              ),",
      "              ListTile(",
      "                leading: const Icon(Icons.bloodtype_rounded, color: AppColors.danger),",
      "                title: Text('Trombolítico (Alteplase)', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),",
      "                subtitle: Text('50 mg IV bolus (Suspeita de TEP Maciço)', style: GoogleFonts.inter(color: AppColors.textSecondary)),",
      "                onTap: () {",
      "                  notifier.registerDrug('Alteplase 50 mg IV bolus');",
      "                  Navigator.pop(ctx);",
      "                },",
      "              ),",
    ]);
    print('done - added extra drugs to modal');
  } else {
    print('error - could not find insertion point');
  }

  file.writeAsStringSync(lines.join('\n'));
}
