  import 'package:burn_tech/models/art_model.dart';
  import 'package:burn_tech/models/color.dart';
  import 'package:burn_tech/screens/camps/user_provider.dart';
  import 'package:flutter/material.dart';

  class ArtDialog_Buy_Art extends StatelessWidget {
    final ArtModel art;
    final UserProvider userProvider;

    const ArtDialog_Buy_Art(
        {Key? key, required this.art, required this.userProvider})
        : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Text(
                art.name ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Icon(
                Icons.confirmation_num,
                size: 80,
                color: desertOrange,
              ),
              const SizedBox(height: 12),
              const Text(
                "\$25.99",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  userProvider.updateArtTokens(art);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.green),
                child: const Text("Buy Now"),
              ),
            ],
          ),
        ),
      );
    }
  }
