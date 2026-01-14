import 'package:esalon_mobile/main.dart';
import 'package:esalon_mobile/screens/rezervacija_odabir_frizera_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:esalon_mobile/providers/rezervacija_cart_provider.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/usluga_provider.dart';
import 'package:esalon_mobile/screens/usluga_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class KorpaScreen extends StatefulWidget {
  const KorpaScreen({super.key});

  @override
  State<KorpaScreen> createState() => _KorpaScreenState();
}

class _KorpaScreenState extends State<KorpaScreen> {
  RezervacijaCartProvider? _cartProvider;
  late UslugaProvider _uslugaProvider;
  List<Map<String, dynamic>> _usluge = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (AuthProvider.korisnikId != null) {
      _cartProvider = RezervacijaCartProvider(AuthProvider.korisnikId!);
      _uslugaProvider = context.read<UslugaProvider>();
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    if (_cartProvider == null) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      if (!mounted) return;
      final data = await _cartProvider!.getRezervacijaList();
      if (!mounted) return;
      setState(() {
        _usluge = data.values.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } catch (e) {
      if (!mounted) return;
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Greška',
        text: e.toString(),
        confirmBtnText: 'OK',
        confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 244, 247),
      body: AuthProvider.isSignedIn
          ? Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (_usluge.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 25),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.cut,
                                    color: Color.fromARGB(255, 76, 72, 72),
                                    size: 45,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Nemate usluga u korpi za rezervaciju.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _usluge.length,
                            itemBuilder: (context, index) {
                              final usluga = _usluge[index];
                              return _buildUslugaCard(usluga);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                if (!_isLoading && _usluge.isNotEmpty) _buildFooter(),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Za pristup ovom dijelu aplikacije morate biti prijavljeni! ",
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
        boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.15),
          blurRadius: 8, 
          offset: Offset(0, 4), 
        ),
      ],
      ),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible( 
              child: Text(
                "Moja korpa za rezervaciju",
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
              Icons.shopping_bag,
              color: Colors.black,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUslugaCard(Map<String, dynamic> usluga) {
    return Container(
      width: double.infinity,
      height: 145,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Slidable(
        key: ValueKey(usluga['id']),
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async {
                try {
                  if (!mounted) return;
                  await _cartProvider?.removeUsluga(usluga['id']);

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color.fromARGB(255, 138, 182, 140),
                      duration: Duration(milliseconds: 1500),
                      content: Center(
                        child: Text(
                          "Usluga je uklonjena iz korpe.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );

                  if (!mounted) return;
                  await _fetchData();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      duration: const Duration(milliseconds: 1800),
                      content: Center(
                        child: Text(
                          "Nije moguće obrisati uslugu: $e",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }
              },
              backgroundColor: Colors.red,
              icon: Icons.delete,
              label: 'Obriši',
              spacing: 0, 
              padding: EdgeInsets.zero, 
              borderRadius: BorderRadius.zero, 
            ),
          ],
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            try {
              if (!mounted) return;
              final uslugaDetalji = await _uslugaProvider.getById(usluga['id']);
              if (!mounted) return;
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UslugaDetailsScreen(usluga: uslugaDetalji),
                ),
              );
              if (!mounted) return;
              if (result is Map && result['korpa'] == true) {
                await _fetchData();
              }
            } catch (e) {
              if (!mounted) return;
              await QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                title: 'Greška',
                text: e.toString(),
                confirmBtnText: 'OK',
                confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
              );
            }
          },
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 100,
                      height: 140,
                      child: (usluga['slika'] != null && usluga['slika'] is String && usluga['slika'].isNotEmpty)
                          ? FittedBox(
                              fit: BoxFit.cover,
                              child: imageFromString(usluga['slika']),
                            )
                          : Image.asset(
                              "assets/images/praznaUsluga.png",
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        usluga['naziv'] ?? "-",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        usluga['cijena'] != null ? '${formatNumber(usluga['cijena'])} KM' : "-",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 56, 54, 54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        usluga['trajanje'] != null ? '${usluga['trajanje']} min' : "-",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildFooter() {
    return FutureBuilder<double>(
      future: _cartProvider!.izracunajUkupnuCijenu(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final ukupno = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(
                color: Colors.grey,
                thickness: 1,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ukupna cijena:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "${formatNumber(ukupno)} KM",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 50,
                    width: 180,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_usluge.isEmpty) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              duration: Duration(milliseconds: 1500),
                              content: Center(
                                child: Text(
                                  "Korpa je prazna.",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        } else {
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RezervacijaOdabirFrizeraScreen(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 210, 193, 214),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 6,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Rezerviši",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.shopping_bag, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}