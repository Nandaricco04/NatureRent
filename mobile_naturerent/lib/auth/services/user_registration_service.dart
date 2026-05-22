import 'package:bcrypt/bcrypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRegistrationService {
  UserRegistrationService({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<bool> isEmailRegistered(String email) async {
    final existing = await _supabase
        .from('users')
        .select('email')
        .eq('email', email)
        .maybeSingle();

    return existing != null;
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final hash = BCrypt.hashpw(password, BCrypt.gensalt());

    await _supabase.from('users').insert({
      'nama': name,
      'email': email,
      'password': hash,
      'role': 'user',
    });
  }
}
