import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  final Future<void> Function() onLogout;
  const ProfileTab({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    // Placeholder Profile Tab
    return Container(
      color: Colors.white,
      child: Center(
        child: ElevatedButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
          ),
        ),
      ),
    );
  }
}