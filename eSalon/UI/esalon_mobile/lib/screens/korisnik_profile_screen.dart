import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:esalon_mobile/main.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';

class KorisnikProfileScreen extends StatefulWidget {
  const KorisnikProfileScreen({super.key});

  @override
  State<KorisnikProfileScreen> createState() => _KorisnikProfileScreenState();
}

class _KorisnikProfileScreenState extends State<KorisnikProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea( 
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildPage(),
                  ],
                ),
              ),
            ),
            // Positioned(
            //   top: 20,
            //   left: 10,
            //   child: IconButton(
            //     icon: const Icon(
            //       Icons.arrow_back,
            //       color: Colors.white,
            //     ),
            //     onPressed: () {
            //       Navigator.pop(context, true);
            //     },
            //   ),
            // ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          //color: const Color.fromARGB(255, 255, 251, 255),
          color: const Color.fromARGB(255, 247, 244, 247),
          //height: 100,
          height: MediaQuery.of(context).size.height * 0.12,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                      image: AuthProvider.slika != null
                          ? DecorationImage(
                              image: MemoryImage(
                                  base64Decode(AuthProvider.slika!)),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image:
                                  AssetImage("assets/images/prazanProfil.png"),
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPage() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        // color: Colors.white,
        width: double.infinity,
        //margin: const EdgeInsets.only(top: 100),
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Korisničko ime',
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 108, 108, 108),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: AuthProvider.username,
                  hintStyle: const TextStyle(color: Colors.black),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.account_circle_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 108, 108, 108),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: AuthProvider.email,
                  hintStyle: const TextStyle(color: Colors.black),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Align(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              bottom: 0,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 173, 178, 178),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fixedSize: const Size(double.infinity, 40),
                ),
                icon: const Icon(
                  Icons.edit,
                  color: Colors.black,
                ),
                label: const Center(
                  child: Text(
                    "Uredi profil",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                onPressed: () {
                  print("Kliknuto na Uredi profil!");
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => KorisnikProfileEditScreen()),
                  // ).then((value) {
                  //   if (value == true) {
                  //     setState(() {});
                  //   }
                  // });
                },
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 210, 193, 214),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fixedSize: const Size(double.infinity, 40),
                ),
                icon: const Icon(Icons.logout, color: Colors.black),
                label: const Center(
                  child: Text(
                    "Odjavi se",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                onPressed: () {
                  AuthProvider.datumRegistracije = null;
                  AuthProvider.email = null;
                  AuthProvider.ime = null;
                  AuthProvider.korisnikId = null;
                  AuthProvider.prezime = null;
                  AuthProvider.slika = null;
                  AuthProvider.telefon = null;
                  AuthProvider.username = null;
                  AuthProvider.password = null;
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const MyApp()));

                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}