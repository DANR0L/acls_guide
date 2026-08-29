import 'dart:io';

void main() {
  var file = File(r'c:\Users\danro\Desktop\acls_guide_backup\acls_guide\lib\data\algorithms.dart');
  var lines = file.readAsLinesSync();

  // 1. In 'ecg_sca', add lab collection
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains("title: '⚡ ECG em 10 minutos — URGENTE',")) {
      for (int j = i + 1; j < lines.length; j++) {
        if (lines[j].trim() == '],') {
          lines.insert(j, "        '🩸 Coletar: troponina hs, hemograma, creatinina, coagulograma, eletrólitos, glicemia',");
          break;
        }
      }
      break;
    }
  }

  // 2. In 'reperfusion_strategy', add subtitle warning
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains("title: 'Estratégia de Reperfusão',")) {
      for (int j = i + 1; j < lines.length; j++) {
        if (lines[j].contains("subtitle: ")) {
          // Instead of modifying subtitle, let's add an alertLevel and bullets to reperfusion_strategy
          lines.insertAll(j + 1, [
            "      alertLevel: 'warning',",
            "      bullets: [",
            "        '⚠️ Se INR > 1,7 ou plaquetas < 100.000: trombólise é contraindicada (preferir ICP)',",
            "      ],",
          ]);
          break;
        }
      }
      break;
    }
  }

  // 3. In 'thrombolysis_ci', add pending exams warning
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains("title: '⚠️ Contraindicações Absolutas à Trombólise',")) {
      for (int j = i + 1; j < lines.length; j++) {
        if (lines[j].trim() == '],') {
          lines.insert(j, "        '⚠️ Se INR ou plaquetas pendentes e história suspeita: considerar ICP como via mais segura',");
          break;
        }
      }
      break;
    }
  }

  file.writeAsStringSync(lines.join('\n'));
  print('done - labs fixes applied');
}
