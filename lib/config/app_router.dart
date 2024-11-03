import 'package:go_router/go_router.dart';
import 'package:teachmate_pro/features/auth/presentation/screens/login_screen.dart';
import 'package:teachmate_pro/features/auth/presentation/screens/signup_screen.dart';
import 'package:teachmate_pro/features/dashboard/presentation/screens/student_dashboard_screen.dart';
import 'package:teachmate_pro/features/dashboard/presentation/screens/teacher_dashboard_screen.dart';
import 'package:teachmate_pro/features/exam_creation/presentation/screens/exam_editor_screen.dart';
import 'package:teachmate_pro/features/exam_creation/presentation/screens/my_exams_screen.dart';
import 'package:teachmate_pro/features/exam_creation/presentation/widgets/exam_pdf_preview.dart';
import 'package:teachmate_pro/features/lesson_planning/presentation/screens/lesson_plan_screen.dart';
import 'package:teachmate_pro/features/exam_creation/presentation/screens/exam_creation_screen.dart';
import 'package:teachmate_pro/features/chat/presentation/screens/chat_screen.dart';
import 'package:teachmate_pro/features/lesson_planning/presentation/screens/my_plans_screen.dart';
import 'package:teachmate_pro/features/performance/presentation/screens/performance_analysis_screen.dart';
import 'package:teachmate_pro/features/quiz/domain/models/quiz_model.dart';
import 'package:teachmate_pro/features/quiz/domain/models/quiz_result_model.dart';
import 'package:teachmate_pro/features/quiz/presentation/screens/my_quizzes_screen.dart';
import 'package:teachmate_pro/features/quiz/presentation/screens/quiz_creation_screen.dart';
import 'package:teachmate_pro/features/quiz/presentation/screens/quiz_editor_screen.dart';
import 'package:teachmate_pro/features/quiz/presentation/screens/quiz_list_screen.dart';
import 'package:teachmate_pro/features/quiz/presentation/screens/quiz_preview_screen.dart';
import 'package:teachmate_pro/features/quiz/presentation/screens/quiz_result_screen.dart';
import 'package:teachmate_pro/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:teachmate_pro/features/student/presentation/screens/student_account_screen.dart';
import 'package:teachmate_pro/features/student_performance/presentation/screens/student_performance_screen.dart';
import 'package:teachmate_pro/features/teacher/presentation/screens/class_schedule_screen.dart';
import 'package:teachmate_pro/features/teacher/presentation/screens/teacher_account_screen.dart';
import 'package:teachmate_pro/features/written_exam/presentation/screens/add_written_exam_screen.dart';
import 'package:teachmate_pro/features/written_exam/presentation/screens/my_written_exams_screen.dart';
import 'package:uuid/uuid.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/teacher-dashboard',
      builder: (context, state) => const TeacherDashboardScreen(),
    ),
    GoRoute(
      path: '/lesson-plan',
      builder: (context, state) => const LessonPlanScreen(),
    ),
    GoRoute(
      path: '/my-plans',
      builder: (context, state) => const MyPlansScreen(),
    ),
    GoRoute(
      path: '/quiz-creation',
      builder: (context, state) => const QuizCreationScreen(),
    ),
    GoRoute(
      path: '/quiz-preview',
      builder: (context, state) {
        final extra = state.extra;

        if (extra is QuizModel) {
          return QuizPreviewScreen(quiz: extra);
        }

        if (extra is Map<String, dynamic>) {
          final examInfo = extra['examInfo'] as Map<String, dynamic>;
          final generatedQuiz = extra['generatedQuiz'] as QuizModel;

          // Create a new QuizModel with the generated quiz data
          final quiz = generatedQuiz.copyWith(
            id: const Uuid().v4(),
            subject: examInfo['subject'] as String,
            grade: examInfo['grade'] as String,
            topic: examInfo['topic'] as String,
            difficulty: examInfo['difficulty'] as String,
            duration: examInfo['duration'] as int,
            isPublished: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          return QuizPreviewScreen(quiz: quiz);
        }

        throw Exception('Invalid route parameters for QuizPreviewScreen');
      },
    ),
    GoRoute(
      path: '/quizzes',
      builder: (context, state) => const QuizListScreen(),
    ),
    GoRoute(
      path: '/quiz-screen',
      builder: (context, state) {
        final quiz = state.extra as QuizModel?;
        if (quiz == null) {
          throw Exception('Quiz data is required for QuizScreen');
        }
        return QuizScreen(quiz: quiz);
      },
    ),
    GoRoute(
      path: '/quiz-result',
      builder: (context, state) {
        final result = state.extra as QuizResultModel?;
        if (result == null) {
          throw Exception('Quiz result data is required for QuizResultScreen');
        }
        return QuizResultScreen(result: result);
      },
    ),
    GoRoute(
      path: '/quiz-editor',
      builder: (context, state) {
        final quiz = state.extra as QuizModel?;
        if (quiz == null) {
          throw Exception('Quiz data is required for QuizEditorScreen');
        }
        return QuizEditorScreen(quiz: quiz);
      },
    ),
    GoRoute(
      path: '/my-quizzes',
      builder: (context, state) => const MyQuizzesScreen(),
    ),
    GoRoute(
      path: '/exam-creation',
      builder: (context, state) => const ExamCreationScreen(),
    ),
    GoRoute(
      path: '/exam-editor',
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return ExamEditorScreen(
          initialQuestions: extra['questions'],
          examInfo: extra['examInfo'],
        );
      },
    ),
    GoRoute(
      path: '/exam-preview',
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return ExamPdfPreview(
          questions: extra['questions'],
          examInfo: extra['examInfo'],
        );
      },
    ),
    GoRoute(
      path: '/my-exams',
      builder: (context, state) => const MyExamsScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: '/performance',
      builder: (context, state) => const PerformanceAnalysisScreen(),
    ),
    GoRoute(
      path: '/student-dashboard',
      builder: (context, state) => const StudentDashboardScreen(),
    ),
    GoRoute(
      path: '/student-performance',
      builder: (context, state) => const StudentPerformanceScreen(),
    ),
    GoRoute(
      path: '/add-written-exam',
      builder: (context, state) => const AddWrittenExamScreen(),
    ),
    GoRoute(
      path: '/my-written-exams',
      builder: (context, state) => const MyWrittenExamsScreen(),
    ),
    GoRoute(
      path: '/student-account',
      builder: (context, state) => const StudentAccountScreen(),
    ),
    GoRoute(
      path: '/teacher-account',
      builder: (context, state) => const TeacherAccountScreen(),
    ),
    GoRoute(
      path: '/class-schedule',
      builder: (context, state) => const ClassScheduleScreen(),
    ),
  ],
);
