import 'package:burn_tech/models/camp_model.dart';
import 'package:burn_tech/screens/camps/camp_screen_provider.dart';
import 'package:burn_tech/screens/camps/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CampScreen extends StatefulWidget {
  final String currentUserId;

  const CampScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<CampScreen> createState() => _CampScreenState();
}

class _CampScreenState extends State<CampScreen> {
  @override
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (widget.currentUserId.isEmpty) {
      debugPrint("Error: currentUserId is empty!");
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchUser(widget.currentUserId);

    final campProvider = Provider.of<CampProvider>(context, listen: false);
    campProvider.fetchCamps();
  });
}

  /// Helper: Return color for the ticket icon
  Color _getTicketColor(CampModel camp, UserProvider userProvider) {
    final user = userProvider.user;
    if (user == null) return Colors.grey;

    final membersCount = camp.members?.length ?? 0;
    if (membersCount == camp.maxMembers) {
      return Colors.red; // All tickets used
    } else if (camp.members?.contains(user.uid) == true) {
      return Colors.green; // User is already in camp
    } else {
      return Colors.yellow; // Some tickets remain
    }
  }

  /// Distance placeholders
  String _getWalkingDistance(GeoPoint location) => "5 min";
  String _getCyclingDistance(GeoPoint location) => "2 min";
  String _getDrivingDistance(GeoPoint location) => "1 min";

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final campProvider = Provider.of<CampProvider>(context);

    final isLoading = userProvider.isLoading || campProvider.isLoading;
    final hasError = userProvider.error != null || campProvider.error != null;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError) {
      return Scaffold(
        body: Center(
          child: Text(
            userProvider.error ?? campProvider.error ?? "Unknown Error",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    if (userProvider.user == null) {
      return Scaffold(
        body: const Center(child: Text("No user data found.")),
      );
    }
    final currentUser = userProvider.user!;
    final camps = campProvider.camps;

    if (camps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Camps")),
        body: const Center(child: Text("No camps found.")),
      );
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: camps.length,
        itemBuilder: (context, index) {
          final camp = camps[index];
          final isFavorite = currentUser.favCamps?.contains(camp.id.toString()) ?? false;

          final walkingDistance = _getWalkingDistance(camp.location);
          final cyclingDistance = _getCyclingDistance(camp.location);
          final drivingDistance = _getDrivingDistance(camp.location);
          final ticketColor = _getTicketColor(camp, userProvider);

          return Card(
  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  child: ExpansionTile(
    leading: CircleAvatar(
      radius: 25,
      backgroundImage: camp.imageUrl != null
          ? NetworkImage(camp.imageUrl!)
          : null,
      child: camp.imageUrl == null
          ? const Icon(Icons.image_not_supported)
          : null,
    ),
    // Show camp name in the title only
    title: Text(
      camp.name,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    // Put distances in first line, and map/ticket/favorite in second line
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First line: Distances
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Walking distance
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_walk, size: 16),
                const SizedBox(width: 4),
                Text(walkingDistance),
              ],
            ),
            // Cycling distance
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_bike, size: 16),
                const SizedBox(width: 4),
                Text(cyclingDistance),
              ],
            ),
            // Driving distance
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_car, size: 16),
                const SizedBox(width: 4),
                Text(drivingDistance),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Second line: Map, Ticket icon, Favorite
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Map button
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Map button clicked (placeholder)"),
                  ),
                );
              },
            ),

            // Ticket status
            Icon(Icons.confirmation_num, color: ticketColor),

            // Favorite icon
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () => userProvider.toggleFavorite(camp),
            ),
          ],
        ),
      ],
    ),
    children: [
      // Expanded content (e.g. description & events placeholder)
      Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.white,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Camp Description: ${camp.description}",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              "Events (Placeholder)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text("• Event 1"),
            const Text("• Event 2"),
            const Text("• Event 3"),
          ],
        ),
      )
    ],
  ),
);
        },
      ),
    );
  }
}