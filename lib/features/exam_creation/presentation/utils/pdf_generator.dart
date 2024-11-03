import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:teachmate_pro/features/exam_creation/domain/models/exam_model.dart';

Future<Uint8List> generateExamPdf(
  List<ExamQuestion> questions,
  Map<String, dynamic> examInfo,
) async {
  final pdf = pw.Document();
  final font = await _loadFont();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (context) => _buildHeader(context, examInfo, font),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 20),
        child: pw.Text(
          'Sayfa ${context.pageNumber}/${context.pagesCount}',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
      ),
      build: (context) => [
        _buildStudentInfo(font),
        pw.SizedBox(height: 20),
        _buildInstructions(font),
        pw.SizedBox(height: 20),
        ...questions.asMap().entries.map((entry) {
          return _buildQuestion(entry.key, entry.value, font);
        }).toList(),
      ],
    ),
  );

  return pdf.save();
}

Future<pw.Font> _loadFont() async {
  final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  return pw.Font.ttf(fontData);
}

pw.Widget _buildHeader(
  pw.Context context,
  Map<String, dynamic> examInfo,
  pw.Font font,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                examInfo['schoolName'] ?? '',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                examInfo['teacherName'] ?? '',
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                examInfo['academicYear'],
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                examInfo['examPeriod'],
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 20),
      pw.Center(
        child: pw.Text(
          '${examInfo['subject']} DERSİ ${examInfo['examPeriod']} SINAVI',
          style: pw.TextStyle(
            font: font,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Sınıf: ${examInfo['grade']}',
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
          pw.Text(
            'Süre: ${examInfo['duration']} dakika',
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
        ],
      ),
      pw.Divider(),
    ],
  );
}

pw.Widget _buildStudentInfo(pw.Font font) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Adı Soyadı:',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
                pw.Container(
                  height: 20,
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(width: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 40),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Numarası:',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
                pw.Container(
                  height: 20,
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(width: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildInstructions(pw.Font font) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SINAV YÖNERGESİ:',
          style: pw.TextStyle(
            font: font,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          '1. Her sorunun yalnız bir doğru cevabı vardır.',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          '2. Her soru eşit puana sahiptir.',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.Text(
          '3. Yanlış cevaplar doğru cevapları etkilemez.',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
      ],
    ),
  );
}

pw.Widget _buildQuestion(int index, ExamQuestion question, pw.Font font) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 20),
      pw.Text(
        '${index + 1}) ${question.text}',
        style: pw.TextStyle(font: font, fontSize: 12),
      ),
      pw.SizedBox(height: 10),
      ...question.options.asMap().entries.map((entry) {
        final optionLetter = String.fromCharCode(65 + entry.key);
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 20, bottom: 5),
          child: pw.Text(
            '$optionLetter) ${entry.value}',
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
        );
      }).toList(),
    ],
  );
}

Future<bool> savePdfToDownloads(Uint8List pdfBytes, String fileName) async {
  try {
    final status = await Permission.storage.request();
    if (!status.isGranted) return false;

    final downloadDir = Directory('/storage/emulated/0/Download');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    final file = File(
        '${downloadDir.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(pdfBytes);
    return true;
  } catch (e) {
    print('Error saving PDF: $e');
    return false;
  }
}
