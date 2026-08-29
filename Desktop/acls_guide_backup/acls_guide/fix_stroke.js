const fs = require('fs');
let text = fs.readFileSync('lib/data/algorithms.dart', 'utf8');
let newStroke = fs.readFileSync('scratch_stroke.dart', 'utf8');
newStroke = newStroke.replace("import '../models/algorithm_node.dart';\r\n\r\n", "");
newStroke = newStroke.replace("import '../models/algorithm_node.dart';\n\n", "");

let startIdx = text.indexOf('final strokeAlgorithm = Algorithm(');
let endIdx = text.indexOf('final allAlgorithms = <String, Algorithm>{');
if (startIdx !== -1 && endIdx !== -1) {
    let result = text.substring(0, startIdx) + newStroke + '\n\n' + text.substring(endIdx);
    fs.writeFileSync('lib/data/algorithms.dart', result, 'utf8');
    console.log("Success!");
} else {
    console.log("Could not find boundaries.");
}
