import 'package:burn_tech/models/camp_model.dart';
import 'package:burn_tech/screens/camps/user_provider.dart';
import 'package:flutter/material.dart';

class ArtDialog_View_Camp extends StatelessWidget {
  final CampModel camp;
  final UserProvider userProvider;

  const ArtDialog_View_Camp({Key? key, required this.camp, required this.userProvider})
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
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Title
            Text(
              camp.name??'',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Ticket Icon
            const Icon(
              Icons.confirmation_num,
              size: 80,
              color: Colors.green,
            ),

            const SizedBox(height: 12),

            // Price Placeholder
            const Text(
              "Expire on 22/02/2025",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 16),

            // Buy Now Button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(foregroundColor: Colors.white,backgroundColor: Colors.green),
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }
}