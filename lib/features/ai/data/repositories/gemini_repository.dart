import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:teachmate_pro/config/api_key.dart';
import 'package:teachmate_pro/features/ai/domain/repositories/ai_repository.dart';
import 'package:teachmate_pro/features/student_performance/domain/models/student_performance_data.dart';

class GeminiRepository implements AIRepository {
  late final GenerativeModel _model;
  final List<Content> _chatHistory = [];

  GeminiRepository() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: ApiKey.geminiApiKey, // API anahtarı artık env'den geliyor
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
      ),
      safetySettings: [
        SafetySetting(
          HarmCategory.harassment,
          HarmBlockThreshold.medium,
        ),
        SafetySetting(
          HarmCategory.hateSpeech,
          HarmBlockThreshold.medium,
        ),
        SafetySetting(
          HarmCategory.sexuallyExplicit,
          HarmBlockThreshold.medium,
        ),
        SafetySetting(
          HarmCategory.dangerousContent,
          HarmBlockThreshold.medium,
        ),
      ],
    );
  }

  @override
  Future<String> generateLessonPlan({
    required String subject,
    required String grade,
    required String topic,
  }) async {
    final prompt = '''
    Lütfen aşağıdaki kriterlere göre detaylı bir ders planı oluşturun:
    Ders: $subject
    Sınıf: $grade
    Konu: $topic
    
    Plan şunları içermelidir:
    1. Kazanımlar
    2. Ön bilgi gereksinimleri
    3. Kullanılacak materyaller
    4. Dersin aşamaları (Giriş, Gelişme, Sonuç)
    5. Değerlendirme yöntemleri
    6. Ödev önerileri
    ''';

    final content = Content.text(prompt);
    final response = await _model.generateContent([content]);
    return response.text ?? 'Ders planı oluşturulamadı.';
  }

  @override
  Future<String> generateExamQuestions({
    required String grade,
    required String subject,
    required List<String> topics,
    required String difficulty,
    required int questionCount,
  }) async {
    final prompt = '''
    Lütfen aşağıdaki kriterlere göre $questionCount adet çoktan seçmeli soru oluşturun.

    SINAV BİLGİLERİ:
    - Sınıf: $grade. Sınıf
    - Ders: $subject
    - Konular: ${topics.join(', ')}
    - Zorluk: $difficulty

    ÖNEMLİ KURALLAR:
    1. Her soru için <SORU> ve </SORU> etiketlerini MUTLAKA kullanın
    2. Her soruyu sıra numarası ile başlatın (1., 2., vb.)
    3. Her şıkkı belirtilen formatta yazın (A), B), C), D))
    4. Doğru cevabı "DOĞRU CEVAP: X" formatında belirtin (X yerine A, B, C veya D)
    5. Tüm içerik Türkçe olmalı
    6. Her soru $grade. sınıf seviyesine uygun olmalı
    7. Her soru $difficulty zorluk seviyesinde olmalı
    8. Her şık anlamlı ve konu ile ilgili olmalı
    9. Şıklar kısa ve öz olmalı
    10. Sorular ve şıklar bilimsel olarak doğru olmalı
    11. ÇOK ÖNEMLİ: Her soru için doğru cevabı rastgele bir şıkka yerleştirin (A, B, C veya D)
    12. Doğru cevaplar her zaman aynı şıkta olmamalı, rastgele dağıtılmalı

    SORU FORMATI:
    <SORU>
    [Soru Numarası]. [Soru Metni]

    A) [Seçenek A]
    B) [Seçenek B]
    C) [Seçenek C]
    D) [Seçenek D]

    DOĞRU CEVAP: [A/B/C/D]
    </SORU>

    ÖRNEK SORU:
    <SORU>
    1. Bir üçgenin iç açıları toplamı kaç derecedir?

    A) 360
    B) 90
    C) 270
    D) 180

    DOĞRU CEVAP: D
    </SORU>

    KONU ÖZEL KURALLARI:
    ${_getSubjectSpecificRules(subject)}

    Lütfen yukarıdaki formata KESINLIKLE uyarak $questionCount adet soru oluşturun.
    Her soru için doğru cevabı rastgele bir şıkka yerleştirmeyi UNUTMAYIN!
    ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final result = response.text;

      if (result == null || result.isEmpty) {
        throw Exception('Soru üretimi başarısız oldu');
      }

      // Validate the response format
      if (!result.contains('<SORU>') || !result.contains('</SORU>')) {
        throw Exception('Üretilen sorular geçerli formatta değil');
      }

      return result;
    } catch (e) {
      throw Exception('Soru oluşturulurken bir hata oluştu: $e');
    }
  }

  String _getSubjectSpecificRules(String subject) {
    switch (subject) {
      case 'Matematik':
        return '''
        - Matematiksel ifadeleri açık ve net yazın
        - Gerekli formülleri sorunun içinde verin
        - Sayısal değerleri anlaşılır şekilde belirtin
        - Geometrik şekilleri sözel olarak açıklayın
        - İşlem gerektiren sorularda ara adımları belirtmeyin
        ''';
      case 'Fizik':
        return '''
        - Fiziksel büyüklükleri birimleriyle birlikte yazın
        - Formülleri sorunun içinde verin
        - Vektörel büyüklükleri yön bilgisiyle belirtin
        - Laboratuvar deneyleriyle ilgili sorularda güvenlik kurallarını gözetin
        - Günlük hayattan örnekler kullanın
        ''';
      case 'Kimya':
        return '''
        - Kimyasal formülleri doğru yazın
        - Tepkime denklemlerini dengeli yazın
        - Element ve bileşik isimlerini doğru kullanın
        - Laboratuvar güvenliği ile ilgili bilgileri doğru verin
        - Mol hesaplamalarında birimleri belirtin
        ''';
      case 'Biyoloji':
        return '''
        - Biyolojik terimleri doğru kullanın
        - Canlı sistemlerini doğru tanımlayın
        - Güncel bilimsel bilgileri kullanın
        - Çevre ve sağlık konularında etik kuralları gözetin
        - Laboratuvar uygulamalarında güvenlik kurallarını belirtin
        ''';
      default:
        return '''
        - Konuya özgü terimleri doğru kullanın
        - Öğrenci seviyesine uygun ifadeler kullanın
        - Güncel ve doğru bilgiler verin
        - Açık ve anlaşılır bir dil kullanın
        ''';
    }
  }

  @override
  Future<String> getTeachingTips({
    required String subject,
    required String topic,
    required String studentLevel,
  }) async {
    final prompt = '''
    Lütfen aşağıdaki konu için öğretim önerileri sunun:
    Ders: $subject
    Konu: $topic
    Öğrenci Seviyesi: $studentLevel
    
    Öneriler şunları içermelidir:
    1. Etkili öğretim stratejileri
    2. Olası zorluklar ve çözüm önerileri
    3. Öğrenci katılımını artıracak aktiviteler
    4. Değerlendirme yöntemleri
    ''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? 'Öneriler oluşturulamadı.';
  }

  bool _isFirstMessage = true; // İlk mesaj kontrolü için bir değişken

  @override
  Future<String> sendMessage({
    required String message,
  }) async {
    try {
      final chat = _model.startChat(history: _chatHistory);

      // İlk mesajda karşılama mesajını göster
      final greetingMessage = _isFirstMessage
          ? "Merhaba! Ben Zozo, senin eğitim yolculuğunda sana yardımcı olmak için buradayım! Hangi konuda destek almak istersin?"
          : ""; // Sonraki mesajlarda boş bırak

      final result = await chat.sendMessage(Content.text('''
        Sen, 'Zozo' adında bir yapay zeka asistanısın. Lise öğretmenleri ve lise öğrencilerine yardımcı olmak için tasarlandın.
        Sadece eğitim, öğretim, pedagoji ve öğrenci gelişimi ile ilgili konularda yardımcı olabilirsin.
        Bu konuların dışındaki sorulara yanıt vermemelisin.

        Kullanıcı Mesajı: $message
        $greetingMessage
      '''));

      final response = result.text;
      if (response == null || response.isEmpty) {
        throw Exception('Yanıt alınamadı');
      }

      _chatHistory.add(Content.text(message));
      _chatHistory.add(Content.text(response));

      // İlk mesaj atıldıktan sonra kontrolü güncelle
      if (_isFirstMessage) {
        _isFirstMessage = false;
      }

      return response;
    } catch (e) {
      throw Exception('Mesaj gönderilemedi: $e');
    }
  }

  @override
  Future<String> generateStudyRecommendations({
    required List<StudentPerformanceData> performanceData,
    required String studentName,
    required String grade,
  }) async {
    try {
      // Group and average performance data by subject and topic
      final subjectPerformance = <String, Map<String, _TopicStats>>{};

      for (final data in performanceData) {
        subjectPerformance.putIfAbsent(data.subject, () => {});
        subjectPerformance[data.subject]!.putIfAbsent(
          data.topic,
          () => _TopicStats(),
        );

        subjectPerformance[data.subject]![data.topic]!
            .addScore(data.totalScore);
      }

      // Create a structured performance summary for topics below 75%
      final performanceSummary = StringBuffer();
      performanceSummary.writeln('STUDENT PERFORMANCE DATA:');
      performanceSummary.writeln('Student Name: $studentName');
      performanceSummary.writeln('Grade: $grade');
      performanceSummary.writeln('\nTopics Needing Improvement (Below 75%):');

      final lowPerformanceTopics = <String>[];

      subjectPerformance.forEach((subject, topics) {
        topics.forEach((topic, stats) {
          if (stats.averageScore < 75) {
            lowPerformanceTopics.add(
                '$subject|$topic|${stats.averageScore.toStringAsFixed(1)}%|${stats.attempts}');
          }
        });
      });

      if (lowPerformanceTopics.isEmpty) {
        return '<RECOMMENDATIONS></RECOMMENDATIONS>';
      }

      lowPerformanceTopics.sort((a, b) {
        final scoreA = double.parse(a.split('|')[2].replaceAll('%', ''));
        final scoreB = double.parse(b.split('|')[2].replaceAll('%', ''));
        return scoreA.compareTo(scoreB);
      });

      for (final topic in lowPerformanceTopics) {
        final parts = topic.split('|');
        performanceSummary.writeln('\n${parts[0]} - ${parts[1]}:'
            '\n  Ortalama Başarı: ${parts[2]}'
            '\n  Toplam Deneme: ${parts[3]}');
      }

      final prompt = '''
        Sen bir eğitim uzmanısın. Aşağıdaki öğrenci performans verilerini analiz ederek, öğrenciye özel çalışma önerileri sunman gerekiyor.

        ${performanceSummary.toString()}

        Öneriler için kurallar:
        1. Her öneri bir konu için olmalı
        2. Öneriler kısa ve net olmalı (max 2 cümle)
        3. Öğrencinin performansına göre spesifik öneriler sunulmalı
        4. En düşük performanslı konulardan başlayarak öneriler sun
        5. Yanıtı aşağıdaki formatta ver:

        <RECOMMENDATIONS>
        [Ders]|[Konu]|[Öneri]|[Başarı Yüzdesi]
        </RECOMMENDATIONS>

        Not: Her konu için sadece bir öneri ver ve başarı yüzdesini verilen değeri kullan.
      ''';

      final result = await _model.generateContent([Content.text(prompt)]);
      final response = result.text;

      if (response == null || response.isEmpty) {
        throw Exception('Öneriler oluşturulamadı');
      }

      return response;
    } catch (e) {
      throw Exception('Öneriler oluşturulurken bir hata oluştu: $e');
    }
  }
}

class _TopicStats {
  double _totalScore = 0;
  int _attempts = 0;

  void addScore(double score) {
    _totalScore += score;
    _attempts++;
  }

  double get averageScore => _totalScore / _attempts;
  int get attempts => _attempts;
}
