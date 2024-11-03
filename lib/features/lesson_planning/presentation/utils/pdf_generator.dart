import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';
import 'package:teachmate_pro/features/lesson_planning/domain/models/lesson_plan_model.dart';

Future<pw.Font> _loadFont() async {
  final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  return pw.Font.ttf(fontData);
}

Future<Uint8List> generateLessonPlanPDF(LessonPlanModel plan) async {
  final pdf = pw.Document();
  final font = await _loadFont();

  // Custom styles with Turkish character support
  final titleStyle = pw.TextStyle(
    font: font,
    fontSize: 24,
    fontWeight: pw.FontWeight.bold,
  );
  final headingStyle = pw.TextStyle(
    font: font,
    fontSize: 18,
    fontWeight: pw.FontWeight.bold,
  );
  final subheadingStyle = pw.TextStyle(
    font: font,
    fontSize: 16,
    fontWeight: pw.FontWeight.bold,
  );
  final subSubheadingStyle = pw.TextStyle(
    font: font,
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
  );
  final bodyStyle = pw.TextStyle(
    font: font,
    fontSize: 12,
  );
  final boldStyle = pw.TextStyle(
    font: font,
    fontSize: 12,
    fontWeight: pw.FontWeight.bold,
  );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(plan.topic, style: titleStyle),
              pw.SizedBox(height: 8),
              pw.Text(
                '${plan.subject} - ${plan.grade}. Sınıf',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 14,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Divider(thickness: 2),
            ],
          ),
        ),
        ...parseContentToPDFWidgets(
          plan.content,
          headingStyle,
          subheadingStyle,
          subSubheadingStyle,
          bodyStyle,
          boldStyle,
        ),
      ],
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 16),
        child: pw.Text(
          'Sayfa ${context.pageNumber}/${context.pagesCount}',
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
      ),
    ),
  );

  return pdf.save();
}

List<pw.Widget> parseContentToPDFWidgets(
  String content,
  pw.TextStyle headingStyle,
  pw.TextStyle subheadingStyle,
  pw.TextStyle subSubheadingStyle,
  pw.TextStyle bodyStyle,
  pw.TextStyle boldStyle,
) {
  final List<pw.Widget> widgets = [];
  final lines = content.split('\n');
  List<String> currentBulletGroup = [];

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];

    // Handle divider lines
    if (line.trim() == '**') {
      if (currentBulletGroup.isNotEmpty) {
        widgets.add(createBulletList(currentBulletGroup, bodyStyle, boldStyle));
        currentBulletGroup = [];
      }
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 16),
          child: pw.Divider(
            thickness: 1,
            color: PdfColors.grey400,
          ),
        ),
      );
      continue;
    }

    // Handle headings
    if (line.startsWith('# ')) {
      if (currentBulletGroup.isNotEmpty) {
        widgets.add(createBulletList(currentBulletGroup, bodyStyle, boldStyle));
        currentBulletGroup = [];
      }
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
          child: pw.Text(line.substring(2), style: headingStyle),
        ),
      );
    } else if (line.startsWith('## ')) {
      if (currentBulletGroup.isNotEmpty) {
        widgets.add(createBulletList(currentBulletGroup, bodyStyle, boldStyle));
        currentBulletGroup = [];
      }
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 12, bottom: 6),
          child: pw.Text(line.substring(3), style: subheadingStyle),
        ),
      );
    } else if (line.startsWith('### ')) {
      if (currentBulletGroup.isNotEmpty) {
        widgets.add(createBulletList(currentBulletGroup, bodyStyle, boldStyle));
        currentBulletGroup = [];
      }
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
          child: pw.Text(line.substring(4), style: subSubheadingStyle),
        ),
      );
    } else if (line.startsWith('* ') || line.startsWith('  * ')) {
      currentBulletGroup.add(line);
    } else if (line.isNotEmpty) {
      if (currentBulletGroup.isNotEmpty) {
        widgets.add(createBulletList(currentBulletGroup, bodyStyle, boldStyle));
        currentBulletGroup = [];
      }
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: formatTextWithBold(line, bodyStyle, boldStyle),
        ),
      );
    }
  }

  if (currentBulletGroup.isNotEmpty) {
    widgets.add(createBulletList(currentBulletGroup, bodyStyle, boldStyle));
  }

  return widgets;
}

pw.Widget createBulletList(
  List<String> items,
  pw.TextStyle bodyStyle,
  pw.TextStyle boldStyle,
) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: items.map((item) {
        final isSubItem = item.startsWith('  * ');
        final text = isSubItem ? item.substring(4) : item.substring(2);
        return pw.Padding(
          padding: pw.EdgeInsets.only(left: isSubItem ? 24 : 8),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(isSubItem ? '▪' : '•', style: bodyStyle),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: formatTextWithBold(text, bodyStyle, boldStyle),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}

pw.Widget formatTextWithBold(
  String text,
  pw.TextStyle normalStyle,
  pw.TextStyle boldStyle,
) {
  final List<pw.TextSpan> spans = [];
  final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
  int currentPosition = 0;

  for (final match in boldPattern.allMatches(text)) {
    if (match.start > currentPosition) {
      spans.add(pw.TextSpan(
        text: text.substring(currentPosition, match.start),
        style: normalStyle,
      ));
    }

    spans.add(pw.TextSpan(
      text: match.group(1),
      style: boldStyle,
    ));

    currentPosition = match.end;
  }

  if (currentPosition < text.length) {
    spans.add(pw.TextSpan(
      text: text.substring(currentPosition),
      style: normalStyle,
    ));
  }

  return pw.RichText(
    text: pw.TextSpan(children: spans),
  );
}

Future<bool> savePDFToDownloads(Uint8List pdfBytes, String fileName) async {
  try {
    // Request storage permission
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      return false;
    }

    // Create the documents directory if it doesn't exist
    final documentsDir = Directory('/storage/emulated/0/Download');
    if (!await documentsDir.exists()) {
      await documentsDir.create(recursive: true);
    }

    // Save the file
    final file =
        File('${documentsDir.path}/${fileName.replaceAll(' ', '_')}.pdf');
    await file.writeAsBytes(pdfBytes);
    return true;
  } catch (e) {
    print('Error saving PDF: $e');
    return false;
  }
}

Future<void> sharePDF(Uint8List pdfBytes, String fileName) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/${fileName.replaceAll(' ', '_')}.pdf');
  await file.writeAsBytes(pdfBytes);
  await Share.shareXFiles([XFile(file.path)], text: 'Ders Planı: $fileName');
}
