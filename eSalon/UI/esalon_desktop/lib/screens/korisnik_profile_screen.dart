import 'dart:convert';
import 'package:esalon_desktop/screens/korisnik_profile_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:esalon_desktop/providers/auth_provider.dart';

class KorisnikProfileScreen extends StatefulWidget {
 const KorisnikProfileScreen({super.key});

  @override
  State<KorisnikProfileScreen> createState() => _KorisnikProfileScreenState();
}

class _KorisnikProfileScreenState extends State<KorisnikProfileScreen> {

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 240, 255),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color.fromARGB(255, 251, 240, 255),
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                    child: const Text(
                      "Profil",
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildPage(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          color: const Color.fromARGB(255, 251, 240, 255),
          height: 100,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 200,
                    height: 200,
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
        width: double.infinity,
        margin: const EdgeInsets.only(top: 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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

            const SizedBox(height: 50),
            Align(
              alignment: Alignment.centerRight,  
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 180, 140, 218), 
                  foregroundColor: const Color.fromARGB(199, 0, 0, 0), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(150, 50), 
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(
                  Icons.edit,
                ),
                label: const Text(
                  "Uredi profil",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const KorisnikProfilEditScreen()),
                  ).then((value) {
                    if (value == true) {
                      if (!mounted) return;
                      setState(() {});
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }

}



