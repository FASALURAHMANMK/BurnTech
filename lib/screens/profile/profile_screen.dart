import 'package:burn_tech/models/color.dart';
import 'package:burn_tech/screens/arts/fav_art_screen.dart';
import 'package:burn_tech/screens/camps/fav_camps_screen.dart';
import 'package:burn_tech/screens/camps/user_provider.dart';
import 'package:burn_tech/screens/chat/chat_screen.dart';
import 'package:burn_tech/screens/map/offline_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatelessWidget {
  final String userId;
  final Future<void> Function() onLogout;

  const ProfileTab({Key? key, required this.userId, required this.onLogout})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Schedule the fetch after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUser(userId);
    });

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return Scaffold(
            body: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromRGBO(250, 139, 0, 1),
                    const Color.fromRGBO(248, 51, 60, 1)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
          );
        }

        final user = userProvider.user;
        if (user == null) {
          return const Center(child: Text("Failed to load user data"));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              user.name,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28),
            ),
            backgroundColor: desertOrange,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatScreen()),
                  );
                },
                icon: Image.asset(
                  'assets/chat.png',
                  width: 24, // Set appropriate width
                  height: 24, // Set appropriate height
                ),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(250, 139, 0, 1),
                  const Color.fromRGBO(248, 51, 60, 1)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: user.profileImage != null
                        ? NetworkImage(user.profileImage!)
                        : null,
                    child: user.profileImage == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildListItem(
                        Icons.cabin,
                        "Favourite Camps",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  favCampScreen(currentUserId: user.uid),
                            ),
                          );
                        },
                      ),
                      _buildListItem(Icons.design_services, "Favourite Arts",onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  favArtScreen(currentUserId: user.uid),
                            ),
                          );
                        },),
                      _buildListItem(Icons.map, "Offline Maps",onTap: () {
                         Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MBTilesMapScreen()),
                  );
                      },),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Button background color
                    foregroundColor: Colors.red, // Text color
                    padding: EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15), // Button padding
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold), // Text style
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18), // Rounded corners
                    ),
                  ),
                  child: Text("Logout"), // Button text
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: desertOrange)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
