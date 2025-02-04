import 'package:burn_tech/screens/camps/camp_card.dart';
import 'package:burn_tech/screens/camps/camp_details_screen.dart';
import 'package:burn_tech/screens/camps/camp_screen_provider.dart';
import 'package:burn_tech/screens/chat/chat_screen.dart';
import 'package:burn_tech/screens/map/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:burn_tech/screens/camps/user_provider.dart';
import 'package:burn_tech/models/color.dart'; 

class CampScreen extends StatefulWidget {
  final String currentUserId;

  const CampScreen({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<CampScreen> createState() => _CampScreenState();
}

class _CampScreenState extends State<CampScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Once the widget is built, fetch user info & camp list
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final campProvider = Provider.of<CampProvider>(context);

    final isLoading = userProvider.isLoading || campProvider.isLoading;
    final hasError = userProvider.error != null || campProvider.error != null;

    if (isLoading) {
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
          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
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
      return const Scaffold(
        body: Center(child: Text("No user data found.")),
      );
    }

    final currentUser = userProvider.user!;
    final camps = campProvider.filteredCamps;

    if (camps.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Camps',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
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
              _buildSearchBar(campProvider),
              const Expanded(child: Center(child: Text("No camps found."))),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Camps',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
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
            // Persistent search bar at the top
            _buildSearchBar(campProvider),
            // Expanded list view of camps below the search bar
            Expanded(
              child: ListView.builder(
                itemCount: camps.length,
                itemBuilder: (context, index) {
                  final camp = camps[index];
                  return CampCard(
      camp: camp,
      currentUser: currentUser,
      onMapPressed: () {
         Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MapTab(arts: [],camps: [camp]),
                ),
              );
      },
      onFavoritePressed: () => userProvider.toggleFavorite(camp),
      onTapDetails: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CampDetailsScreen(campId: camp.uid ?? ''),
          ),
        );
      },
    );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Updated search bar widget using a simple Container rather than Positioned.
  Widget _buildSearchBar(CampProvider campProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search camps...',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                // If the search field is empty, show full list.
                if (value.trim().isEmpty) {
                  campProvider.searchCamps(""); // Ensure your provider resets the filtered list on empty search.
                } else {
                  campProvider.searchCamps(value);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Trigger search when the search icon is pressed.
              final value = _searchController.text;
              campProvider.searchCamps(value);
            },
          ),
        ],
      ),
    );
  }
}