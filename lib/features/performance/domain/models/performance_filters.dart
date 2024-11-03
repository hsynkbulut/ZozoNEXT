class PerformanceFilters {
  final String? studentId;
  final String subject;
  final String? topic;
  final String timeRange;

  const PerformanceFilters({
    this.studentId,
    required this.subject,
    this.topic,
    required this.timeRange,
  });

  PerformanceFilters copyWith({
    String? studentId,
    String? subject,
    String? topic,
    String? timeRange,
  }) {
    return PerformanceFilters(
      studentId: studentId ?? this.studentId,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      timeRange: timeRange ?? this.timeRange,
    );
  }

  static const subjects = [
    'Tüm Dersler',
    'Matematik',
    'Fizik',
    'Kimya',
    'Biyoloji',
    'Tarih',
    'Coğrafya',
  ];

  static const timeRanges = [
    'Son 7 Gün',
    'Son 30 Gün',
    'Son 3 Ay',
  ];
}
