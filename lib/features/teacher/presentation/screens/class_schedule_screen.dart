import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:teachmate_pro/core/theme/app_colors.dart';
import 'package:teachmate_pro/core/theme/app_text_styles.dart';
import 'package:teachmate_pro/core/widgets/app_button.dart';
import 'package:teachmate_pro/core/widgets/app_loading_indicator.dart';
import 'package:teachmate_pro/core/widgets/app_snackbar.dart';
import 'package:teachmate_pro/features/teacher/domain/models/class_schedule_model.dart';
import 'package:teachmate_pro/features/teacher/presentation/providers/class_schedule_provider.dart';
import 'package:teachmate_pro/features/teacher/presentation/widgets/schedule_form_dialog.dart';

class ClassScheduleScreen extends ConsumerStatefulWidget {
  const ClassScheduleScreen({super.key});

  @override
  ConsumerState<ClassScheduleScreen> createState() =>
      _ClassScheduleScreenState();
}

class _ClassScheduleScreenState extends ConsumerState<ClassScheduleScreen> {
  final CalendarController _calendarController = CalendarController();
  CalendarView _currentView = CalendarView.week;
  bool _isLoading = false;

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => const ScheduleFormDialog(),
    );
  }

  void _showEditScheduleDialog(ClassSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => ScheduleFormDialog(schedule: schedule),
    );
  }

  Future<void> _handleScheduleTap(CalendarTapDetails details) async {
    if (details.targetElement == CalendarElement.appointment) {
      final schedule = (details.appointments?.first as ClassSchedule);
      _showEditScheduleDialog(schedule);
    } else if (details.targetElement == CalendarElement.calendarCell) {
      final startTime = details.date!;
      final endTime = startTime.add(const Duration(hours: 1));

      showDialog(
        context: context,
        builder: (context) => ScheduleFormDialog(
          initialStartTime: startTime,
          initialEndTime: endTime,
        ),
      );
    }
  }

  Future<void> _handleScheduleDrop(AppointmentDragEndDetails details) async {
    if (details.appointment == null || details.droppingTime == null) return;

    setState(() => _isLoading = true);

    try {
      final schedule = details.appointment! as ClassSchedule;
      final newStartTime = details.droppingTime!;
      final duration = schedule.endTime.difference(schedule.startTime);
      final newEndTime = newStartTime.add(duration);

      await ref.read(classScheduleControllerProvider).moveSchedule(
            schedule.id,
            newStartTime,
            newEndTime,
          );

      if (mounted) {
        AppSnackBar.showSuccess(
          context: context,
          message: 'Ders programı güncellendi',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context: context,
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(classSchedulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Ders Programı',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppButton(
              text: 'Yeni',
              onPressed: _showAddScheduleDialog,
              icon: Icons.add_rounded,
              variant: AppButtonVariant.text,
              size: AppButtonSize.small,
              fullWidth: false,
            ),
          ),
          PopupMenuButton<CalendarView>(
            icon: const Icon(Icons.calendar_view_day_rounded),
            tooltip: 'Görünüm Değiştir',
            initialValue: _currentView,
            onSelected: (view) {
              setState(() {
                _currentView = view;
                _calendarController.view = view;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarView.day,
                child: Text('Günlük'),
              ),
              const PopupMenuItem(
                value: CalendarView.week,
                child: Text('Haftalık'),
              ),
              const PopupMenuItem(
                value: CalendarView.month,
                child: Text('Aylık'),
              ),
              const PopupMenuItem(
                value: CalendarView.schedule,
                child: Text('Liste'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          schedulesAsync.when(
            data: (schedules) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: AppColors.primary,
                      secondary: AppColors.secondary,
                    ),
              ),
              child: SfCalendar(
                key: ValueKey(schedules.length),
                controller: _calendarController,
                view: _currentView,
                firstDayOfWeek: 1,
                timeSlotViewSettings: const TimeSlotViewSettings(
                  startHour: 8,
                  endHour: 17,
                  timeFormat: 'HH:mm',
                  timeInterval: Duration(minutes: 30),
                  timeIntervalHeight: 60,
                  timeTextStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                headerStyle: CalendarHeaderStyle(
                  textStyle: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                viewHeaderStyle: ViewHeaderStyle(
                  dayTextStyle: AppTextStyles.labelMedium,
                  dateTextStyle: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                dataSource: _ScheduleDataSource(schedules),
                onTap: _handleScheduleTap,
                monthViewSettings: const MonthViewSettings(
                  showAgenda: true,
                  agendaViewHeight: 200,
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment,
                ),
                scheduleViewSettings: const ScheduleViewSettings(
                  hideEmptyScheduleWeek: true,
                  monthHeaderSettings: MonthHeaderSettings(
                    height: 70,
                    textAlign: TextAlign.center,
                  ),
                ),
                allowDragAndDrop: true,
                allowAppointmentResize: true,
                onDragEnd: _handleScheduleDrop,
              ),
            ),
            loading: () => const Center(child: AppLoadingIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Hata: $error',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: AppLoadingIndicator()),
            ),
        ],
      ),
    );
  }
}

class _ScheduleDataSource extends CalendarDataSource {
  _ScheduleDataSource(List<ClassSchedule> schedules) {
    appointments = schedules;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    final schedule = appointments![index] as ClassSchedule;
    return '${schedule.subject} - ${schedule.grade}\n${schedule.topic}';
  }

  @override
  Color getColor(int index) {
    final schedule = appointments![index] as ClassSchedule;
    return Color(int.parse('0xFF${schedule.color}'));
  }

  @override
  String? getNotes(int index) {
    return appointments![index].notes;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }

  @override
  Object? convertAppointmentToObject(
      Object? customData, Appointment appointment) {
    return customData;
  }

  Appointment convertToCalendarAppointment(Object customData) {
    final schedule = customData as ClassSchedule;
    return Appointment(
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      subject: '${schedule.subject} - ${schedule.grade}\n${schedule.topic}',
      color: Color(int.parse('0xFF${schedule.color}')),
      notes: schedule.notes,
      isAllDay: false,
    );
  }
}
