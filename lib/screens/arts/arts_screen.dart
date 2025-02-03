// art_screen.dart
import 'package:burn_tech/models/color.dart';
import 'package:burn_tech/screens/arts/art_details_screen.dart';
import 'package:burn_tech/screens/arts/arts_screen_provider.dart';
import 'package:burn_tech/screens/camps/user_provider.dart';
import 'package:burn_tech/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:burn_tech/models/art_model.dart';

class ArtScreen extends StatefulWidget {
  final String currentUserId;
  const ArtScreen({Key? key,required this.currentUserId}) : super(key: key);

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

  // Distance placeholder functions.
  String _getWalkingDistance(ArtModel art) => "5 min";
  String _getCyclingDistance(ArtModel art) => "2 min";
  String _getDrivingDistance(ArtModel art) => "1 min";

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

               child:Center(child: CircularProgressIndicator(color: Colors.white))
        ),
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
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 28),
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
        child:Column(
         children: [
          _buildSearchBar(artProvider),
          Expanded(
            child:ListView.builder(
          itemCount: artItems.length,
          itemBuilder: (context, index) {
            final art = artItems[index];

            // Check if the art is favourited.
            final isFavorite = currentUser.favArts?.contains(art.uid) ?? false;
            final haveToken = currentUser.artTokens?.contains(art.uid) ?? false;
            // Distance placeholders.
            final walkingDistance = _getWalkingDistance(art);
            final cyclingDistance = _getCyclingDistance(art);
            final drivingDistance = _getDrivingDistance(art);


            // Build the rectangular thumbnail.
            Widget thumbnail;
            if (art.images != null &&
                art.images!.isNotEmpty &&
                art.images!.first.thumbnailUrl != null) {
              thumbnail = CircleAvatar(
    radius: 30, // radius of 50 gives a diameter of 100
    backgroundImage: NetworkImage(art.images!.first.thumbnailUrl!),
  );
            } else {
              thumbnail = ClipOval(
    child: Container(
      width: 100,
      height: 100,
      color: Colors.grey,
      child: const Icon(Icons.image, color: Colors.white),
    ),
  );
            }

            return Card(
              shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18), // Change 20.0 to your desired radius
  ),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: thumbnail,
                title: Text(
                  art.name ?? 'Unnamed Art',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display hometown instead of year.
                    Text("Hometown: ${art.hometown ?? 'N/A'}"),
                    const SizedBox(height: 4),
                    // Distance indicators row.
                    Wrap(
                      spacing: 6,
                      runSpacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions_walk, size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(walkingDistance, style: const TextStyle(color: Colors.green)),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions_bike, size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(cyclingDistance, style: const TextStyle(color: Colors.green)),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions_car, size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(drivingDistance, style: const TextStyle(color: Colors.green)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Row of action icons: Ticket, Donation, Favourite.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Ticket button.
                        IconButton(
                        icon: const Icon(Icons.map, color: Colors.blue),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Map button clicked (placeholder)"),
                            ),
                          );
                        },
                      ),
                        IconButton(
                          icon: Icon(
                            Icons.confirmation_num,
                            color: haveToken ? Colors.green : desertOrange,
                          ),
                           onPressed: () => userProvider.updateArtTokens(art),
                        ),
                        // Donation link button (only shown if donationLink exists).
                       
                        // Favourite button.
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => userProvider.toggleArtFavorite(art),
                        ),
                      ],
                    ),
                  ],
                ),
                // Trailing arrow icon to navigate to the details screen.
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArtDetailScreen(artId: art.uid??''),
                      ),
                    );
                  },
                ),
              ),
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
                // If the search field is empty, show full list.
                if (value.trim().isEmpty) {
                  artProvider.searchArts(""); // Ensure your provider resets the filtered list on empty search.
                } else {
                  artProvider.searchArts(value);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Trigger search when the search icon is pressed.
              final value = _searchController.text;
              artProvider.searchArts(value);
            },
          ),
        ],
      ),
    );
  }
}