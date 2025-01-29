import 'package:burn_tech/screens/auth/login_screen.dart';
import 'package:burn_tech/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Root widget that decides which screen to load based on SharedPreferences
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  String? _storedUid;

  @override
  void initState() {
    super.initState();
    _checkUidInPrefs();
  }

  Future<void> _checkUidInPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _storedUid = prefs.getString('uid');
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a loading indicator while checking SharedPreferences
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // If we have a stored UID, go to HomeScreen; otherwise, go to LoginScreen
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BurnTech Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: _storedUid == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}