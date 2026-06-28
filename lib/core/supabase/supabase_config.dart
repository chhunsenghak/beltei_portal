import 'package:flutter_dotenv/flutter_dotenv.dart';

String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
String get supabaseServiceRoleKey => dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
