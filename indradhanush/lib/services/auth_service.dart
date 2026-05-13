import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // onj to talk to supabase backend
  // sup.inst.client gets initialized in main using spi key and anon
// static allows to use client without creating obj
// _cleint underscore means private var inside this file/clas
  static final SupabaseClient _client = Supabase.instance.client;

  //sign in method

  //runs asyncly 
  // authresponse stores user, session and auth info

  static Future<AuthResponse> signUp ( String email, String password, String name) 
  async{
      return await _client.auth.signUp( // calls supabase authentication api
        email : email, 
        password : password,
        data : {'name': name}, // stores metadata about user liek name inside auth.users
      );// at the end it creates a session and returns auth response
  }

  static Future<AuthResponse> signIn (String email, String password) 
  async{
    return await _client.auth.signInWithPassword(
      email : email,
      password : password
      );
  }

  static Future<void> signOut() async{
    return _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;
}