  import 'package:burn_tech/screens/auth/auth_provider.dart';
  import 'package:burn_tech/screens/auth/login_screen.dart';
  import 'package:burn_tech/screens/camps/camps_screen.dart';
  import 'package:burn_tech/screens/arts/arts_screen.dart';
  import 'package:burn_tech/screens/home/home_screen_provider.dart';
  import 'package:burn_tech/screens/home/home_tab.dart';
  import 'package:burn_tech/screens/map/map_screen.dart';
  import 'package:burn_tech/screens/profile/profile_screen.dart';
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:burn_tech/models/color.dart';

  class HomeScreen extends StatelessWidget {
    const HomeScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return ChangeNotifierProvider(
        create: (_) => HomeProvider(),
        child: Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            return Scaffold(
              body: _buildBody(context, homeProvider),
              bottomNavigationBar: _buildBottomNavBar(context, homeProvider),
            );
          },
        ),
      );
    }

    Widget _buildBody(BuildContext context, HomeProvider homeProvider) {
      final authProvider = Provider.of<AuthProvider>(context);
      final List<Widget> pages = [
        const HomeTab(),
        MapTab(
          camps: homeProvider.camps,
          arts: homeProvider.arts,
        ),
        CampScreen(currentUserId: authProvider.uid ?? ''),
        ArtScreen(currentUserId: authProvider.uid ?? ''),
        ProfileTab(
          onLogout: () async => await _handleLogout(context),
          userId: authProvider.uid ?? '',
        ),
      ];

      return pages[homeProvider.currentIndex];
    }

    Widget _buildBottomNavBar(BuildContext context, HomeProvider homeProvider) {
      return BottomNavigationBar(
        currentIndex: homeProvider.currentIndex,
        onTap: homeProvider.onTabTapped,
        selectedItemColor: desertOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cabin),
            label: 'Camps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'Arts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      );
    }

    Future<void> _handleLogout(BuildContext context) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logoutUser(context);

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
