  import 'package:burn_tech/models/art_model.dart';
  import 'package:burn_tech/models/camp_model.dart';
  import 'package:burn_tech/models/color.dart';
  import 'package:burn_tech/models/event_model.dart';
  import 'package:burn_tech/screens/arts/art_card.dart';
  import 'package:burn_tech/screens/arts/art_details_screen.dart';
  import 'package:burn_tech/screens/auth/auth_provider.dart';
  import 'package:burn_tech/screens/camps/camp_card.dart';
  import 'package:burn_tech/screens/camps/camp_details_screen.dart';
  import 'package:burn_tech/screens/camps/user_provider.dart';
  import 'package:burn_tech/screens/chat/chat_screen.dart';
  import 'package:burn_tech/screens/home/home_cards.dart';
  import 'package:burn_tech/screens/home/home_screen_provider.dart';
  import 'package:burn_tech/screens/map/map_screen.dart';
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';

  class HomeTab extends StatelessWidget {
    const HomeTab({super.key});

    @override
    Widget build(BuildContext context) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        authProvider.checkUidInPrefs();
        if (authProvider.uid != null && authProvider.uid!.isNotEmpty) {
          userProvider.fetchUser(authProvider.uid!);
        }
      });

      return Consumer<UserProvider>(
        builder: (context, userProv, child) {
          final currentUser = userProv.user;
          if (currentUser == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'BurnTech',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
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
              height: double.infinity,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    ExpandableWalletCard(
                      icon: Icons.confirmation_num,
                      title: 'My Tickets',
                      color: Colors.green,
                      future: homeProvider.getMyTickets(currentUser),
                      itemBuilder: (context, item) {
                        if (item is ArtModel) {
                          return ArtCard(
                            art: item,
                            currentUser: currentUser,
                            onMapPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MapTab(arts: [item], camps: []),
                                ),
                              );
                            },
                            onFavoritePressed: () {
                              userProvider.toggleArtFavorite(item);
                            },
                            onTapDetails: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ArtDetailScreen(artId: item.uid ?? ''),
                                ),
                              );
                            },
                          );
                        } else if (item is CampModel) {
                          return CampCard(
                            camp: item,
                            currentUser: currentUser,
                            onMapPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MapTab(arts: [], camps: [item]),
                                ),
                              );
                            },
                            onFavoritePressed: () {
                              userProvider.toggleFavorite(item);
                            },
                            onTapDetails: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CampDetailsScreen(campId: item.uid ?? ''),
                                ),
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 20),
                    ExpandableWalletCard(
                      icon: Icons.event,
                      title: 'Upcoming Events',
                      color: desertOrange,
                      future: homeProvider.getUpcomingEvents(),
                      itemBuilder: (context, item) {
                        if (item is EventModel) {
                          String startTime = "Time N/A";
                          if (item.occurrenceSet != null &&
                              item.occurrenceSet!.isNotEmpty) {
                            DateTime? occTime = item.occurrenceSet!
                                .firstWhere((occ) => occ.startTime != null,
                                    orElse: () => EventOccurrence(
                                        startTime: DateTime.now()))
                                .startTime;
                            startTime = occTime != null
                                ? "${occTime.hour}:${occTime.minute.toString().padLeft(2, '0')}"
                                : startTime;
                          }
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 4),
                            child: ListTile(
                              leading: const Icon(Icons.event_available,
                                  color: desertOrange),
                              title: Text(item.title ?? "Untitled Event",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text("Starts at: $startTime",
                                  style: TextStyle(color: Colors.green)),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 20),
                    ExpandableWalletCard(
                      icon: Icons.location_on,
                      title: 'Nearby Camps & Arts',
                      color: Colors.blue,
                      future: homeProvider.getNearbyCampsAndArts(),
                      itemBuilder: (context, item) {
                        if (item is CampModel) {
                          return CampCard(
                            camp: item,
                            currentUser: currentUser,
                            onMapPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MapTab(arts: [], camps: [item]),
                                ),
                              );
                            },
                            onFavoritePressed: () {
                              userProvider.toggleFavorite(item);
                            },
                            onTapDetails: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CampDetailsScreen(campId: item.uid ?? ''),
                                ),
                              );
                            },
                          );
                        } else if (item is ArtModel) {
                          return ArtCard(
                            art: item,
                            currentUser: currentUser,
                            onMapPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MapTab(arts: [item], camps: []),
                                ),
                              );
                            },
                            onFavoritePressed: () {
                              userProvider.toggleArtFavorite(item);
                            },
                            onTapDetails: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ArtDetailScreen(artId: item.uid ?? ''),
                                ),
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 20),
                    ExpandableWalletCard(
                      icon: Icons.campaign,
                      title: 'Announcements',
                      color: Colors.red,
                      future: homeProvider.getAnnouncements(),
                      itemBuilder: (context, item) {
                        if (item is String) {
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 4),
                            child: ListTile(
                              leading:
                                  const Icon(Icons.campaign, color: Colors.red),
                              title: Text(item,
                                  style: TextStyle(color: Colors.black)),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }
