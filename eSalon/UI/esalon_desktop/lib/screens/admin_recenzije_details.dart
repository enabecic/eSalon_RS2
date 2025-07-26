import 'package:esalon_desktop/models/recenzija.dart';
import 'package:esalon_desktop/models/recenzija_odgovor.dart';
import 'package:esalon_desktop/providers/recenzija_odgovor_provider.dart';
import 'package:esalon_desktop/providers/recenzija_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminRecenzijeDetailsScreen extends StatelessWidget {
  final dynamic item;

  const AdminRecenzijeDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isRecenzija = item is Recenzija;
    final bool isOdgovor = item is RecenzijaOdgovor; 

    final String komentar = item.komentar;
    final int brojLajkova = item.brojLajkova;
    final int brojDislajkova = item.brojDislajkova;
    final String? komentarRecenzije = isOdgovor ? item.komentarRecenzije : null;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 240, 255),
      body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("eSalon",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                Image.asset('assets/images/logo.png',
                    height: 80, width: 80, fit: BoxFit.contain),
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
                Text(
                  isRecenzija
                      ? "Detalji recenzije"
                      : "Detalji odgovora na recenziju",
                  style: const TextStyle(fontSize: 22),
                ),
              ],
            ),
          ),

          // Sadržaj
          Padding(
            padding: const EdgeInsets.fromLTRB(80, 40, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("Korisničko ime:", item.korisnickoIme ?? ''),
                const SizedBox(height: 16),
                _buildInfoRow("Broj lajkova:", brojLajkova.toString()),
                const SizedBox(height: 16),
                _buildInfoRow("Broj dislajkova:", brojDislajkova.toString()),
                const SizedBox(height: 16),
                _buildInfoRow("Datum dodavanja:", DateFormat('dd.MM.yyyy HH:mm').format(item.datumDodavanja)),
                const SizedBox(height: 24),
                const Text(
                  "Komentar:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 160,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      komentar,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                if (isOdgovor && komentarRecenzije != null && komentarRecenzije.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Text(
                    "Komentar na koji je odgovoreno:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 160,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        komentarRecenzije,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(80, 40, 60, 20), 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 140,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                            foregroundColor: const Color.fromARGB(199, 0, 0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "OK",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        height: 50,
                        width: 140,
                        child: ElevatedButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                title: const Text("Potvrda brisanja"),
                                content: const Text(
                                    "Da li želite obrisati sadržaj zbog neprimjerenog komentara?"),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "NE",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "DA",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              try {
                                if (isRecenzija) {
                                  final provider = RecenzijaProvider();
                                  await provider.delete(item.recenzijaId!);
                                } else {
                                  final provider = RecenzijaOdgovorProvider();
                                  await provider.delete(item.recenzijaOdgovorId!);
                                }

                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16)),
                                      title: const Text("Obrisano"),
                                      content: const Text(
                                          "Sadržaj je uspješno obrisan."),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.deepPurple,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text("OK",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                Navigator.pop(context, true); 

                              } catch (e) {
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    title: const Text("Greška"),
                                    content: Text(e.toString()),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: const Text("OK",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                            foregroundColor: const Color.fromARGB(199, 0, 0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Obriši",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
