import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:teachmate_pro/features/exam_creation/domain/models/exam_model.dart';
import 'package:teachmate_pro/features/exam_creation/presentation/utils/pdf_generator.dart';

class ExamPdfPreview extends StatelessWidget {
  final List<ExamQuestion> questions;
  final Map<String, dynamic> examInfo;

  const ExamPdfPreview({
    super.key,
    required this.questions,
    required this.examInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Önizleme'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final pdf = await generateExamPdf(questions, examInfo);
              final success = await savePdfToDownloads(pdf, 'sinav');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'PDF başarıyla indirildi'
                          : 'PDF indirilemedi. Lütfen izinleri kontrol edin.',
                    ),
                  ),
                );
              }
            },
            tooltip: 'PDF İndir',
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => generateExamPdf(questions, examInfo),
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: false,
      ),
    );
  }
}
