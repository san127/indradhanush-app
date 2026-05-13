import 'package:flutter/material.dart';
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
    return const Placeholder();
  }
}