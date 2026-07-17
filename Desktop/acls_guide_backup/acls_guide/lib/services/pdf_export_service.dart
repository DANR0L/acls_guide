import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/cpr_dynamic_provider.dart';

/// Remove emojis e caracteres Unicode especiais que a fonte Helvetica não suporta
String _sanitize(String text) {
  // Remove emojis e símbolos Unicode fora do range Latin-1
  return text.replaceAll(RegExp(
    r'[\u{1F600}-\u{1F64F}]|'  // Emoticons
    r'[\u{1F300}-\u{1F5FF}]|'  // Misc Symbols and Pictographs
    r'[\u{1F680}-\u{1F6FF}]|'  // Transport and Map
    r'[\u{1F1E0}-\u{1F1FF}]|'  // Flags
    r'[\u{2702}-\u{27B0}]|'    // Dingbats
    r'[\u{FE00}-\u{FE0F}]|'    // Variation Selectors
    r'[\u{1F900}-\u{1F9FF}]|'  // Supplemental Symbols
    r'[\u{2600}-\u{26FF}]|'    // Misc symbols (⚠️ etc)
    r'[\u{2300}-\u{23FF}]|'    // Misc Technical (⏰ etc)
    r'[\u{200D}]|'              // Zero Width Joiner
    r'[\u{20E3}]|'              // Combining Enclosing Keycap
    r'[\u{E0020}-\u{E007F}]',   // Tags
    unicode: true,
  ), '').trim();
}

class PdfExportService {
  static Future<void> exportCprLog(CprDynamicState state, {Function(String)? onError}) async {
    try {
      final pdf = pw.Document();

      final font = pw.Font.helvetica();
      final fontBold = pw.Font.helveticaBold();

      final now = DateTime.now();
      final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final startTime = state.startTime != null 
          ? '${state.startTime!.hour.toString().padLeft(2, '0')}:${state.startTime!.minute.toString().padLeft(2, '0')}:${state.startTime!.second.toString().padLeft(2, '0')}'
          : '--:--:--';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              _buildHeader(fontBold, font, dateStr, timeStr),
              pw.SizedBox(height: 20),
              _buildSummaryTable(state, font, fontBold, startTime),
              pw.SizedBox(height: 20),
              pw.Text(
                'Linha do Tempo (Log de Eventos)',
                style: pw.TextStyle(font: fontBold, fontSize: 16),
              ),
              pw.SizedBox(height: 10),
              _buildLogsTable(state.logs.reversed.toList(), font, fontBold),
              pw.SizedBox(height: 40),
              _buildSignatures(font),
            ];
          },
        ),
      );

      final bytes = await pdf.save();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'Relatorio_PCR_$dateStr',
      );
    } catch (e) {
      if (onError != null) {
        onError(e.toString());
      }
    }
  }

  static pw.Widget _buildHeader(pw.Font fontBold, pw.Font font, String date, String time) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'RELATÓRIO DE ATENDIMENTO DE EMERGÊNCIA — PCR',
          style: pw.TextStyle(font: fontBold, fontSize: 20),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Gerado em: $date às $time',
          style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 16),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Text('Paciente: ', style: pw.TextStyle(font: fontBold)),
                  pw.Expanded(
                    child: pw.Container(
                      height: 14,
                      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5))),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                children: [
                  pw.Text('Idade: ', style: pw.TextStyle(font: fontBold)),
                  pw.Container(
                    width: 60,
                    height: 14,
                    decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5))),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Text('Leito/Setor: ', style: pw.TextStyle(font: fontBold)),
                  pw.Expanded(
                    child: pw.Container(
                      height: 14,
                      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryTable(CprDynamicState state, pw.Font font, pw.Font fontBold, String startTime) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryCol('Início', startTime, fontBold, font),
          _buildSummaryCol('Tempo CPR', state.formatTime(state.elapsedSeconds), fontBold, font),
          _buildSummaryCol('Choques', '${state.shockCount}', fontBold, font),
          _buildSummaryCol('Epinefrina', '${state.epiCount} doses', fontBold, font),
          _buildSummaryCol('Antiarrítmico', '${state.amioLidoCount} doses', fontBold, font),
          _buildSummaryCol('ROSC', state.isRosc ? 'Sim' : 'Não', fontBold, font),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryCol(String label, String value, pw.Font fontBold, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 12)),
      ],
    );
  }

  static pw.Widget _buildLogsTable(List<CprLogEvent> logs, pw.Font font, pw.Font fontBold) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(60),
        1: const pw.FixedColumnWidth(80),
        2: const pw.FlexColumnWidth(),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Tempo CPR', fontBold, isHeader: true),
            _buildTableCell('Hora Real', fontBold, isHeader: true),
            _buildTableCell('Evento / Conduta', fontBold, isHeader: true),
          ],
        ),
        // Rows
        ...logs.map((log) {
          final hr = log.realTime;
          final timeStr = '${hr.hour.toString().padLeft(2, '0')}:${hr.minute.toString().padLeft(2, '0')}:${hr.second.toString().padLeft(2, '0')}';
          return pw.TableRow(
            children: [
              _buildTableCell(_sanitize(log.timeText), font),
              _buildTableCell(timeStr, font),
              _buildTableCell(_sanitize(log.message), log.isAlert ? fontBold : font),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
          color: isHeader ? PdfColors.black : PdfColors.grey800,
        ),
      ),
    );
  }

  static pw.Widget _buildSignatures(pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        pw.Column(
          children: [
            pw.Container(width: 200, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 4),
            pw.Text('Médico Líder (Assinatura e CRM)', style: pw.TextStyle(font: font, fontSize: 10)),
          ],
        ),
        pw.Column(
          children: [
            pw.Container(width: 200, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 4),
            pw.Text('Enfermeiro(a) (Assinatura e COREN)', style: pw.TextStyle(font: font, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
