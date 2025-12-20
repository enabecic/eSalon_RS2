import 'package:esalon_mobile/main.dart';
import 'package:esalon_mobile/models/arhiva.dart';
import 'package:esalon_mobile/models/favorit.dart';
import 'package:esalon_mobile/models/ocjena.dart';
import 'package:esalon_mobile/models/search_result.dart';
import 'package:esalon_mobile/providers/arhiva_provider.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/favorit_provider.dart';
import 'package:esalon_mobile/providers/ocjena_provider.dart';
import 'package:esalon_mobile/providers/rezervacija_cart_provider.dart';
import 'package:esalon_mobile/screens/recenzije_screen.dart';
import 'package:flutter/material.dart';
import 'package:esalon_mobile/models/usluga.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class UslugaDetailsScreen extends StatefulWidget {
  final Usluga usluga;

  const UslugaDetailsScreen({super.key, required this.usluga});

  @override
  State<UslugaDetailsScreen> createState() => _UslugaDetailsScreenState();
}

class _UslugaDetailsScreenState extends State<UslugaDetailsScreen> {
  late String naziv;
  late String opis;
  late double cijena;
  late int trajanje;
  late String? datumObjavljivanja;
  late String? vrstaUsluge;
  String? slika;
  bool _isLoadingFavorite = true;
  bool _isLoadingArhiva = true;
  bool _isLoadingOcjena = true;

  late ArhivaProvider arhivaProvider;
  SearchResult<Arhiva>? arhivaResult;
  
  int brojArhiviranja = 0; 

  late OcjenaProvider ocjenaProvider;
  late FavoritProvider favoritProvider;

  SearchResult<Ocjena>? ocjenaResult;
  SearchResult<Favorit>? favoritResult;

  Image? _cachedImage;
  bool _changed = false;

  int _mojaOcjena = 0; 
  bool _isLoadingOcjenaUser = true; 

  RezervacijaCartProvider? _cartProvider;
  bool _isLoadingKorpa = false;
  bool _isInKorpa = false;

  @override
  void initState() {
    super.initState();
    naziv = widget.usluga.naziv ?? "/";
    opis = widget.usluga.opis ?? "/";
    cijena = widget.usluga.cijena ?? 0;
    trajanje = widget.usluga.trajanje ?? 0;
    datumObjavljivanja = widget.usluga.datumObjavljivanja;
    vrstaUsluge = widget.usluga.vrstaUslugeNaziv;
    slika = widget.usluga.slika;

    if (slika != null && slika!.isNotEmpty) {
      try {
        _cachedImage = imageFromString(slika!);
      } catch (_) {
        _cachedImage = null;
      }
    }

    ocjenaProvider = context.read<OcjenaProvider>();
    favoritProvider = context.read<FavoritProvider>();
    arhivaProvider = context.read<ArhivaProvider>();

    if (AuthProvider.korisnikId != null) {
      _cartProvider = RezervacijaCartProvider(AuthProvider.korisnikId!);
      _checkIfInRezervacija();
    } 

    _loadData();
    _loadOcjena();
    _loadUserOcjena();
    _loadArhivaResult();
  }

