  // art_screen.dart
  import 'package:burn_tech/models/color.dart';
  import 'package:burn_tech/screens/arts/art_card.dart';
  import 'package:burn_tech/screens/arts/art_details_screen.dart';
  import 'package:burn_tech/screens/arts/arts_screen_provider.dart';
  import 'package:burn_tech/screens/camps/user_provider.dart';
  import 'package:burn_tech/screens/chat/chat_screen.dart';
  import 'package:burn_tech/screens/map/map_screen.dart';
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';

  class ArtScreen extends StatefulWidget {
    final String currentUserId;
    const ArtScreen({Key? key, required this.currentUserId}) : super(key: key);

    @override
    State<ArtScreen> createState() => _ArtScreenState();
  }

  class _ArtScreenState extends State<ArtScreen> {
    late TextEditingController _searchController;
    @override
    void initState() {
      super.initState();
      _searchController = TextEditingController();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.currentUserId.isEmpty) {
          debugPrint("Error: currentUserId is empty!");
          return;
        }
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.fetchUser(widget.currentUserId);

        final artProvider = Provider.of<ArtProvider>(context, listen: false);
        artProvider.fetchArt();
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
      final artProvider = Provider.of<ArtProvider>(context);

      final isLoading = artProvider.isLoading;
      final hasError = artProvider.error != null;

      if (isLoading) {
        return Scaffold(
          body: Container(
              height: 800,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(250, 139, 0, 1),
                    Color.fromRGBO(248, 51, 60, 1)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child:
                  Center(child: CircularProgressIndicator(color: Colors.white))),
        );
      }

      if (hasError) {
        return Scaffold(
          body: Center(
            child: Text(
              artProvider.error ?? "Unknown Error",
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
      final artItems = artProvider.filteredArts;

      if (artItems.isEmpty) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Arts',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
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
                _buildSearchBar(artProvider),
                const Expanded(child: Center(child: Text("No Arts found."))),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Arts',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(250, 139, 0, 1),
                Color.fromRGBO(248, 51, 60, 1)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              _buildSearchBar(artProvider),
              Expanded(
                child: ListView.builder(
                  itemCount: artItems.length,
                  itemBuilder: (context, index) {
                    final art = artItems[index];
                    return ArtCard(
                      art: art,
                      currentUser: currentUser,
                      onMapPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MapTab(arts: [art], camps: []),
                          ),
                        );
                      },
                      onFavoritePressed: () =>
                          userProvider.toggleArtFavorite(art),
                      onTapDetails: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArtDetailScreen(artId: art.uid ?? ''),
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

    Widget _buildSearchBar(ArtProvider artProvider) {
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
                  hintText: 'Search Arts...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  if (value.trim().isEmpty) {
                    artProvider.searchArts("");
                  } else {
                    artProvider.searchArts(value);
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                final value = _searchController.text;
                artProvider.searchArts(value);
              },
            ),
          ],
        ),
      );
    }
  }
