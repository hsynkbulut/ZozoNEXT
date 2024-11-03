import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:teachmate_pro/features/lesson_planning/domain/models/lesson_plan_model.dart';
import 'package:teachmate_pro/features/lesson_planning/presentation/utils/pdf_generator.dart';

class PDFPreviewDialog extends StatefulWidget {
  final LessonPlanModel plan;

  const PDFPreviewDialog({
    super.key,
    required this.plan,
  });

  @override
  State<PDFPreviewDialog> createState() => _PDFPreviewDialogState();
}

class _PDFPreviewDialogState extends State<PDFPreviewDialog> {
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;
  final double _minScale = 0.5;
  final double _maxScale = 3.0;

  void _handleZoomIn() {
    final newScale = (_currentScale + 0.25).clamp(_minScale, _maxScale);
    _updateScale(newScale);
  }

  void _handleZoomOut() {
    final newScale = (_currentScale - 0.25).clamp(_minScale, _maxScale);
    _updateScale(newScale);
  }

  void _updateScale(double newScale) {
    setState(() {
      _currentScale = newScale;
      final value = Matrix4.identity()..scale(_currentScale);
      _transformationController.value = value;
    });
  }

  void _handleScaleUpdate(double scale) {
    final newScale = (_currentScale * scale).clamp(_minScale, _maxScale);
    if (newScale != _currentScale) {
      _updateScale(newScale);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 20,
            right: 20,
          ),
        ),
      );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Önizleme'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: _handleZoomOut,
            tooltip: 'Uzaklaştır',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: _handleZoomIn,
            tooltip: 'Yakınlaştır',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final pdf = await generateLessonPlanPDF(widget.plan);
              final success = await savePDFToDownloads(pdf, widget.plan.topic);

              _showSnackBar(
                success
                    ? 'PDF başarıyla İndirilenler (Download) klasörüne kaydedildi'
                    : 'PDF kaydedilemedi. Lütfen depolama iznini kontrol edin.',
              );
            },
            tooltip: 'PDF İndir',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final pdf = await generateLessonPlanPDF(widget.plan);
              await sharePDF(pdf, widget.plan.topic);
            },
            tooltip: 'Paylaş',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Yakınlaştırma: ${(_currentScale * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onScaleUpdate: (details) => _handleScaleUpdate(details.scale),
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: _minScale,
                maxScale: _maxScale,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                child: PdfPreview(
                  build: (format) => generateLessonPlanPDF(widget.plan),
                  initialPageFormat: PdfPageFormat.a4,
                  allowPrinting: true,
                  allowSharing: false,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  maxPageWidth: 700,
                  pdfPreviewPageDecoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  scrollViewDecoration: BoxDecoration(
                    color: Colors.grey.shade100,
                  ),
                  previewPageMargin: const EdgeInsets.all(16),
                  loadingWidget: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
