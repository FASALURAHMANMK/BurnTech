  import 'package:burn_tech/screens/camps/user_provider.dart';
  import 'package:burn_tech/screens/ticket/art_ticket_buy_dialogue.dart';
  import 'package:burn_tech/screens/ticket/art_ticket_view_dialogue.dart';
  import 'package:flutter/material.dart';
  import 'package:burn_tech/models/art_model.dart';
  import 'package:burn_tech/models/color.dart';
  import 'package:provider/provider.dart';

  class ArtCard extends StatelessWidget {
    final ArtModel art;
    final dynamic currentUser;
    final VoidCallback onMapPressed;
    final VoidCallback onFavoritePressed;
    final VoidCallback onTapDetails;

    const ArtCard({
      Key? key,
      required this.art,
      required this.currentUser,
      required this.onMapPressed,
      required this.onFavoritePressed,
      required this.onTapDetails,
    }) : super(key: key);

    String getWalkingDistance() => "5 min";
    String getCyclingDistance() => "2 min";
    String getDrivingDistance() => "1 min";

    Widget _buildThumbnail() {
      if (art.images != null &&
          art.images!.isNotEmpty &&
          art.images!.first.thumbnailUrl != null) {
        return CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(art.images!.first.thumbnailUrl!),
        );
      } else {
        return ClipOval(
          child: Container(
            width: 60,
            height: 60,
            color: Colors.grey,
            child: const Icon(Icons.image, color: Colors.white),
          ),
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      final bool isFavorite = currentUser.favArts?.contains(art.uid) ?? false;
      final bool haveToken = currentUser.artTokens?.contains(art.uid) ?? false;

      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8),
          leading: _buildThumbnail(),
          title: Text(
            art.name ?? 'Unnamed Art',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hometown: ${art.hometown ?? 'N/A'}"),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_walk,
                          size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(getWalkingDistance(),
                          style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_bike,
                          size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(getCyclingDistance(),
                          style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_car,
                          size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(getDrivingDistance(),
                          style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    onPressed: onMapPressed,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.confirmation_num,
                      color: haveToken ? Colors.green : desertOrange,
                    ),
                    onPressed: () {
                      !haveToken
                          ? showDialog(
                              context: context,
                              builder: (context) {
                                return ArtDialog_Buy_Art(
                                  art: art,
                                  userProvider: Provider.of<UserProvider>(context,
                                      listen: false),
                                );
                              },
                            )
                          : showDialog(
                              context: context,
                              builder: (context) {
                                return ArtDialog_View_Art(
                                  art: art,
                                  userProvider: Provider.of<UserProvider>(context,
                                      listen: false),
                                );
                              },
                            );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: onFavoritePressed,
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: onTapDetails,
          ),
        ),
      );
    }
  }
