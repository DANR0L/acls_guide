import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  int sampleRate = 44100;
  double duration = 0.15;
  double frequency = 1000.0;
  
  int numSamples = (sampleRate * duration).toInt();
  var data = Int16List(numSamples);
  for(int i=0; i<numSamples; i++) {
    data[i] = (32767 * sin(2 * pi * frequency * i / sampleRate)).toInt();
  }
  
  var byteData = data.buffer.asUint8List();
  var fileLength = 36 + byteData.length;
  
  var header = BytesBuilder();
  header.add('RIFF'.codeUnits);
  header.add([fileLength & 0xff, (fileLength >> 8) & 0xff, (fileLength >> 16) & 0xff, (fileLength >> 24) & 0xff]);
  header.add('WAVE'.codeUnits);
  header.add('fmt '.codeUnits);
  header.add([16, 0, 0, 0, 1, 0, 1, 0, 0x44, 0xac, 0, 0, 0x88, 0x58, 0x01, 0x00, 2, 0, 16, 0]);
  header.add('data'.codeUnits);
  header.add([byteData.length & 0xff, (byteData.length >> 8) & 0xff, (byteData.length >> 16) & 0xff, (byteData.length >> 24) & 0xff]);
  header.add(byteData);
  
  Directory('assets/audio').createSync(recursive: true);
  File('assets/audio/beep.wav').writeAsBytesSync(header.takeBytes());
  print('Beep generated at assets/audio/beep.wav');
}
