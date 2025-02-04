import 'package:burn_tech/models/user_model.dart';
import 'package:burn_tech/screens/arts/art_card.dart';
import 'package:burn_tech/screens/arts/art_details_screen.dart';
import 'package:burn_tech/screens/arts/fav_art_screen_provider.dart';
import 'package:burn_tech/screens/chat/chat_screen.dart';
import 'package:burn_tech/screens/map/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:burn_tech/screens/camps/user_provider.dart';
import 'package:burn_tech/models/color.dart';

class favArtScreen extends StatefulWidget {
  final String currentUserId;

  const favArtScreen({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<favArtScreen> createState() => _favArtScreenState();
}

class _favArtScreenState extends State<favArtScreen> {
  late TextEditingController _searchController;
  late favArtProvider favartProvider;
  late UserModel currentUser;
  bool _dataInitialized = false; // To ensure initialization only happens once

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Delay fetching user data until after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.currentUserId.isEmpty) {
        debugPrint("Error: currentUserId is empty!");
      } else {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.fetchUser(widget.currentUserId);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize the favcampProvider and fetch camp data only once when dependencies change.
    if (!_dataInitialized) {
      favartProvider = Provider.of<favArtProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context);
      if (userProvider.user != null) {
        currentUser = userProvider.user!;
        // Schedule the initialization after the current frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeData();
        });
        _dataInitialized = true;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// First fetch the camps, then update the favorite camps based on the current user.
  Future<void> _initializeData() async {
    await favartProvider.fetchArts();
    favartProvider.updateFavoriteArts(currentUser);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final favartProvider = Provider.of<favArtProvider>(context);

    final isLoading = userProvider.isLoading || favartProvider.isLoading;
    final hasError = userProvider.error != null || favartProvider.error != null;

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
          child: const Center(
              child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    if (hasError) {
      return Scaffold(
        body: Center(
          child: Text(
            userProvider.error ?? favartProvider.error ?? "Unknown Error",
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

    // Use the user data from the provider.
    final currentUser = userProvider.user!;
    final arts = favartProvider.filteredArts;

    if (arts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Favourite Arts',
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
                width: 24,
                height: 24,
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
              _buildSearchBar(favartProvider),
              const Expanded(
                  child: Center(child: Text("No camps found."))),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favourite Arts',
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
              width: 24,
              height: 24,
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
            _buildSearchBar(favartProvider),
            Expanded(
              child: ListView.builder(
                itemCount: arts.length,
                itemBuilder: (context, index) {
                  final art = arts[index];
                  return ArtCard(
                    art: art,
                    currentUser: currentUser,
                    onMapPressed: () {
                      Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MapTab(arts: [art],camps: []),
                ),
              );
                    },
                    onFavoritePressed: () =>
                        userProvider.toggleArtFavorite(art),
                    onTapDetails: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArtDetailScreen(
                              artId: art.uid ?? ''),
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

  Widget _buildSearchBar(favArtProvider favartProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
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
                hintText: 'Search arts...',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (value.trim().isEmpty) {
                  favartProvider.searchArts("");
                } else {
                  favartProvider.searchArts(value);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final value = _searchController.text;
              favartProvider.searchArts(value);
            },
          ),
        ],
      ),
    );
  }
}