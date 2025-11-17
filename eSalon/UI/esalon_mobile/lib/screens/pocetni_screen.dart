import 'package:esalon_mobile/main.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/screens/usluga_details_screen.dart';
import 'package:esalon_mobile/screens/usluge_filter_screen.dart';
import 'package:flutter/material.dart';
import 'package:esalon_mobile/models/ocjena.dart';
import 'package:esalon_mobile/models/usluga.dart';
import 'package:esalon_mobile/models/favorit.dart';
import 'package:esalon_mobile/models/search_result.dart';
import 'package:esalon_mobile/models/vrsta_usluge.dart';
import 'package:esalon_mobile/providers/ocjena_provider.dart';
import 'package:esalon_mobile/providers/favorit_provider.dart';
import 'package:esalon_mobile/providers/usluga_provider.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:esalon_mobile/providers/vrsta_usluge_provider.dart';
import 'package:provider/provider.dart';

class PocetniScreen extends StatefulWidget {
  const PocetniScreen({super.key});

  @override
  State<PocetniScreen> createState() => _PocetniScreenState();
}

class _PocetniScreenState extends State<PocetniScreen> {
  late UslugaProvider uslugaProvider;
  late VrstaUslugeProvider vrstaUslugeProvider;
  late OcjenaProvider ocjenaProvider;
  late FavoritProvider favoritProvider;

  SearchResult<Usluga>? uslugaResult;
  SearchResult<VrstaUsluge>? vrstaUslugeResult;
  SearchResult<Ocjena>? ocjenaResult;
  SearchResult<Favorit>? favoritResult;

  bool isFavorit = false;

  List<Usluga> uslugaList = [];
  int page = 1;

  final int limit = 20;
  int total = 0;

  bool showbtn = false;
  bool _isLoading = true;

  late ScrollController scrollController = ScrollController();

