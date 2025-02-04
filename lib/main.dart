import 'package:burn_tech/screens/arts/art_details_screen_provider.dart';
import 'package:burn_tech/screens/arts/arts_screen_provider.dart';
import 'package:burn_tech/screens/arts/fav_art_screen_provider.dart';
import 'package:burn_tech/screens/auth/auth_provider.dart';
import 'package:burn_tech/screens/camps/camp_details_screen_provider.dart';
import 'package:burn_tech/screens/camps/camp_screen_provider.dart';
import 'package:burn_tech/screens/camps/fav_camp_screen_provider.dart';
import 'package:burn_tech/screens/camps/user_provider.dart';
import 'package:burn_tech/screens/chat/chat_screen_provider.dart';
import 'package:burn_tech/screens/map/mbtiles_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:burn_tech/screens/auth/login_screen.dart';
import 'package:burn_tech/screens/home/home_screen.dart';
import 'package:burn_tech/models/color.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkUidInPrefs()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<CampProvider>(create: (_) => CampProvider()),
        ChangeNotifierProvider<ArtProvider>(create: (_) => ArtProvider()),
        ChangeNotifierProvider<CampDetailProvider>(create: (_) => CampDetailProvider()),
        ChangeNotifierProvider<ArtDetailProvider>(create: (_) => ArtDetailProvider()),
        ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
        ChangeNotifierProvider<favCampProvider>(create: (_) => favCampProvider()),
        ChangeNotifierProvider<favArtProvider>(create: (_) => favArtProvider()),
        ChangeNotifierProvider<MBTilesProvider>(create: (_) => MBTilesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BurnTech',
      theme: ThemeData(
        primarySwatch: desertOrange, // Updated to valid swatch
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return authProvider.isLoggedIn ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}