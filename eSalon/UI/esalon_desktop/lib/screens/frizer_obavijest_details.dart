import 'package:esalon_desktop/models/obavijest.dart';
import 'package:esalon_desktop/providers/utils.dart';
import 'package:flutter/material.dart';

class FrizerObavijestDetailsScreen extends StatelessWidget {
  final Obavijest obavijest;

  const FrizerObavijestDetailsScreen({super.key, required this.obavijest});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 240, 255),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "eSalon",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 12),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    width: 80,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 35.0, top: 30.0, bottom: 20.0),
              child: Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back, size: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Detalji obavijesti",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black26,
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Naslov
                          Row(
                            children: [
                              const Icon(Icons.notifications_on_outlined, size: 28, color: Colors.black),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  obavijest.naslov,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Datum
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 24, color: Colors.black),
                              const SizedBox(width: 12),
                              Text(
                                formatirajDatum(obavijest.datumObavijesti),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          // Sadržaj
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.description, size: 24, color: Colors.black),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  obavijest.sadrzaj,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    height: 1.5,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 35),

                          // Dugme OK
                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 190,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                                  foregroundColor: Colors.black,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text("OK"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

