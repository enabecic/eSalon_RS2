import 'package:esalon_mobile/screens/korisnik_profile_edit_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esalon_mobile/providers/korisnik_provider.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/main.dart';

class KorisnikProfileScreen extends StatefulWidget {
  const KorisnikProfileScreen({super.key});

  @override
  State<KorisnikProfileScreen> createState() => _KorisnikProfileScreenState();
}

class _KorisnikProfileScreenState extends State<KorisnikProfileScreen> {
  late KorisnikProvider _provider;
  bool _isLoading = true;

  Map<String, String> _korisnikPodaci = {
    'korisnickoIme': '',
    'ime': '',
    'prezime': '',
    'email': '',
    'telefon': '',
    'datumRegistracije': '',
  };

  @override
  void initState() {
    super.initState();
    _provider = context.read<KorisnikProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _isLoading = true);
      _loadKorisnik();
    });
  }

  Future<void> _loadKorisnik() async {
    if (!mounted) return;

    if (!AuthProvider.isSignedIn || AuthProvider.korisnikId == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      if (!mounted) return;
      final korisnik = await _provider.getById(AuthProvider.korisnikId!);
      if (!mounted) return;
      setState(() {
        _korisnikPodaci = {
          'korisnickoIme': korisnik.korisnickoIme ?? '',
          'ime': korisnik.ime ?? '',
          'prezime': korisnik.prezime ?? '',
          'email': korisnik.email ?? '',
          'telefon': korisnik.telefon ?? '',
          'datumRegistracije': korisnik.datumRegistracije?.toString() ?? '',
        };
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 1800),
          content: Center(
            child: Text(
              "Neuspješno učitavanje podataka o korisniku.",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );

      // Future.delayed(const Duration(milliseconds: 1800), () {
      //   if (!mounted) return;
      //   Navigator.pop(context);
      // });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 244, 247),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : AuthProvider.isSignedIn
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                        maxWidth: constraints.maxWidth, 
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeader(),
                                const SizedBox(height: 35),
                                _buildInfoSection(),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text:
                            "Za pristup ovom dijelu aplikacije morate biti prijavljeni! ",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: "Molimo prijavite se!",
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 210, 193, 214),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible( 
              child: Text(
                "Moj korisnički profil",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1, 
                overflow: TextOverflow.ellipsis, 
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.person,
              color: Colors.black,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor ?? Colors.black, size: 20),
          const SizedBox(width: 10),
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("Ime:", _korisnikPodaci['ime'] ?? "/", Icons.person),
          _buildInfoRow("Prezime:", _korisnikPodaci['prezime'] ?? "/",
              Icons.person_outline),
          _buildInfoRow(
              "Korisničko ime:",
              _korisnikPodaci['korisnickoIme'] ?? "/",
              Icons.account_circle_outlined),
          _buildInfoRow(
              "Email:", _korisnikPodaci['email'] ?? "/", Icons.email_outlined),
          _buildInfoRow("Telefon:", _korisnikPodaci['telefon'] ?? "/",
              Icons.phone_outlined),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () async {
              if (!mounted) return;
              final refresh = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KorisnikProfileEditScreen(),
                ),
              );

              if (refresh == true) {
              if (!mounted) return;
                await _loadKorisnik();
              }
            },
            icon: const Icon(Icons.edit, color: Colors.black),
            label: const Text(
              'Uredi profil',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 210, 193, 214),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout, color: Colors.black),
            label: const Text(
              "Odjavi se",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,              
                fontWeight: FontWeight.w600,),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 210, 209, 210),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              if (!mounted) return;
              final potvrda = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Potvrda odjave"),
                  content: const Text("Da li ste sigurni da se želite odjaviti?"),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        "Ne",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        "Da",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (potvrda == true) {
                AuthProvider.datumRegistracije = null;
                AuthProvider.email = null;
                AuthProvider.ime = null;
                AuthProvider.korisnikId = null;
                AuthProvider.prezime = null;
                AuthProvider.slika = null;
                AuthProvider.telefon = null;
                AuthProvider.username = null;
                AuthProvider.password = null;
                AuthProvider.uloge = null;
                AuthProvider.isSignedIn = false;
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                );
                if (!mounted) return;
                setState(() {});
              }
            },
          ),
        ),
      ],
    );
  }
}