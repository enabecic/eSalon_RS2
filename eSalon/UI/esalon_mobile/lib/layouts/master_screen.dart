import 'package:esalon_mobile/screens/korisnik_profile_screen.dart';
import 'package:esalon_mobile/screens/pocetni_screen.dart';
import 'package:esalon_mobile/screens/usluga_arhiva_screen.dart';
import 'package:esalon_mobile/screens/usluga_favorit_screen.dart';
import 'package:flutter/material.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PocetniScreen(),
    const Center(child: Text("Moje usluge (Korpa)")),
    const KorisnikProfileScreen(),
    const UslugaFavoritScreen(),
    const Center(child: Text("Sve usluge")),
    const Center(child: Text("Moje rezervacije")),
    const Center(child: Text("Posebne ponude")),
    const UslugaArhivaScreen(),
    const Center(child: Text("Obavijesti")),
  ];

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
                    const Text(
                      "eSalon",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Image.asset(
                        "assets/images/logo.png",
                        height: 70,
                        width: 70,
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
                title: const Text('Obavijesti'),
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
