import 'package:flutter/material.dart';
import 'package:indradhanush/add_event_page.dart';
import 'package:indradhanush/all_events_page.dart';
import 'package:indradhanush/auth_page.dart';
import 'package:indradhanush/event_details_page.dart';
import 'package:indradhanush/expenses_page.dart';
import 'package:indradhanush/home_page.dart';
import 'package:indradhanush/income_page.dart';
import 'package:indradhanush/finance_dashboard_page.dart';
import 'package:indradhanush/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';

// wil run the bg to connect to the supabase db
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

// initialize supabase
  await Supabase.initialize (
    url : SupabaseConfig.supabaseUrl,
    anonKey : SupabaseConfig.supabaseAnonKey
  );

  runApp(const IndradhanushApp());
}

class IndradhanushApp extends StatelessWidget {
  const IndradhanushApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return MaterialApp(
      title : 'Indradhanush',
      debugShowCheckedModeBanner: false,
      theme : AppTheme.theme,
      home: const _AuthGate(),
      // initialRoute: user != null? '/home' : '/auth',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/auth' :
          return MaterialPageRoute(builder: (_) => const AuthPage());

          case '/home':
            return MaterialPageRoute(
                builder: (_) => const HomePage());

          case '/add-event':
            return MaterialPageRoute(
                builder: (_) => const AddEventPage());

          case '/event-details':
            final eventId = settings.arguments as String;
            return MaterialPageRoute(
                builder: (_) => EventDetailsPage(eventId: eventId));

          case '/income':
            return MaterialPageRoute(
                builder: (_) => const IncomePage());

          case '/expenses':
            return MaterialPageRoute(
                builder: (_) => const ExpensesPage());

          case '/finances':
            return MaterialPageRoute(
                builder: (_) => const FinanceDashboardPage());

          default:
            return MaterialPageRoute(
                builder: (_) => const AuthPage());
        }
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        
  print('=== AUTH GATE ===');
  print('Connection state: ${snapshot.connectionState}');
  print('Has data: ${snapshot.hasData}');
  print('Session: ${snapshot.data?.session}');
  print('Event: ${snapshot.data?.event}');
        // Still loading session
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        if (session != null) {
          return const HomePage();
        } else {
          return const AuthPage();
        }
      },
    );
  }
}