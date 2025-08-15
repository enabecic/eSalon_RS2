import 'package:esalon_desktop/models/korisnik.dart';
import 'package:esalon_desktop/providers/korisnik_provider.dart';
import 'package:flutter/material.dart';
import 'package:esalon_desktop/models/rezervacija.dart';
import 'package:esalon_desktop/models/search_result.dart';
import 'package:esalon_desktop/models/stavke_rezervacije.dart';
import 'package:esalon_desktop/providers/rezervacija_provider.dart';
import 'package:esalon_desktop/providers/stavke_rezervacije_provider.dart';
import 'package:esalon_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class FrizerRezervacijeListScreen extends StatefulWidget {
 const FrizerRezervacijeListScreen({super.key});

  @override
  State<FrizerRezervacijeListScreen> createState() =>
      _FrizerRezervacijeListScreenState();
}

class _FrizerRezervacijeListScreenState extends State<FrizerRezervacijeListScreen>
    with SingleTickerProviderStateMixin {
  late RezervacijaProvider rezervacijaProvider;
  late StavkeRezervacijeProvider stavkeRezervacijeProvider;

  SearchResult<StavkeRezervacije>? stavkeRezervacijeResult;
  late TabController _tabController;
  late KorisnikProvider korisnikProvider;
  List<Korisnik> frizeri = [];

  List<Rezervacija> rezervacijeAktivne = [];
  List<Rezervacija> rezervacijeHistorija = [];

  int pageAktivne = 1;
  int pageHistorija = 1;

  bool hasNextPageAktivne = true;
  bool hasNextPageHistorija = true;

  bool isLoadMoreRunningAktivne = false;
  bool isLoadMoreRunningHistorija = false;

  int page = 1;
  final int limit = 50;
  int total = 0;
  bool isFirstLoadRunning = false;
  bool showbtn = false;
  late ScrollController scrollControllerRezervacije= ScrollController();
  late ScrollController scrollControllerHistorija= ScrollController();

  Map<String, dynamic> searchRequest = {};
  DateTime? datumRezervacijeTab1;
  Map<int, bool> hoverMap = {};
  bool isHoveredSifra = false; 
  bool isHoveredDatum = false;
  bool isHoveredDatumGTE = false; 
  bool isHoveredFrizer = false;
  Korisnik? odabraniFrizer;

  @override
  void dispose() {
    scrollControllerRezervacije.dispose();
    scrollControllerHistorija.dispose();

    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    rezervacijaProvider = context.read<RezervacijaProvider>();
    stavkeRezervacijeProvider = context.read<StavkeRezervacijeProvider>();
    korisnikProvider = context.read<KorisnikProvider>();
    _tabController = TabController(length: 2, vsync: this);

    _loadFrizere();
    _firstLoad();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _brojRezervacijeController.clear();
        searchRequest['Sifra'] = null;
        datumGTE = null;
        datumRezervacijeTab1 = null;
        searchRequest['DatumRezervacijeGTE'] = null;
        searchRequest['DatumRezervacije'] = null;
        odabraniFrizer = null;
        searchRequest['FrizerId'] = null;
        showbtn = false;
        _firstLoad();
      }
    });

    void scrollListener() {
      ScrollController activeController = 
          _tabController.index == 0 ? scrollControllerRezervacije : scrollControllerHistorija;

      double showOffset = 10.0;
      showbtn = activeController.offset > showOffset;

      if (!mounted) return;
      setState(() {});

      if (activeController.position.maxScrollExtent ==
          activeController.position.pixels) {
        _loadMore(activeController); 
      }
    }
    scrollControllerRezervacije.addListener(scrollListener);
    scrollControllerHistorija.addListener(scrollListener);

    _initForm();
  }

  Future _initForm() async {
     stavkeRezervacijeResult = await stavkeRezervacijeProvider.get();
     if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadFrizere() async {
    var result = await korisnikProvider.get(); 

    frizeri = result.result
        .where((k) => k.uloge?.contains('Frizer') ?? false)
        .toList();

    if (mounted) setState(() {});
  }

  Future<void> _firstLoad() async {
    if (!mounted) return;

    bool isAktivneTab = _tabController.index == 0;

    setState(() {
      if (isAktivneTab) {
        rezervacijeAktivne = [];
        pageAktivne = 1;
        hasNextPageAktivne = true;
        isLoadMoreRunningAktivne = true;
      } else {
        rezervacijeHistorija = [];
        pageHistorija = 1;
        hasNextPageHistorija = true;
        isLoadMoreRunningHistorija = true;
      }
    });

    searchRequest['stateMachine'] = isAktivneTab
        ? ['kreirana', 'odobrena']
        : ['zavrsena', 'ponistena'];

    var rezervacijaResult = await rezervacijaProvider.get(
      filter: searchRequest,
      page: 1,
      pageSize: 10,
      orderBy: 'DatumRezervacije',
      sortDirection: 'desc',
    );

    if (!mounted) return;

    setState(() {
      if (isAktivneTab) {
        rezervacijeAktivne = rezervacijaResult.result;
        hasNextPageAktivne = rezervacijaResult.result.length >= 10;
        isLoadMoreRunningAktivne = false;
      } else {
        rezervacijeHistorija = rezervacijaResult.result;
        hasNextPageHistorija = rezervacijaResult.result.length >= 10;
        isLoadMoreRunningHistorija = false;
      }
    });
  }

  void _loadMore(ScrollController controller) async {
    bool isAktivneTab = _tabController.index == 0;
    int page = isAktivneTab ? pageAktivne : pageHistorija;
    bool hasNextPage = isAktivneTab ? hasNextPageAktivne : hasNextPageHistorija;
    bool isLoadMoreRunning = isAktivneTab ? isLoadMoreRunningAktivne : isLoadMoreRunningHistorija;

    if (hasNextPage && !isFirstLoadRunning && !isLoadMoreRunning && controller.position.extentAfter < 300) {
      if (isAktivneTab) {
        setState(() => isLoadMoreRunningAktivne = true);
      } else {
        setState(() => isLoadMoreRunningHistorija = true);
      }

      try {
        page += 1;

        searchRequest['stateMachine'] = isAktivneTab
            ? ['kreirana', 'odobrena']
            : ['zavrsena', 'ponistena'];

        var result = await rezervacijaProvider.get(
          filter: searchRequest,
          page: page,
          pageSize: 10,
          orderBy: 'DatumRezervacije',
          sortDirection: 'desc',
        );

        if (result.result.isNotEmpty) {
          if (isAktivneTab) {
            setState(() => rezervacijeAktivne.addAll(result.result));
            pageAktivne = page;
            hasNextPageAktivne = result.result.length >= 10;
          } else {
            setState(() => rezervacijeHistorija.addAll(result.result));
            pageHistorija = page;
            hasNextPageHistorija = result.result.length >= 10;
          }
        } else {
          if (isAktivneTab) {
            setState(() => hasNextPageAktivne = false);
          } else {
            setState(() => hasNextPageHistorija = false);
          }
        }
      } catch (e) {
        print('Greška prilikom učitavanja: $e');
      } finally {
        if (isAktivneTab) {
          setState(() => isLoadMoreRunningAktivne = false);
        } else {
          setState(() => isLoadMoreRunningHistorija = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
          child: Text(
            "Rezervacije",
            style: TextStyle(fontSize: 26, color: Colors.black),
          ),
        ),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey.shade800,
                    labelStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    indicatorColor: Colors.deepPurple,
                    indicatorWeight: 4.0,
                    tabs: const [
                      Tab(text: "Rezervacije"),
                      Tab(text: "Historija rezervacija"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Stack(
                        children: [
                          _buildRezervacije(),
                          if (showbtn)
                            Positioned(
                              bottom: 20,
                              right: 20,
                              child: FloatingActionButton(
                                onPressed: () {
                                  if (scrollControllerRezervacije.hasClients) {
                                    scrollControllerRezervacije.animateTo(
                                      0,
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.fastOutSlowIn,
                                    );
                                  }
                                },
                                backgroundColor: Colors.deepPurple,
                                child: const Icon(Icons.arrow_upward, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      Stack(
                        children: [
                          _buildHistorijaRezervacija(),
                          if (showbtn)
                            Positioned(
                              bottom: 20,
                              right: 20,
                              child: FloatingActionButton(
                                onPressed: () {
                                  if (scrollControllerHistorija.hasClients) {
                                    scrollControllerHistorija.animateTo(
                                      0,
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.fastOutSlowIn,
                                    );
                                  }
                                },
                                backgroundColor: Colors.deepPurple,
                                child: const Icon(Icons.arrow_upward, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  final TextEditingController _brojRezervacijeController = TextEditingController();
  Widget _buildSearchRezervacije() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: MouseRegion(
              onEnter: (_) {
                setState(() {
                  isHoveredSifra = true;
                });
              },
              onExit: (_) {
                setState(() {
                  isHoveredSifra = false;
                });
              },
              child: TextField(
                controller: _brojRezervacijeController,
                onChanged: (value) async {
                  setState(() {
                    searchRequest['Sifra'] = _brojRezervacijeController.text;
                    _loadFiltered();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Sifra rezervacije',
                  hintText: 'Sifra rezervacije',
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 108, 108, 108),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: isHoveredSifra ? const Color(0xFFE0D7F5) : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      isHoveredDatum = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      isHoveredDatum = false;
                    });
                  },
                  child: InkWell(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          datumRezervacijeTab1 = pickedDate;
                          searchRequest['DatumRezervacije'] =
                              pickedDate.toIso8601String().split('T')[0];
                        });
                        _firstLoad();
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Datum rezervacije',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isHoveredDatum ? const Color(0xFFE0D7F5) : Colors.white,
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        datumRezervacijeTab1 != null
                            ? "${datumRezervacijeTab1!.day}.${datumRezervacijeTab1!.month}.${datumRezervacijeTab1!.year}."
                            : "Odaberi datum",
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      isHoveredFrizer = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      isHoveredFrizer = false;
                    });
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Frizer',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isHoveredFrizer ? const Color(0xFFE0D7F5) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Korisnik>(
                        isExpanded: true,
                        hint: const Text('Odaberite frizera'),
                        value: odabraniFrizer,
                        items: frizeri.map((f) {
                          return DropdownMenuItem<Korisnik>(
                            value: f,
                            child: Text("${f.ime} ${f.prezime}"),
                          );
                        }).toList(),
                        onChanged: (selectedFrizer) {
                          setState(() {
                            odabraniFrizer = selectedFrizer;
                            searchRequest['FrizerId'] = selectedFrizer?.korisnikId;
                          });
                          _loadFiltered(); 
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(150, 59),
                ),
                onPressed: () {
                  setState(() {
                    datumRezervacijeTab1 = null;
                    _brojRezervacijeController.clear();
                    searchRequest['DatumRezervacije'] = null;
                    searchRequest['Sifra'] = null;
                    odabraniFrizer = null;
                    searchRequest['FrizerId'] = null;
                  });
                  _firstLoad();
                },
                child: const Text('Očisti filtere'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRezervacije() {
    return SingleChildScrollView(
      controller: scrollControllerRezervacije,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildSearchRezervacije(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(97, 158, 158, 158),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Broj aktivnih rezervacija: ${rezervacijeAktivne.where((e) => e.stateMachine == "kreirana" || e.stateMachine == "odobrena").length}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...rezervacijeAktivne.asMap().entries.map((entry) {
            int index = entry.key;
            var e = entry.value;

            bool isHovered = hoverMap[index] ?? false;

            return MouseRegion(
              onEnter: (_) {
                setState(() {
                  hoverMap[index] = true;
                });
              },
              onExit: (_) {
                setState(() {
                  hoverMap[index] = false;
                });
              },
              child: InkWell(
                onTap: () {
                  print("Radi onTap za prikaz detalja rezervacije!");
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isHovered ? const Color(0xFFE0D7F5) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rezervacija #${e.sifra}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (e.stateMachine == "kreirana")
                        Text(
                          "Rezervacija #${e.sifra} još uvijek nije odobrena od strane frizera.",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      if (e.stateMachine == "odobrena")
                        Text(
                          "Rezervacija #${e.sifra} je odobrena od strane frizera.",
                          style:  TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      Text(
                        "Datum rezervacije: ${formatDate(e.datumRezervacije.toString())}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        "Frizer: ${e.frizerImePrezime}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        stavkeRezervacijeResult?.result
                                .where((stavka) => stavka.rezervacijaId == e.rezervacijaId)
                                .map((stavka) => stavka.uslugaNaziv ?? 'Nepoznato')
                                .join(", ") ??
                            'Nema stavki',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Divider(
                        color: Colors.deepPurple,
                        thickness: 1,
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "${stavkeRezervacijeResult?.result.where((stavka) => stavka.rezervacijaId == e.rezervacijaId).length ?? 0} usluga/e",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              "Ukupan iznos: ${formatNumber(e.ukupnaCijena)} KM",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          if (hasNextPageAktivne) const CircularProgressIndicator(),
          if (!hasNextPageAktivne)
            Container(
              width: 350,
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
                  "Nema više aktivnih rezervacija za prikazati.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _loadFiltered() async {
    if (!mounted) return;
      setState(() {
        isLoadMoreRunningAktivne = true;
      });
      searchRequest['stateMachine'] = ['kreirana', 'odobrena'];
      var result = await rezervacijaProvider.get(
        filter: searchRequest,
        pageSize: limit,
        page: 1,
      );
      if (result.result.isNotEmpty) {
        rezervacijeAktivne = result.result;
        hasNextPageAktivne = result.result.length >= limit; 
      } else {
        rezervacijeAktivne = [];
        hasNextPageAktivne = false;
      }
      if (!mounted) return;
      setState(() {
        isLoadMoreRunningAktivne = false;
      });
    }

  Widget _buildHistorijaRezervacija() {
    return SingleChildScrollView(
      controller: scrollControllerHistorija,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildSearchHistorije(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(97, 158, 158, 158),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Broj završenih rezervacija: ${rezervacijeHistorija.where((e) => e.stateMachine == "zavrsena").length}\n"
              "Broj otkazanih rezervacija: ${rezervacijeHistorija.where((e) => e.stateMachine == "ponistena").length}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...rezervacijeHistorija.asMap().entries.map((entry) {
            int index = entry.key;
            var e = entry.value;
            bool isHovered = hoverMap[index] ?? false;
            return MouseRegion(
              onEnter: (_) {
                setState(() {
                  hoverMap[index] = true;
                });
              },
              onExit: (_) {
                setState(() {
                  hoverMap[index] = false;
                });
              },
              child: InkWell(
                onTap: () {
                  print("Radi onTap klik za detalje!");
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isHovered ? const Color(0xFFE0D7F5) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rezervacija #${e.sifra}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Status rezervacije: ${e.stateMachine}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        "Datum rezervacije: ${formatDate(e.datumRezervacije.toString())}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        "Frizer: ${e.frizerImePrezime}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        stavkeRezervacijeResult != null && stavkeRezervacijeResult!.result.isNotEmpty
                            ? stavkeRezervacijeResult!.result
                                .where((stavka) => stavka.rezervacijaId == e.rezervacijaId)
                                .map((stavka) => stavka.uslugaNaziv ?? "Nepoznata usluga")
                                .join(", ")
                            : "Nema stavki",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Divider(
                        color: Colors.deepPurple,
                        thickness: 1,
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "${stavkeRezervacijeResult?.result.where((stavka) => stavka.rezervacijaId == e.rezervacijaId).length ?? 0} usluga/e",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              "Ukupan iznos: ${formatNumber(e.ukupnaCijena)} KM",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          if (hasNextPageHistorija) const CircularProgressIndicator(),
          if (!hasNextPageHistorija)
            Container(
              width: 350,
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
                  "Nema više rezervacija za prikazati.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  DateTime? datumGTE;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: datumGTE ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        datumGTE = picked;
      });
      _loadFilteredHistorija();
    }
  }

  Widget _buildSearchHistorije() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      isHoveredDatumGTE = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      isHoveredDatumGTE = false;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: datumGTE == null
                                ? "Izaberite datum"
                                : "Izabrani datum: ${formatDate(datumGTE.toString())}",
                            prefixIcon: const Icon(Icons.calendar_today),
                            labelText: 'Rezervacije poslije',
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 108, 108, 108),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: isHoveredDatumGTE ? const Color(0xFFE0D7F5) : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9),
                width: 250,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.deepPurple,
                ),
                child: InkWell(
                  onTap: () async {
                    datumGTE = null;
                    searchRequest['DatumRezervacijeGTE'] = null;
                    _firstLoad();
                    setState(() {});
                  },
                  child:const Center(
                    child: Text(
                      "Očisti filter",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _loadFilteredHistorija() async {
    if (!mounted) return;
    setState(() {
      isLoadMoreRunningHistorija = true;
      page = 1;                 
      rezervacijeHistorija = [];       
      hasNextPageHistorija = true;         
    });
    searchRequest['stateMachine'] = ['zavrsena', 'ponistena'];

    DateTime datumGte = datumGTE ?? DateTime.now();
    searchRequest['DatumRezervacijeGTE'] =
        datumGte.toIso8601String().split('T')[0];
    // if (!mounted) return;
    // setState(() {});
    scrollControllerHistorija.jumpTo(0); 

    var result = await rezervacijaProvider.get(
      filter: searchRequest,
      pageSize: limit,
      page: 1,
      orderBy: 'DatumRezervacije', 
      sortDirection: 'asc',
    );

    if (result.result.isNotEmpty) {
      rezervacijeHistorija = result.result;
       hasNextPageHistorija = result.result.length >= limit; 
    } else {
      rezervacijeHistorija = [];
      hasNextPageHistorija = false;
    }
    if (!mounted) return;
    setState(() {
      isLoadMoreRunningHistorija = false;
    });
  }

}