  final Map<String, Widget> _cachedImages = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    uslugaProvider = context.read<UslugaProvider>();
    vrstaUslugeProvider = context.read<VrstaUslugeProvider>();
    ocjenaProvider = context.read<OcjenaProvider>();
    favoritProvider = context.read<FavoritProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });

    scrollController.addListener(() {
      double showoffset = 10.0;

      if (scrollController.offset > showoffset) {
        showbtn = true;
        if (!mounted) return;
        setState(() {});
      } else {
        showbtn = false;
        if (!mounted) return;
        setState(() {});
      }
    });
    _initForm();
  }

  Future _initForm() async {
    try {
      if (!mounted) return;
      var vrste = await vrstaUslugeProvider.get();
      if (!mounted) return;
      var ocjene = await ocjenaProvider.get();
      SearchResult<Favorit>? favoriti;

      if (AuthProvider.isSignedIn) {
        if (!mounted) return;
        favoriti = await favoritProvider.get();
      }
      if (!mounted) return;
      setState(() {
        vrstaUslugeResult = vrste as SearchResult<VrstaUsluge>?;
        ocjenaResult = ocjene;
        favoritResult = AuthProvider.isSignedIn ? favoriti : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        vrstaUslugeResult = null;
        ocjenaResult = null;
        favoritResult = null;
      });
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      if (!mounted) return;
      var vrste = await vrstaUslugeProvider.get();
      if (!mounted) return;
      var ocjene = await ocjenaProvider.get();
      SearchResult<Favorit>? favoriti;
      if (AuthProvider.isSignedIn) {
        if (!mounted) return;
        favoriti = await favoritProvider.get();
      }
      if (!mounted) return;
      var uslugaResult = await uslugaProvider.get(
        page: 1,
        pageSize: 10,
        filter: {'BrojZadnjeDodanih': 10},
      );

      if (!mounted) return;
      setState(() {
        vrstaUslugeResult = vrste as SearchResult<VrstaUsluge>?;
        ocjenaResult = ocjene;
        favoritResult = AuthProvider.isSignedIn ? favoriti : null;
        uslugaList = uslugaResult.result;
        total = uslugaResult.count;

        _isLoading = false; 
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 244, 247),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),//8
                    child: _buildHeader(),
                  ),
                  _buildVrste(),
                  _buildPage(),
                ],
              ),
            ),
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 1000),
        opacity: showbtn ? 1.0 : 0.0,
        child: FloatingActionButton(
          onPressed: () {
            scrollController.animateTo(0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn);
          },
          backgroundColor: const Color.fromARGB(255, 210, 193, 214),
          child: const Icon(
            Icons.arrow_upward,
            color: Colors.white,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "Brzo i jednostavno rezervišite svoj termin",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.event_available,
                color: Colors.black,
                size: constraints.maxWidth * 0.12, 
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVrste() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //const SizedBox(height: 30),
          const Padding(
            padding:  EdgeInsets.symmetric(horizontal: 7), 
            child:  Text(
              "Vrste usluga",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),

          if (vrstaUslugeResult == null)
            const Center(child: CircularProgressIndicator())

          else if (vrstaUslugeResult!.result.isEmpty)
            const Text("Nema dostupnih vrsta usluga.")
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UslugeFilterScreen(),
                          ),
                        );

                        if (result == true) {
                          _loadInitialData();
                        }
                      },
                      child: Container(
                        width: 115,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      child: SizedBox(
                          width: 15,
                          height: 15,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 95, 
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    "assets/images/menu.png",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const Text("Sve usluge", textAlign: TextAlign.center, 
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        )
                      ),
                    ),
                  ),
                  ...vrstaUslugeResult!.result.map((vrsta) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                      child: GestureDetector( 
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UslugeFilterScreen(
                                vrstaId: vrsta.vrstaId,
                                vrstaNaziv: vrsta.naziv,
                              ),
                            ),
                          );

                          if (result == true) {
                            _loadInitialData(); 
                          }
                        },    
                        child: Container(
                          width: 115,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: 
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 70,
                                    child: vrsta.slika != null && vrsta.slika!.isNotEmpty
                                        ? FittedBox(
                                            fit: BoxFit.cover,
                                            clipBehavior: Clip.hardEdge,
                                            child: (_cachedImages[vrsta.slika!] ??= imageFromString(vrsta.slika!)),
                                          )
                                        : Image.asset(
                                            "assets/images/praznaVrstaUsluge.png",
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 70,
                                          ),
                                  ),
                                )
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: Text(
                                  vrsta.naziv ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    if (uslugaList.isEmpty) {
      return Center(
        child: Container(
          width: 250,
          decoration: BoxDecoration(
            color: const Color.fromARGB(97, 158, 158, 158),
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
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Nema usluga za prikazati.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Najnovije usluge",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: uslugaList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.70,
              ),

              itemBuilder: (context, index) {
                var e = uslugaList[index];
                return GestureDetector(
                  onTap: () async {
                    try {
                      final uslugaDetalji =
                        await uslugaProvider.getById(e.uslugaId!);
                      if (!context.mounted) return;
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                            UslugaDetailsScreen(usluga: uslugaDetalji),
                        ),
                      );

                      if (result == true) {
                        _loadInitialData();
                      }
                    }catch (e) {
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 120,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: e.slika != null && e.slika!.isNotEmpty
                                      ? FittedBox(
                                          fit: BoxFit.fill,
                                          clipBehavior: Clip.hardEdge,
                                          child: (_cachedImages[e.slika!] ??=
                                              imageFromString(e.slika!)),
                                        )
                                      : Image.asset(
                                          "assets/images/praznaUsluga.png",
                                          fit: BoxFit.fill,
                                          width: double.infinity,
                                          height: 100,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                e.naziv ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${formatNumber(e.cijena)} KM",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 108, 108, 108),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.yellow, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    _avgOcjena(e.uslugaId).toString(),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 108, 108, 108),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                child: (favoritResult != null &&
                                        favoritResult!.result.any(
                                          (f) =>
                                              f.korisnikId == AuthProvider.korisnikId &&
                                              f.uslugaId == e.uslugaId,
                                        ))
                                    ? const Icon(Icons.favorite, color: Colors.red)
                                    : const Icon(Icons.favorite_border),
                                onTap: () async {
                                  if (AuthProvider.korisnikId == null) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        duration:
                                            const Duration(milliseconds: 1500),
                                        content: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginPage()),
                                            );
                                          },
                                          child: RichText(
                                            text: const TextSpan(
                                              text:
                                                  "Morate biti prijavljeni da biste dodali uslugu u favorite. ",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                              children: [
                                                TextSpan(
                                                  text: "Prijavite se!",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    decoration:
                                                        TextDecoration.underline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  try {
                                    bool isFavorite = favoritResult!.result.any(
                                      (f) =>
                                          f.korisnikId ==
                                              AuthProvider.korisnikId &&
                                          f.uslugaId == e.uslugaId,
                                    );

                                    if (!isFavorite) {
                                      if (!mounted) return;
                                      await favoritProvider.insert({
                                        'korisnikId': AuthProvider.korisnikId,
                                        'uslugaId': e.uslugaId
                                      });
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          backgroundColor:
                                              Color.fromARGB(255, 138, 182, 140),
                                          duration:
                                              Duration(milliseconds: 1500),
                                          content: Center(
                                            child: Text(
                                              "Uspješno dodano u favorite.",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      var favRest = favoritResult!.result
                                          .firstWhere((f) =>
                                              f.korisnikId ==
                                                  AuthProvider.korisnikId &&
                                              f.uslugaId == e.uslugaId);
                                      if (!mounted) return;
                                      await favoritProvider
                                          .delete(favRest.favoritId!);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          backgroundColor:
                                              Color.fromARGB(255, 138, 182, 140),
                                          duration:
                                              Duration(milliseconds: 1500),
                                          content: Center(
                                            child: Text(
                                              "Uspješno izbačeno iz favorita.",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    if (!mounted) return;
                                    favoritResult = await favoritProvider.get();
                                    if (!mounted) return;
                                    setState(() {});
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
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
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
}
