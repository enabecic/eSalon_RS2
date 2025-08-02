import 'package:esalon_desktop/screens/admin_aktivirana_promocija_screen.dart';
import 'package:esalon_desktop/screens/admin_korisnici_screen.dart';
import 'package:esalon_desktop/screens/admin_promocija_screen.dart';
import 'package:esalon_desktop/screens/admin_recenzije_screen.dart';
import 'package:esalon_desktop/screens/admin_upravljanje_uslugama_screen.dart';
import 'package:esalon_desktop/screens/admin_upravljanje_vrstama_usluga_screen.dart';
import 'package:esalon_desktop/screens/frizer_korisnici_screen.dart';
import 'package:esalon_desktop/screens/frizer_recenzije_screen.dart';
import 'package:esalon_desktop/screens/frizer_usluge_screen.dart';
import 'package:esalon_desktop/screens/korisnik_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:esalon_desktop/main.dart';
import 'package:esalon_desktop/providers/auth_provider.dart';
import 'package:esalon_desktop/screens/admin_home_screen.dart';
import 'package:esalon_desktop/screens/frizer_home_screen.dart';

class MasterScreen extends StatefulWidget {
  final String title;
  final Widget initialScreen;

  const MasterScreen(this.title, this.initialScreen, {super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  late Widget currentScreen;
  late String _selectedTitle;
  String _hoveredTitle = "";

  @override
  void initState() {
    super.initState();
    currentScreen = widget.initialScreen;
    _selectedTitle = _getTitleForScreen(widget.initialScreen);
  }

  String _getTitleForScreen(Widget screen) {
    if (screen is AdminHomeScreen || screen is FrizerHomeScreen) return "Statistika";
    if (screen is PlaceholderScreen) return screen.title;
    return "";
  }

  void _setScreen(Widget screen, String title) {
    setState(() {
      currentScreen = screen;
      _selectedTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 300,
            color: const Color.fromRGBO(220, 201, 221, 1),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    // Glavni sadržaj liste sa skrolom
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),

                            if (AuthProvider.uloge?.contains("Admin") ?? false)
                              const Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  "Admin panel",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                            if (AuthProvider.uloge?.contains("Frizer") ?? false)
                              const Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  "Frizer panel",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 20),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              child: Divider(color: Colors.black, thickness: 0.5),
                            ),

                            if (AuthProvider.uloge?.contains("Admin") ?? false) ...[
                              _buildListTile(Icons.bar_chart_outlined, "Statistika", const AdminHomeScreen()),
                              _buildListTile(Icons.content_cut, "Usluge", const AdminUpravljanjeUslugamaScreen()),
                              _buildListTile(Icons.style, "Vrsta usluge", const AdminUpravljanjeVrstamaUslugaScreen()),
                              _buildListTile(Icons.people_outline, "Korisnici", const AdminKorisniciScreen()),
                              _buildListTile(Icons.reviews_outlined, "Recenzije", const AdminRecenzijaScreen()),
                              _buildListTile(Icons.local_offer_outlined, "Promocije", const AdminPromocijaScreen()),
                              _buildListTile(Icons.verified_outlined, "Aktivirane promocije", const AdminAktiviranaPromocijaScreen()),

                            ],

                            if (AuthProvider.uloge?.contains("Frizer") ?? false) ...[
                              _buildListTile(Icons.bar_chart_outlined, "Statistika", const FrizerHomeScreen()),
                              _buildListTile(Icons.calendar_today, "Rezervacije", const PlaceholderScreen("Rezervacije")),
                              _buildListTile(Icons.reviews_outlined, "Recenzije", const FrizerRecenzijaScreen()),
                              _buildListTile(Icons.content_cut, "Usluge", const FrizerUslugeScreen()),
                              _buildListTile(Icons.people_outline, "Korisnici", const FrizerKorisniciScreen()),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Footer
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Divider(color: Colors.black, thickness: 0.5),
                          const SizedBox(height: 10),
                          _buildListTile(Icons.edit_outlined, "Uredi profil", const KorisnikProfileScreen()),
                          _buildListTile(Icons.logout, "Odjava", null, logout: true),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: const Color.fromARGB(255, 251, 240, 255),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Spacer(),
                          const Text(
                            "eSalon",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Image.asset(
                            'assets/images/logo.png',
                            height: 80,
                            width: 80,
                            fit: BoxFit.contain,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color.fromARGB(255, 251, 240, 255),
                    child: currentScreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, Widget? screen, {bool logout = false}) {
    final bool isSelected = _selectedTitle == title;
    final bool isHovered = _hoveredTitle == title;

    final double iconSize = isHovered ? 30.0 : 28.0;
    final double fontSize = isHovered ? 20.0 : 19.0;
    final FontWeight fontWeight = isSelected ? FontWeight.bold : FontWeight.normal;

    return Padding(
      padding: EdgeInsets.only(
        left: logout || title == "Uredi profil" ? 10 : 20,
        right: 10,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveredTitle = title),
        onExit: (_) => setState(() => _hoveredTitle = ""),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (logout) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Potvrda odjave"),
                    content: const Text("Da li ste sigurni da se želite odjaviti?"),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Odustani",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // logout logika
                          AuthProvider.email = null;
                          AuthProvider.username = null;
                          AuthProvider.password = null;
                          AuthProvider.korisnikId = null;
                          AuthProvider.ime = null;
                          AuthProvider.prezime = null;
                          AuthProvider.slika = null;
                          //AuthProvider.jeAktivan =false;
                          AuthProvider.telefon = null;
                          AuthProvider.datumRegistracije = null;
                          AuthProvider.uloge = [];

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const MyApp()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Odjavi se",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else if (screen != null) {
              _setScreen(screen, title);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 0),
              leading: Icon(
                icon,
                size: iconSize,
                color: Colors.black,
                weight: isSelected ? 800 : 400,
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Stranica "$title" još nije implementirana.'),
    );
  }
}
