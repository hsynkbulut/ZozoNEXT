class StudentPerformanceFilters {
  final String subject;
  final String? topic;
  final String timeRange;

  const StudentPerformanceFilters({
    required this.subject,
    this.topic,
    required this.timeRange,
  });

  StudentPerformanceFilters copyWith({
    String? subject,
    String? topic,
    String? timeRange,
  }) {
    return StudentPerformanceFilters(
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
