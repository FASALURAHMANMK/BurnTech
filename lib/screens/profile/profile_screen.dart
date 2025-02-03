import 'package:burn_tech/screens/camps/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatefulWidget {
  final String userId;
  final Future<void> Function() onLogout;

  const ProfileTab({Key? key, required this.userId, required this.onLogout})
      : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late Future<void> _fetchUserFuture;

  @override
  void initState() {
    super.initState();
    // Schedule fetchUser() only once.
    _fetchUserFuture = Provider.of<UserProvider>(context, listen: false)
        .fetchUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchUserFuture,
      builder: (context, snapshot) {
        // You can check for snapshot states (loading, error) here if needed.
        return Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final user = userProvider.user;
            if (user == null) {
              return const Center(child: Text("Failed to load user data"));
            }
            
            return Scaffold(
              appBar: AppBar(title: const Text("Profile")),
              body: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: user.profileImage != null
                          ? NetworkImage(user.profileImage!)
                          : null,
                      child: user.profileImage == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(user.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildListItem(Icons.receipt, "My Tickets"),
                        _buildListItem(Icons.favorite, "Favourite Camps"),
                        _buildListItem(Icons.brush, "Favourite Arts"),
                        _buildListItem(Icons.map, "Offline Maps"),
                        _buildListItem(Icons.logout, "Logout",
                            onTap: () => _showLogoutDialog(context)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
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
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}