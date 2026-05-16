import 'package:flutter/material.dart';
import 'package:indradhanush/services/auth_service.dart';
import '../services/supabase_service.dart';
import '../theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> 
    with SingleTickerProviderStateMixin {

  late TabController _tabController; // allows for stack of pages
  // form helps to validate save and reset items within in 
  // global key allows for using it anywhere to access
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

// obscure is a toggle for password show or hide  ******
  bool _obscureLogin = true;
  bool _obscureSignup = true;
  bool _loading = false;

// fluuter widget's lifecycle
  @override
  void initState(){ // runs only once when widget is first created
    super.initState(); // used for controllers, statrting animations, api calls, loading data, setting listeners
    _tabController = TabController(length: 2, vsync: this);
    // tells which tab is active, swiping between tabs etc
  }

  @override
  void dispose(){
    _tabController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async{
    if(!_loginFormKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try{
      await AuthService.signIn(_loginEmailCtrl.text.trim(), _loginPasswordCtrl.text);
      if (mounted) Navigator.pushReplacement(context, '/home');
    } catch(e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed : ${e.toString()}'),
            backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if(mounted) setState(() => _loading = false);
    }
  }






  @override
  Widget build(BuildContext context) {
    return ;
  }

}