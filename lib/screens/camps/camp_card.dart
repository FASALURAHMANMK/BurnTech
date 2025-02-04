  import 'package:burn_tech/screens/camps/user_provider.dart';
  import 'package:burn_tech/screens/ticket/camp_ticket_buy_dialogue.dart';
  import 'package:burn_tech/screens/ticket/camp_ticket_view_dialogue.dart';
  import 'package:flutter/material.dart';
  import 'package:burn_tech/models/camp_model.dart';
  import 'package:burn_tech/models/color.dart';
  import 'package:provider/provider.dart';

  class CampCard extends StatelessWidget {
    final CampModel camp;
    final dynamic currentUser;
    final VoidCallback onMapPressed;
    final VoidCallback onFavoritePressed;
    final VoidCallback onTapDetails;

    const CampCard({
      Key? key,
      required this.camp,
      required this.currentUser,
      required this.onMapPressed,
      required this.onFavoritePressed,
      required this.onTapDetails,
    }) : super(key: key);

    String getWalkingDistance() => "5 min";
    String getCyclingDistance() => "2 min";
    String getDrivingDistance() => "1 min";

    @override
    Widget build(BuildContext context) {
      final bool isFavorite = currentUser.favCamps?.contains(camp.uid) ?? false;
      final bool haveToken = currentUser.campTokens?.contains(camp.uid) ?? false;

      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: ListTile(
          title: Text(
            camp.name ?? 'Unnamed Camp',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
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
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
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
                                return ArtDialog_Buy_Camp(
                                  camp: camp,
                                  userProvider: Provider.of<UserProvider>(context,
                                      listen: false),
                                );
                              },
                            )
                          : showDialog(
                              context: context,
                              builder: (context) {
                                return ArtDialog_View_Camp(
                                  camp: camp,
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
