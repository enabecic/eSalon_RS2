import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/obavijest_provider.dart';
import 'package:esalon_mobile/screens/korisnik_profile_screen.dart';
import 'package:esalon_mobile/screens/korpa_screen.dart';
import 'package:esalon_mobile/screens/obavijesti_screen.dart';
import 'package:esalon_mobile/screens/pocetni_screen.dart';
import 'package:esalon_mobile/screens/promocija_screen.dart';
import 'package:esalon_mobile/screens/moje_rezervacije_screen.dart';
import 'package:esalon_mobile/screens/usluga_arhiva_screen.dart';
import 'package:esalon_mobile/screens/usluga_favorit_screen.dart';
import 'package:esalon_mobile/screens/usluge_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PocetniScreen(),
    const KorpaScreen(),
    const KorisnikProfileScreen(),
    const UslugaFavoritScreen(),
    const UslugeScreen(),
    const MojeRezervacijeScreen(),
    const PromocijaScreen(),
    const UslugaArhivaScreen(),
    const ObavijestiScreen(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthProvider.isSignedIn) {
        context
            .read<ObavijestProvider>()
            .ucitajBrojNeprocitanih(AuthProvider.korisnikId!);
      }
    });
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 25),
          child: AppBar(
            elevation: 0,
            //backgroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 247, 244, 247),
            automaticallyImplyLeading: false,
            centerTitle: false,
            toolbarHeight: kToolbarHeight + 25,
            surfaceTintColor: Colors.transparent,
            forceMaterialTransparency: false,

            title: SafeArea( 
              child: Padding(
                padding: const EdgeInsets.only(top: 6.0), 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.black,
                          size: 40,
                        ),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    const Flexible( 
                      child: Text(
                        "eSalon",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis, 
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Image.asset(
                        "assets/images/logo.png",
                        height: 55,
                        width: 55,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.content_cut),
                title: const Text('Usluge'),
                onTap: () => _onDrawerItemTapped(4),
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Favoriti'),
                onTap: () => _onDrawerItemTapped(3),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Moje rezervacije'),
                onTap: () => _onDrawerItemTapped(5),
              ),
              ListTile(
                leading: const Icon(Icons.local_offer_outlined),
                title: const Text('Posebne ponude'),
                onTap: () => _onDrawerItemTapped(6),
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: const Text("Lista 'Želim probati'"), 
                onTap: () => _onDrawerItemTapped(7),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: Row(
                  children: [
                    const Text('Obavijesti'),
                    const SizedBox(width: 8),
                    Consumer<ObavijestProvider>(
                      builder: (context, provider, _) {
                        if (provider.neprocitane == 0) return const SizedBox();

                        final count = provider.neprocitane;
                        final displayText = count > 99 ? '99+' : count.toString();

                        return Transform.translate(
                          offset: const Offset(0, -5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              displayText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                onTap: () => _onDrawerItemTapped(8),
              ),
            ],
          ),
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex > 2 ? 0 : _selectedIndex,
          onTap: _onBottomNavTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color.fromARGB(255, 210, 193, 214),
          selectedItemColor: Colors.grey[900],
          unselectedItemColor: Colors.grey[900],
          selectedFontSize: 15,   
          unselectedFontSize: 14,  
          iconSize: 30,          
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Početna',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Korpa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
