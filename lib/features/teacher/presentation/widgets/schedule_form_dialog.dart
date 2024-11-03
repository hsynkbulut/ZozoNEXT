import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';
import 'package:teachmate_pro/core/widgets/app_text_field.dart';
import 'package:teachmate_pro/features/teacher/domain/models/class_schedule_model.dart';
import 'package:teachmate_pro/features/teacher/presentation/providers/class_schedule_provider.dart';

class ScheduleFormDialog extends ConsumerStatefulWidget {
  final ClassSchedule? schedule;
  final DateTime? initialStartTime;
  final DateTime? initialEndTime;

  const ScheduleFormDialog({
    super.key,
    this.schedule,
    this.initialStartTime,
    this.initialEndTime,
  });

  @override
  ConsumerState<ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends ConsumerState<ScheduleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();
  final _topicController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _startTime;
  late DateTime _endTime;
  late String _recurrenceRule;
  late String _color;
  bool _isLoading = false;

  String _selectedGrade = '9. Sınıf';

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    if (widget.schedule != null) {
      _subjectController.text = widget.schedule!.subject;
      _selectedGrade = widget.schedule!.grade;
      _topicController.text = widget.schedule!.topic;
      _notesController.text = widget.schedule!.notes;
      _startTime = widget.schedule!.startTime;
      _endTime = widget.schedule!.endTime;
      _recurrenceRule = widget.schedule!.recurrenceRule;
      _color = widget.schedule!.color;
    } else {
      _startTime = widget.initialStartTime ?? DateTime.now();
      _endTime =
          widget.initialEndTime ?? _startTime.add(const Duration(hours: 1));
      _recurrenceRule = RecurrenceType.none.label;
      _color = _colorOptions.first.value.toRadixString(16).substring(2);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _gradeController.dispose();
    _topicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _startTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          // Adjust end time to maintain duration
          final duration = _endTime.difference(_startTime);
          _endTime = _startTime.add(duration);
        });
      }
    }
  }

  Future<void> _selectEndTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );

    if (pickedTime != null && mounted) {
      setState(() {
        _endTime = DateTime(
          _startTime.year,
          _startTime.month,
          _startTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Widget _buildDateTimeSelectors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Başlangıç',
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectStartTime,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(_startTime),
                              style: AppTextStyles.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bitiş',
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectEndTime,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              DateFormat('HH:mm').format(_endTime),
                              style: AppTextStyles.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Renk',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colorOptions.map((color) {
            final colorString = color.value.toRadixString(16).padLeft(8, '0');
            return InkWell(
              onTap: () {
                setState(() {
                  _color = colorString;
                });
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _color == colorString
                        ? Colors.black
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final schedule = ClassSchedule(
        id: widget.schedule?.id ?? '',
        teacherId: widget.schedule?.teacherId ?? '',
        subject: _subjectController.text,
        grade: _selectedGrade,
        topic: _topicController.text,
        startTime: _startTime,
        endTime: _endTime,
        recurrenceRule: _recurrenceRule,
        notes: _notesController.text,
        color: _color.replaceAll('0xFF', ''),
      );

      if (widget.schedule != null) {
        await ref
            .read(classScheduleControllerProvider)
            .updateSchedule(schedule);
      } else {
        await ref.read(classScheduleControllerProvider).addSchedule(schedule);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.schedule != null
                  ? 'Ders programı güncellendi'
                  : 'Ders programı oluşturuldu',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.schedule != null ? 'Dersi Düzenle' : 'Yeni Ders',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _subjectController,
                  label: 'Ders',
                  hint: 'Dersin adını girin',
                  prefixIcon: Icons.subject_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ders adı zorunludur';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGrade,
                  decoration: const InputDecoration(
                    labelText: 'Sınıf',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: '9. Sınıf', child: Text('9. Sınıf')),
                    DropdownMenuItem(
                        value: '10. Sınıf', child: Text('10. Sınıf')),
                    DropdownMenuItem(
                        value: '11. Sınıf', child: Text('11. Sınıf')),
                    DropdownMenuItem(
                        value: '12. Sınıf', child: Text('12. Sınıf')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedGrade = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sınıf zorunludur';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _topicController,
                  label: 'Konu',
                  hint: 'İşlenecek konuyu girin',
                  prefixIcon: Icons.topic_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konu zorunludur';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildDateTimeSelectors(),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _recurrenceRule,
                  decoration: const InputDecoration(
                    labelText: 'Tekrar',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.repeat_rounded),
                  ),
                  items: RecurrenceType.values.map((type) {
                    return DropdownMenuItem(
                      value: type.label,
                      child: Text(type.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _recurrenceRule = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                _buildColorPicker(),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _notesController,
                  label: 'Notlar',
                  hint: 'Ders ile ilgili notlar...',
                  prefixIcon: Icons.note_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      text: 'İptal',
                      onPressed: () => Navigator.of(context).pop(),
                      variant: AppButtonVariant.text,
                      fullWidth: false,
                    ),
                    if (widget.schedule != null) ...[
                      const SizedBox(width: 8),
                      AppButton(
                        text: 'Sil',
                        onPressed: _isLoading
                            ? null
                            : () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Dersi Sil'),
                                    content: const Text(
                                      'Bu dersi silmek istediğinizden emin misiniz?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('İptal'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Sil'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await ref
                                      .read(classScheduleControllerProvider)
                                      .deleteSchedule(widget.schedule!.id);
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Ders silindi'),
                                      ),
                                    );
                                  }
                                }
                              },
                        variant: AppButtonVariant.text,
                        fullWidth: false,
                        icon: Icons.delete_outline_rounded,
                      ),
                    ],
                    const SizedBox(width: 8),
                    AppButton(
                      text: 'Kaydet',
                      onPressed: _isLoading ? null : _saveSchedule,
                      isLoading: _isLoading,
                      fullWidth: false,
                      icon: Icons.save_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
