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
                      height: 80, 
                      width: 80, 
                      fit: BoxFit.contain
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
    padding: const EdgeInsets.fromLTRB(15.0, 50.0, 15.0, 15.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12.0, bottom: 8.0),
                  child: Text(
                    "Slika usluge sa promocije",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Container(
                width: 270,
                height: 250,
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
              const SizedBox(height: 13),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      _readonlyField(
                        "Aktivirana:",
                        (widget.aktiviranaPromocija?.aktivirana ?? false) ? "Da" : "Ne",
                      ),
                      _readonlyField(
                        "Iskorištena:",
                        (widget.aktiviranaPromocija?.iskoristena ?? false) ? "Da" : "Ne",
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _readonlyField(
                  "Naziv promocije:",
                  widget.aktiviranaPromocija?.promocijaNaziv ?? "",
                ),
                _readonlyField(
                  "Ime i prezime klijenta:",
                  widget.aktiviranaPromocija?.korisnikImePrezime ?? "",
                ),
                _readonlyField(
                  "Ostvareni popust:",
                  "${(widget.aktiviranaPromocija?.popust ?? 0).toInt()}%",
                ),
                _readonlyField(
                  "Datum aktiviranja:",
                  formatirajDatum(widget.aktiviranaPromocija?.datumAktiviranja),
                ),
                const SizedBox(height: 10),
                Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Align(
                  alignment: Alignment.centerRight, 
                  child: SizedBox(
                    width: 200, 
                    height: 45, 
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
              ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _readonlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

