  import 'package:burn_tech/models/color.dart';
  import 'package:burn_tech/models/event_model.dart';
  import 'package:burn_tech/screens/camps/camp_details_screen_provider.dart';
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';

  class CampDetailsScreen extends StatefulWidget {
    final String campId;

    const CampDetailsScreen({Key? key, required this.campId}) : super(key: key);

    @override
    State<CampDetailsScreen> createState() => _CampDetailsScreenState();
  }

  class _CampDetailsScreenState extends State<CampDetailsScreen> {
    @override
    void initState() {
      super.initState();
      Future.microtask(() {
        Provider.of<CampDetailProvider>(context, listen: false)
            .fetchCampAndEvents(widget.campId);
      });
    }

    @override
    Widget build(BuildContext context) {
      return Consumer<CampDetailProvider>(
        builder: (context, campDetailProvider, child) {
          final camp = campDetailProvider.camp;
          final isLoading = campDetailProvider.isLoading;
          final errorMessage = campDetailProvider.errorMessage;
          final events = campDetailProvider.campEvents;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: desertOrange,
              title: Text(
                isLoading ? '' : camp?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            body: isLoading
                ? Container(
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
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.white)))
                : errorMessage != null
                    ? Center(child: Text(errorMessage))
                    : camp == null
                        ? const Center(child: Text("No camp found."))
                        : Container(
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
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  Text(
                                    camp.name ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  if (camp.hometown != null &&
                                      camp.hometown!.isNotEmpty)
                                    Row(
                                      children: [
                                        const Icon(Icons.home,
                                            color: Colors.white),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            camp.hometown!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 8),
                                  if (camp.description != null &&
                                      camp.description!.isNotEmpty)
                                    Text(
                                      camp.description!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.white),
                                    ),
                                  const SizedBox(height: 16),
                                  if (camp.contactEmail != null &&
                                      camp.contactEmail!.isNotEmpty)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.email,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            camp.contactEmail!,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                  const SizedBox(height: 8),
                                  if (camp.url != null && camp.url!.isNotEmpty)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.link,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            camp.url!,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                  const SizedBox(height: 8),
                                  // Landmark
                                  if (camp.landmark != null &&
                                      camp.landmark!.isNotEmpty)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.map,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            camp.landmark!,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 16),
                                  if (camp.locationString != null &&
                                      camp.locationString!.isNotEmpty)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.place,
                                            color: Colors.white),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            camp.locationString!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (camp.latitude != null &&
                                      camp.longitude != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      "Coordinates: (${camp.latitude}, ${camp.longitude})",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.white),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  const Divider(
                                    thickness: 1.0,
                                    height: 1.0,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Events Hosted by This Camp",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  events.isEmpty
                                      ? const Text(
                                          "No events found for this camp.",
                                          style: TextStyle(color: Colors.white),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: events.length,
                                          itemBuilder: (context, index) {
                                            final event = events[index];
                                            return _EventCard(event: event);
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

  class _EventCard extends StatelessWidget {
    final EventModel event;

    const _EventCard({Key? key, required this.event}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      final occurrences = event.occurrenceSet ?? [];
      final occurrenceText = occurrences.isNotEmpty
          ? occurrences.map((occ) {
              final start = occ.startTime != null
                  ? _formatDate(occ.startTime!)
                  : 'No Start';
              final end = occ.endTime != null ? _formatDate(occ.endTime!) : '';
              return '$start - $end';
            }).join('\n')
          : 'No Occurrences Listed';

      return Card(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(18),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: Text(
            event.title ?? 'Untitled Event',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.description != null && event.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    event.description!,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Time',
                style: const TextStyle(fontSize: 13, color: desertOrange),
              ),
              const SizedBox(height: 8),
              Text(
                occurrenceText,
                style: const TextStyle(fontSize: 13, color: Colors.green),
              ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
          },
        ),
      );
    }
    String _formatDate(DateTime date) {
      return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