  Future<void> _loadData() async {
    try {
      if (!mounted) return;

      SearchResult<Favorit>? favoriti;
      if (AuthProvider.korisnikId != null) {
        if (!mounted) return;
        favoriti = await favoritProvider.get(filter: {
          "KorisnikId": AuthProvider.korisnikId,
          "UslugaId": widget.usluga.uslugaId
        });
      }

      if (!mounted) return;
      setState(() {
        favoritResult = favoriti; 
        _isLoadingFavorite = false;  
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingFavorite = false;
      });
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
  }

  Future<void> _loadOcjena() async {
    try {
      if (!mounted) return;
      final ocjene = await ocjenaProvider.get();
      if (!mounted) return;
      setState(() {
        ocjenaResult = ocjene; 
        _isLoadingOcjena = false;  
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingOcjena = false;
      });
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
  }

  Future<void> _loadArhivaResult() async {
    if (AuthProvider.korisnikId == null) {
      if (!mounted) return;
      setState(() {
        _isLoadingArhiva = false;
      });
      return;
    }
    try {
      if (!mounted) return;
      arhivaResult = await arhivaProvider.get(filter: {
          "KorisnikId": AuthProvider.korisnikId,
          "UslugaId": widget.usluga.uslugaId
        });
      if (!mounted) return;
      int broj = await arhivaProvider.getBrojArhiviranja(widget.usluga.uslugaId!);

      if (!mounted) return;
      setState(() {
        brojArhiviranja = broj;
        _isLoadingArhiva = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingArhiva = false;
        brojArhiviranja = 0;
        arhivaResult = null;
      });
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
  }

  Future<void> _loadUserOcjena() async {
    if (AuthProvider.korisnikId == null) {
      if (!mounted) return;
      setState(() {
        _isLoadingOcjenaUser = false;
      });
      return;
    }

    try {
      if (!mounted) return;
      final result = await ocjenaProvider.get(filter: {
        'KorisnikId': AuthProvider.korisnikId,
        'UslugaId': widget.usluga.uslugaId,
      });

      if (!mounted) return;

      if (result.result.isNotEmpty) {
        _mojaOcjena = result.result.first.vrijednost ?? 0;
      }
      if (!mounted) return;
      setState(() {
        _isLoadingOcjenaUser = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingOcjenaUser = false;
      });
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
  }

  Future<void> _checkIfInRezervacija() async {
    if (_cartProvider == null) return;
    if (!mounted) return;
    final inRezervacija =
      await _cartProvider!.isInRezervacija(widget.usluga.uslugaId!);
    if (!mounted) return;
    setState(() => _isInKorpa = inRezervacija);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 244, 247),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 25),
          child: AppBar(
            elevation: 0,
            backgroundColor: const Color.fromARGB(255, 247, 244, 247),
            automaticallyImplyLeading: false,
            toolbarHeight: kToolbarHeight + 25,
            surfaceTintColor: Colors.transparent,
            forceMaterialTransparency: false,
            title: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 40,
                      ),
                      onPressed: () {
                        Navigator.pop(context, _changed);
                      },
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "eSalon",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 35,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        "assets/images/logo.png",
                        height: 55,
                        width: 55,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeaderInfo(), 
                    const SizedBox(height: 20),
                    _buildDetails(),   
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(), 
              _buildOcijeni(),
            ],
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
        boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15), 
          blurRadius: 8, 
          offset: const Offset(0, 4), 
        ),
      ],
      ),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible( 
              child: Text(
                "Detalji usluge",
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
              Icons.content_cut,
              color: Colors.black,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(slika), 
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    naziv,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vrstaUsluge ?? "Nepoznata vrsta",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, color: Colors.black),
            const SizedBox(width: 6),
            Text(
              "Trajanje: $trajanje min",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.attach_money, color: Colors.black),
            const SizedBox(width: 6),
            Text(
              "Cijena: ${cijena.toStringAsFixed(2)} KM",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "O usluzi:",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          opis,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.yellow, size: 18),
                const SizedBox(width: 6),
                _isLoadingOcjena
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _avgOcjena(widget.usluga.uslugaId).toString(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    )
              ],
            ),
            const Spacer(),
            StatefulBuilder(
              builder: (context, setLocalState) {
                bool isFavorite = !_isLoadingFavorite &&
                favoritResult != null &&
                favoritResult!.result.any(
                  (f) =>
                      f.korisnikId == AuthProvider.korisnikId &&
                      f.uslugaId == widget.usluga.uslugaId,
                );
                return InkWell(
                 onTap: _isLoadingFavorite ? null : () async {
                  if (AuthProvider.korisnikId == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        duration: const Duration(milliseconds: 1500),
                        content: Center( 
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
                            },
                            child: RichText(
                              textAlign: TextAlign.center, 
                              text: const TextSpan(
                                text: "Morate biti prijavljeni da biste dodali uslugu u favorite. ",
                                style: TextStyle(color: Colors.white, fontSize: 15),
                                children: [
                                  TextSpan(
                                    text: "Prijavite se!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                    return;
                  }
                    try {
                      if (!isFavorite) {
                        if (!mounted) return;
                        await favoritProvider.insert({
                          'korisnikId': AuthProvider.korisnikId,
                          'uslugaId': widget.usluga.uslugaId
                        });
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color.fromARGB(255, 138, 182, 140),
                            duration: Duration(milliseconds: 1500),
                            content: Center(child: Text("Uspješno dodano u favorite.")),
                          ),
                        );
                      } else {
                        var favRest = favoritResult!.result.firstWhere(
                          (f) =>
                              f.korisnikId == AuthProvider.korisnikId &&
                              f.uslugaId == widget.usluga.uslugaId,
                        );
                        if (!mounted) return;
                        await favoritProvider.delete(favRest.favoritId!);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color.fromARGB(255, 138, 182, 140),
                            duration: Duration(milliseconds: 1500),
                            content: Center(child: Text("Uspješno izbačeno iz favorita.")),
                          ),
                        );
                      }
                      if (!mounted) return;
                      setState(() {
                        _changed = true;
                      });
                      if (!mounted) return;
                       favoritResult = await favoritProvider.get(filter: {
                        "KorisnikId": AuthProvider.korisnikId,
                        "UslugaId": widget.usluga.uslugaId
                      });
                      setLocalState(() {});
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          duration: const Duration(milliseconds: 1800),
                          content: Center(
                            child: Text(
                              e.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: _isLoadingFavorite
                  ? const Icon(Icons.favorite, color: Colors.grey, size: 28,) 
                  : Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.black,
                      size: 28,
                    ),
                );
              },
            ),

          ],
        )
      ],
    );
  }

  Future<void> _spasiOcjenu(int vrijednost) async {
    if (AuthProvider.korisnikId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 1500),
          content: Center( 
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: RichText(
                textAlign: TextAlign.center, 
                text: const TextSpan(
                  text: "Morate biti prijavljeni da biste ocijenili uslugu. ",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  children: [
                    TextSpan(
                      text: "Prijavite se!",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _isLoadingOcjenaUser = true;
    });

    try {
      if (!mounted) return;
      final postojeca = await ocjenaProvider.get(filter: {
        'KorisnikId': AuthProvider.korisnikId,
        'UslugaId': widget.usluga.uslugaId,
      });

      if (!mounted) return;
      if (postojeca.result.isEmpty) {
        if (!mounted) return;
        await ocjenaProvider.insert({
          'korisnikId': AuthProvider.korisnikId,
          'uslugaId': widget.usluga.uslugaId,
          'vrijednost': vrijednost,
        });
      } else {
        if (!mounted) return;
        await ocjenaProvider.update(postojeca.result.first.ocjenaId!, {
          'vrijednost': vrijednost,
        });
      }
      if (!mounted) return;
      setState(() {
        _mojaOcjena = vrijednost;
        _isLoadingOcjenaUser = false;
        _changed = true;
      });
      if (!mounted) return;
      await _loadOcjena(); 
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromARGB(255, 138, 182, 140),
          duration: Duration(milliseconds: 1500),
          content: Center(child: Text("Ocjena je uspješno spremljena.")),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingOcjenaUser = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "$e",
              textAlign: TextAlign.center,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  dynamic _avgOcjena(int? uslugaId) {
    if (ocjenaResult == null) {
      return 0;
    }
    var ocjena = ocjenaResult!.result
        .where((e) => e.uslugaId == uslugaId)
        .toList();
    if (ocjena.isEmpty) {
      return 0;
    }
    double avgOcjena = ocjena.map((e) => e.vrijednost ?? 0).reduce((a, b) => a + b) /
            ocjena.length;
    return formatNumber(avgOcjena);
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
          onPressed: (_isLoadingKorpa || _isInKorpa)
            ? null
            : (AuthProvider.korisnikId == null
              ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    duration: const Duration(milliseconds: 1500),
                    content: Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            text: "Morate biti prijavljeni da biste dodali uslugu u rezervaciju. ",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                            children: [
                              TextSpan(
                                text: "Prijavite se!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            : () async {
                try {
                  if (!mounted) return;
                  setState(() => _isLoadingKorpa = true);
                  if (!_isInKorpa) {
                    if (!mounted) return;
                    await _cartProvider!.addToRezervacijaList(widget.usluga);
                    if (!mounted) return;
                    setState(() => _isInKorpa = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color.fromARGB(255, 138, 182, 140),
                        duration: Duration(milliseconds: 1500),
                        content: Center(child: Text("Uspješno dodano u korpu za rezervaciju.")),
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      duration: const Duration(milliseconds: 1800),
                      content: Center(
                        child: Text(
                          e.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                } finally {
                  if (mounted) setState(() => _isLoadingKorpa = false);
                }
              }),
            icon: _isLoadingKorpa
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(_isInKorpa ? Icons.shopping_bag : Icons.shopping_bag_outlined, color: Colors.black),
             label: _isLoadingKorpa
              ? const Text("Učitavanje...", style: TextStyle(color: Colors.black))
              : Text(
                  _isInKorpa ? "Već u rezervaciji" : "Dodaj u rezervaciju",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (_isInKorpa) return const Color.fromARGB(255, 210, 193, 214); 
                if (states.contains(MaterialState.pressed)) return const Color.fromARGB(255, 210, 193, 214); 
                return const Color.fromARGB(255, 210, 193, 214); 
              }),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: StatefulBuilder(
                  builder: (context, setLocalState) {
                    bool inArhiva = !_isLoadingArhiva &&
                        arhivaResult != null &&
                        arhivaResult!.result.any(
                          (a) =>
                              a.korisnikId == AuthProvider.korisnikId &&
                              a.uslugaId == widget.usluga.uslugaId,
                        );

                    return ElevatedButton(
                      onPressed: _isLoadingArhiva ? null : () async {
                        if (!mounted) return;
                        await _handleArhivaAction(inArhiva, setLocalState, context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 210, 209, 210),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              " ‘Želim probati’  ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            _isLoadingArhiva
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Text(
                                        brojArhiviranja.toString(),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Icon(
                                        inArhiva ? Icons.bookmark : Icons.bookmark_outline,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecenzijeScreen(
                          uslugaId: widget.usluga.uslugaId!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 210, 209, 210),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Pročitaj recenzije",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.rate_review_outlined, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildOcijeni() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          _mojaOcjena > 0 ? "Vaša ocjena" : "Ocijenite uslugu",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        _isLoadingOcjenaUser
            ? const CircularProgressIndicator()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final index = i + 1;
                  final isActive = index <= _mojaOcjena;
                  return GestureDetector(
                    onTap: () => _spasiOcjenu(index),
                    child: Icon(
                      Icons.star,
                      color: isActive ? Colors.yellow : Colors.grey,
                      size: 32,
                    ),
                  );
                }),
              ),
      ],
    );
  }

  Future<void> _handleArhivaAction(
    bool inArhiva,
    StateSetter setLocalState,
    BuildContext context,
  ) async {
    if (AuthProvider.korisnikId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 1500),
          content: Center( 
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: RichText(
                textAlign: TextAlign.center, 
                text: const TextSpan(
                  text: "Morate biti prijavljeni da biste dodali uslugu u listu 'Želim probati'. ",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  children: [
                    TextSpan(
                      text: "Prijavite se!",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      return;
    }

    try {
      if (!inArhiva) {
        if (!mounted) return;
        await arhivaProvider.insert({
          'korisnikId': AuthProvider.korisnikId,
          'uslugaId': widget.usluga.uslugaId,
        });
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color.fromARGB(255, 138, 182, 140),
            duration: Duration(milliseconds: 1500),
            content: Center(child: Text("Uspješno dodano u listu 'Želim probati'.")),
          ),
        );
      } else {
        var arh = arhivaResult!.result.firstWhere(
          (a) =>
              a.korisnikId == AuthProvider.korisnikId &&
              a.uslugaId == widget.usluga.uslugaId,
        );
        if (!mounted) return;
        await arhivaProvider.delete(arh.arhivaId!);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color.fromARGB(255, 138, 182, 140),
            duration: Duration(milliseconds: 1500),
            content: Center(child: Text("Uspješno izbačeno iz liste 'Želim probati'.")),
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        _changed = true;
      });
      if (!mounted) return;
      arhivaResult = await arhivaProvider.get(filter: {
          "KorisnikId": AuthProvider.korisnikId,
          "UslugaId": widget.usluga.uslugaId
        });
      if (!mounted) return;
      int broj = await arhivaProvider.getBrojArhiviranja(widget.usluga.uslugaId!);
      if (!mounted) return;
      setState(() {
        brojArhiviranja = broj;
        _changed = true;
      });

      setLocalState(() {}); 
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 1800),
          content: Center(
            child: Text(
              e.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildImage(String? slikaBase64) {
    const double imageHeight = 160;
    const double imageWidth = 130;
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(8));

    Widget imageWidget;

    if (_cachedImage != null) {
      imageWidget = FittedBox(
        fit: BoxFit.cover,
        child: _cachedImage!,
      );
    } else if (slikaBase64 == null || slikaBase64.isEmpty) {
      imageWidget = Image.asset(
        "assets/images/praznaUsluga.png",
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = const Icon(Icons.broken_image, size: 100);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: imageHeight,
        width: imageWidth,
        child: imageWidget,
      ),
    );
  }

}

