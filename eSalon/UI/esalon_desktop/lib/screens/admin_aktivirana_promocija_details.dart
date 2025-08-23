import 'dart:convert';
import 'package:esalon_desktop/models/aktivirana_promocija.dart';
import 'package:esalon_desktop/providers/utils.dart';
import 'package:flutter/material.dart';

class AdminAktiviranaPromocijaDetails extends StatefulWidget {
  final AktiviranaPromocija? aktiviranaPromocija;

  const AdminAktiviranaPromocijaDetails({super.key, this.aktiviranaPromocija});

  @override
  State<AdminAktiviranaPromocijaDetails> createState() =>
      _AdminAktiviranaPromocijaDetailsState();
}

class _AdminAktiviranaPromocijaDetailsState
    extends State<AdminAktiviranaPromocijaDetails> {
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();

    final base64Image = widget.aktiviranaPromocija?.slikaUsluge;
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
                    "Detalji aktivirane promocije",
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
                  "Slika usluge sa promocije:",
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
                        const AssetImage("assets/images/praznaUsluga.png"),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
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
                  _buildInfoRow(label: "Naziv promocije:", value: widget.aktiviranaPromocija?.promocijaNaziv ?? "", icon: Icons.local_offer_outlined,),
                  _buildInfoRow(label: "Ime i prezime korisnika:", value: widget.aktiviranaPromocija?.korisnikImePrezime ?? "", icon: Icons.person, ),
                  _buildInfoRow(label: "Ostvareni popust:", value: "${(widget.aktiviranaPromocija?.popust ?? 0).toInt()}%", icon: Icons.percent, ),
                  _buildInfoRow(label: "Datum aktiviranja:", value: formatirajDatum(widget.aktiviranaPromocija?.datumAktiviranja), icon: Icons.calendar_today,),
                  _buildInfoRow(label: "Aktivirana:", value: (widget.aktiviranaPromocija?.aktivirana ?? false) ? "Da" : "Ne", icon: Icons.check_circle,),
                  _buildInfoRow(label: "Iskorištena:", value: (widget.aktiviranaPromocija?.iskoristena ?? false) ? "Da" : "Ne", icon: Icons.done_all,),
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
                        child: const Text("OK"),
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

  Widget _buildInfoRow({required String label, required String value, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 23, color: Colors.black87),
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
          const SizedBox(width: 30),
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

