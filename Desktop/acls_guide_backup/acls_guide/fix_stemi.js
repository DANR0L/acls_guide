const fs = require('fs');
let content = fs.readFileSync('lib/data/algorithms.dart', 'utf8');

const oldStr = "'💊 Ticagrelor 180 mg VO ou Clopidogrel 600 mg VO',";
const newStr = `'💊 Dose de ataque do Inibidor P2Y12:',
        '   • ICP Primária: Clopidogrel 600mg, Ticagrelor 180mg ou Prasugrel 60mg',
        '   • Trombólise: Clopidogrel 300mg (75mg se > 75 anos)',
        '🚫 Evitar Prasugrel se AVC/AIT prévio',`;

content = content.replace(oldStr, newStr);

// Let's also replace the others just in case
content = content.replace("'💨 O₂ apenas se SpO₂ < 90% (cateter 2–4 L/min)',", "'💨 O₂ apenas se SpO₂ < 90%',");
content = content.replace("'💉 Morfina 2–4 mg IV se dor intensa (usar com cautela)',", "'💉 Morfina se dor severa (cautela)',");
content = content.replace("'💊 Nitroglicerina 0,4 mg SL a cada 5 min (máx 3x) se PA > 90 mmHg (CI: Infarto VD ou PDE5i)',", "'💊 Nitrato se PA > 90 mmHg (CI: VD ou PDE5i)',");

fs.writeFileSync('lib/data/algorithms.dart', content, 'utf8');
console.log('Replaced STEMI successfully');
