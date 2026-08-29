const fs = require('fs');
let text = fs.readFileSync('lib/data/algorithms.dart', 'utf8');
if (text.charCodeAt(0) === 0xFEFF) {
    text = text.slice(1);
}
// Also remove it if it got injected in the middle
text = text.replace(/\uFEFF/g, '');
fs.writeFileSync('lib/data/algorithms.dart', text, 'utf8');
console.log("BOM removed");
