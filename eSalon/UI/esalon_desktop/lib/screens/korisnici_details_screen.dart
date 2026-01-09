import 'dart:convert';
import 'package:esalon_desktop/models/korisnik.dart';
import 'package:esalon_desktop/providers/utils.dart';
import 'package:flutter/material.dart';

class KorisniciDetailsScreen extends StatefulWidget {
  final Korisnik? korisnik;

  const KorisniciDetailsScreen({super.key, this.korisnik});

  @override
  State<KorisniciDetailsScreen> createState() =>
      _KorisniciDetailsScreenState();
}

class _KorisniciDetailsScreenState
    extends State<KorisniciDetailsScreen> {
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();

    final base64Image = widget.korisnik?.slika;
    if (base64Image != null) {
      _imageProvider = MemoryImage(base64Decode(base64Image));
    }
  }

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
                  const Text("eSalon",
                      style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.w500)),
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
                  const Text(
                    "Detalji korisnika",
                    style: TextStyle(fontSize: 22),
                  ),
                ],
              ),
            ),
            _buildDetailsView(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsView() {
  final status = widget.korisnik?.jeAktivan == true ? "Aktivan" : "Deaktiviran";
  final ulogeText = (widget.korisnik?.uloge?.isNotEmpty ?? false)
    ? widget.korisnik!.uloge!.join(', ')
    : "/";

    return Padding(
      padding: const EdgeInsets.fromLTRB(80.0, 50.0, 20.0, 15.0), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slika
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            const Padding(
                padding:  EdgeInsets.only(bottom: 26), 
                child:  Text(
                  "Slika korisnika:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 310,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: _imageProvider ??
                        const AssetImage("assets/images/prazanProfil.png"),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.2 * 255).round()),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(width: 70), 

          // Polja
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Ime:", widget.korisnik?.ime ?? "", icon: Icons.person),
                  _buildInfoRow("Prezime:", widget.korisnik?.prezime ?? "", icon: Icons.person_outlined),
                  _buildInfoRow("Korisničko ime:", widget.korisnik?.korisnickoIme ?? "", icon: Icons.account_circle),
                  _buildInfoRow("Email:", widget.korisnik?.email ?? "", icon: Icons.email),
                  _buildInfoRow("Telefon:", widget.korisnik?.telefon ?? "", icon: Icons.phone),
                  _buildInfoRow("Datum registracije:", formatirajDatum(widget.korisnik?.datumRegistracije), icon: Icons.calendar_today),
                  _buildInfoRow("Status:", status, icon: Icons.check_circle_outline),
                  _buildInfoRow("Uloge:", ulogeText, icon: Icons.group),
                  const SizedBox(height: 25),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 190,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.done, size: 20, color: Color.fromARGB(199, 0, 0, 0)),
                            SizedBox(width: 8),
                            Text('OK', style: TextStyle(fontSize: 16,),),
                          ],
                        ),
                      ),
                    ),
                  ),
                ].expand((widget) => [widget, const SizedBox(height: 16)]).toList() 
                  ..removeLast(), 
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 3), 
              child: Icon(icon, size: 23, color: Colors.black87),
            ),
            const SizedBox(width: 15),
          ],
          SizedBox(
            width: 250,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              softWrap: true,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

