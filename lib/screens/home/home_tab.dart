import 'package:flutter/material.dart';
import 'package:burn_tech/models/color.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
              title: const Text(
                'BurnTech',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 28),
              ),
              backgroundColor: desertOrange,
            ),
    body:Container(
      height: 800,
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
            _buildCard(
              icon: Icons.cabin,
              title: 'My Camps',
              subtitle: 'View camps you have tokens for or where you are a member.',
              onTap: () {},
            ),
            _buildCard(
              icon: Icons.event,
              title: 'Upcoming Events',
              subtitle: 'Check out upcoming camp events.',
              onTap: () {},
            ),
            _buildCard(
              icon: Icons.location_on,
              title: 'Nearby Camps',
              subtitle: 'See camps near your current location.',
              onTap: () {},
            ),
            _buildCard(
              icon: Icons.campaign,
              title: 'Announcements',
              subtitle: 'Latest news and official announcements.',
              onTap: () {},
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      child: ListTile(
        leading: Icon(icon, color: desertOrange),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}