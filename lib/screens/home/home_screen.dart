import 'package:burn_tech/models/camp_location.dart';
import 'package:burn_tech/screens/auth/login_screen.dart';
import 'package:burn_tech/screens/home/camps_screen.dart';
import 'package:burn_tech/screens/home/chat_screen.dart';
import 'package:burn_tech/screens/home/map_screen.dart';
import 'package:burn_tech/screens/home/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:burn_tech/models/color.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
final camps = [
  CampLocation(name: 'Camp A', latitude: 40.787, longitude: -119.203),
  CampLocation(name: 'Camp B', latitude: 40.786, longitude: -119.208),
  // Add more camps...
];
  // We define 5 tabs to match the bottom navbar
  late final List<Widget> _pages = [
    const HomeTab(),
    MapTab(campLocations: camps),
    const CampsTab(),
    const ChatTab(),
    ProfileTab(onLogout: _handleLogout),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Clears the uid from SharedPreferences and navigates to LoginScreen
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Match gradient style in AppBar or a custom container
      appBar: AppBar(
        title: const Text('BurnTech',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: desertOrange,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
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
            icon: Icon(Icons.group),
            label: 'Camps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Similar gradient style as the login screen
    return Container(
      height: 600,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromRGBO(250, 139, 0, 1), Color.fromRGBO(248, 51, 60, 1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Example Section for "My Camps"
            Card(
              color: Colors.white.withOpacity(0.9),
              child: ListTile(
                leading: const Icon(Icons.cabin, color: desertOrange),
                title: const Text(
                  'My Camps',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                    'View camps you have tokens for or where you are a member.'),
                onTap: () {
                  // Navigate or show details
                },
              ),
            ),
            const SizedBox(height: 16),

            // Upcoming Events
            Card(
              color: Colors.white.withOpacity(0.9),
              child: ListTile(
                leading: const Icon(Icons.event, color: desertOrange),
                title: const Text(
                  'Upcoming Events',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Check out upcoming camp events.'),
                onTap: () {
                  // Show a list of upcoming events
                },
              ),
            ),
            const SizedBox(height: 16),

            // Nearby Camps
            Card(
              color: Colors.white.withOpacity(0.9),
              child: ListTile(
                leading: const Icon(Icons.location_on, color: desertOrange),
                title: const Text(
                  'Nearby Camps',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('See camps near your current location.'),
                onTap: () {
                  // Show map or relevant info
                },
              ),
            ),
            const SizedBox(height: 16),

            // Another placeholder
            Card(
              color: Colors.white.withOpacity(0.9),
              child: ListTile(
                leading: const Icon(Icons.campaign, color: desertOrange),
                title: const Text(
                  'Announcements',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Latest news and official announcements.'),
                onTap: () {
                  // Show announcements
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
