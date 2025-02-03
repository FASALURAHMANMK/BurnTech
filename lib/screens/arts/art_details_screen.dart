// art_detail_screen.dart
import 'package:burn_tech/models/color.dart';
import 'package:burn_tech/screens/arts/art_details_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArtDetailScreen extends StatefulWidget {
  final String artId;
 
  const ArtDetailScreen({Key? key, required this.artId}) : super(key: key);

   @override
  State<ArtDetailScreen> createState() => _ArtDetailScreenState();
}
 
class _ArtDetailScreenState extends State<ArtDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the camp details as soon as the screen is initialized
    Future.microtask(() {
      Provider.of<ArtDetailProvider>(context, listen: false)
          .fetchArtDetails(widget.artId);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ArtDetailProvider>(
      builder: (context, artDetailProvider, child) {
        final art = artDetailProvider.art;
        final isLoading = artDetailProvider.isLoading;
        final errorMessage = artDetailProvider.errorMessage;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: desertOrange,
            title: Text(isLoading?'':
              art?.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
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

               child:Center(child: CircularProgressIndicator(color: Colors.white))
        )
              : errorMessage != null
                  ? Center(child: Text(errorMessage))
                  : art == null
                      ? const Center(child: Text("No art found."))
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
                      child:SingleChildScrollView(
                        
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              if (art.images![0].thumbnailUrl != null && art.images![0].thumbnailUrl!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    art.images![0].thumbnailUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 200,
                                    errorBuilder: (ctx, error, stack) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        height: 200,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              const SizedBox(height: 16),
                              // Camp Name
                              Text(
                                art.name ?? '',
                                style: Theme.of(context)
                                    .textTheme.headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                    ),
                              ),
                              const SizedBox(height: 8),
                              
                              if (art.artist != null &&
                                  art.artist!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        color: Colors.black),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        art.artist!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: Colors.black
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              // Hometown
                              if (art.hometown != null &&
                                  art.hometown!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.home,
                                        color: Colors.white),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        art.hometown!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.white
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              
                              const SizedBox(height: 8),
                              // Description
                              if (art.description != null &&
                                  art.description!.isNotEmpty)
                                Text(
                                  art.description!,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                              color: Colors.white
                                            ),
                                ),
                              const SizedBox(height: 16),

                              // Contact Email
                              if (art.contactEmail != null &&
                                  art.contactEmail!.isNotEmpty)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.email,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        art.contactEmail!,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 8),
                              if (art.url != null &&
                                  art.url!.isNotEmpty)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.link,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        art.url!,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 8),
                              // Landmark
                              /*if (camp.landmark != null &&
                                  camp.landmark!.isNotEmpty)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
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

                              const SizedBox(height: 16),*/

                              // Location info (latitude / longitude / location_string)
                              if (art.locationString != null &&
                                  art.locationString!.isNotEmpty)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.place, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        art.locationString!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Colors.white
                                            ),
                                      ),
                                    ),
                                  ],
                                ),

                              // (Optional) Display lat/long if they exist
                              if (art.location!.gpsLatitude != null &&
                                  art.location!.gpsLongitude != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  "Coordinates: (${art.location!.gpsLatitude}, ${art.location!.gpsLongitude})",
                                  style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                              color: Colors.white
                                            ),
                                ),
                              ],
                      
                            ],
                          ),
                        ),
        ),
        );
      },
    );
  }
}