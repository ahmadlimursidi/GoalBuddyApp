import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'config/theme.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/dashboard_view_model.dart';
import 'view_models/active_session_view_model.dart';
import 'view_models/admin_view_model.dart';
import 'view_models/student_parent_view_model.dart';
import 'view_models/attendance_view_model.dart';
import 'view_models/drill_library_view_model.dart';
import 'views/auth/login_view.dart';
import 'views/dashboard/coach_dashboard_view.dart';
import 'views/dashboard/admin_dashboard_view.dart';
import 'views/dashboard/student_parent_dashboard_view.dart';
import 'views/analytics/admin_analytics_view.dart';
import 'views/session/active_session_view.dart';
import 'views/session/attendance_view.dart';
import 'views/session/student_list_view.dart';
import 'views/session/student_profile_view.dart';
import 'views/resources/coach_resources_view.dart';
import 'views/resources/drill_library_view.dart';
import 'views/admin/create_session_template_view.dart';
import 'views/admin/schedule_class_view.dart';
import 'views/admin/admin_students_view.dart';
import 'views/admin/admin_coaches_view.dart';
import 'views/admin/class_details_view.dart';
import 'views/splash/splash_view.dart';
import 'views/finance/finance_view.dart';
import 'views/parent/parent_schedule_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError caught by FlutterError.onError: ${details.exceptionAsString()}');
  };

  runZonedGuarded(() {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => DashboardViewModel()),
          ChangeNotifierProvider(create: (_) => ActiveSessionViewModel()),
          ChangeNotifierProvider(create: (_) => AdminViewModel()),
          ChangeNotifierProvider(create: (_) => StudentParentViewModel()), // Add student/parent view model
          ChangeNotifierProvider(create: (_) => AttendanceViewModel()), // Add attendance view model
          ChangeNotifierProvider(create: (_) => DrillLibraryViewModel()), // Add drill library view model
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrintStack(stackTrace: stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GOALBUDDY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashView(),
        '/login': (context) => const LoginView(),
        '/dashboard': (context) => const CoachDashboardView(),
        '/admin_dashboard': (context) => const AdminDashboardView(),
        '/admin_analytics': (context) => const AdminAnalyticsView(), // Add admin analytics route
        '/student_parent_dashboard': (context) => const StudentParentDashboardView(), // Add student/parent dashboard route
        '/parent_schedule': (context) => const ParentScheduleView(), // Add parent schedule route
        '/active_session': (context) => const ActiveSessionView(),
        '/attendance': (context) => const AttendanceView(),
        '/student_profile': (context) => const StudentProfileView(),
        '/student_list': (context) => const StudentListView(), // Add student list route
        '/coach_resources': (context) => const CoachResourcesView(), // Add coach resources route
        '/create_session_template': (context) => const CreateSessionTemplateView(),
        '/schedule_class': (context) => const ScheduleClassView(),
        '/drill_library': (context) => const DrillLibraryView(),
        '/finance': (context) => const FinanceView(),
        '/admin_students': (context) => const AdminStudentsView(),
        '/admin_coaches': (context) => const AdminCoachesView(),
      },
      onGenerateRoute: (settings) {
        // Handle /class_details route with dynamic data fetching
        if (settings.name == '/class_details') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null && args.containsKey('sessionId')) {
            return MaterialPageRoute(
              builder: (context) => ClassDetailsWrapper(
                sessionId: args['sessionId'] as String,
              ),
            );
          }
        }
        return null;
      },
    );
  }
}

// Wrapper widget that fetches session data and displays ClassDetailsView
class ClassDetailsWrapper extends StatelessWidget {
  final String sessionId;

  const ClassDetailsWrapper({
    Key? key,
    required this.sessionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('sessions').doc(sessionId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Class Details'),
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Class Details'),
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('Error loading class details'),
            ),
          );
        }

        final classData = snapshot.data!.data() as Map<String, dynamic>;

        return ClassDetailsView(
          classId: sessionId,
          classData: classData,
        );
      },
    );
  }
}