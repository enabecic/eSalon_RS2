import 'package:esalon_desktop/models/korisnik.dart';
import 'package:esalon_desktop/providers/auth_provider.dart';
import 'package:esalon_desktop/providers/korisnik_provider.dart';
import 'package:esalon_desktop/screens/detalji_rezervacije_screen.dart';
import 'package:flutter/material.dart';
import 'package:esalon_desktop/models/rezervacija.dart';
import 'package:esalon_desktop/models/search_result.dart';
import 'package:esalon_desktop/models/stavke_rezervacije.dart';
import 'package:esalon_desktop/providers/rezervacija_provider.dart';
import 'package:esalon_desktop/providers/stavke_rezervacije_provider.dart';
import 'package:esalon_desktop/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

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

  int _lastActiveTab = 0;
  double _lastScrollOffsetAktivne = 0;
  double _lastScrollOffsetHistorija = 0;

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

  Future<void> _initForm() async {
    if (!mounted) return;
    if (AuthProvider.korisnikId == null) return; 

    try {
      stavkeRezervacijeResult = await stavkeRezervacijeProvider.get();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Greška",
        text: e.toString(),
        confirmBtnText: 'OK',
        confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
        textColor: Colors.black,
        titleColor: Colors.black,
      );
    }
  }

  Future<void> _loadFrizere() async {
    if (!mounted) return;
    if (AuthProvider.korisnikId == null) return; 
    try {
      var result = await korisnikProvider.get();

      frizeri = result.result
          .where((k) => 
              (k.uloge?.contains('Frizer') ?? false) && 
              (k.jeAktivan ?? false))
          .toList();

      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Greška",
        text: e.toString(),
        confirmBtnText: 'OK',
        confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
        textColor: Colors.black,
        titleColor: Colors.black,
      );
    }
  }

  Future<void> _firstLoad() async {
    if (!mounted) return;
    if (AuthProvider.korisnikId == null) return; 

    try {
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
    } catch (e) {
      if (!mounted) return;
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Greška",
        text: e.toString(),
        confirmBtnText: 'OK',
        confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
        textColor: Colors.black,
        titleColor: Colors.black,
      );
    }
  }

  void _loadMore(ScrollController controller) async {
    bool isAktivneTab = _tabController.index == 0;
    int page = isAktivneTab ? pageAktivne : pageHistorija;
    bool hasNextPage = isAktivneTab ? hasNextPageAktivne : hasNextPageHistorija;
    bool isLoadMoreRunning = isAktivneTab ? isLoadMoreRunningAktivne : isLoadMoreRunningHistorija;

    if (hasNextPage && !isFirstLoadRunning && !isLoadMoreRunning && controller.position.extentAfter < 300) {
       if (!mounted) return; 
      if (isAktivneTab) {
        if (!mounted) return;
        setState(() => isLoadMoreRunningAktivne = true);
      } else {
        if (!mounted) return;
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
        if (!mounted) return; 
        if (result.result.isNotEmpty) {
          if (isAktivneTab) {
            if (!mounted) return; 
            setState(() => rezervacijeAktivne.addAll(result.result));
            pageAktivne = page;
            hasNextPageAktivne = result.result.length >= 10;
          } else {
            if (!mounted) return; 
            setState(() => rezervacijeHistorija.addAll(result.result));
            pageHistorija = page;
            hasNextPageHistorija = result.result.length >= 10;
          }
        } else {
          if (isAktivneTab) {
            if (!mounted) return; 
            setState(() => hasNextPageAktivne = false);
          } else {
            if (!mounted) return; 
            setState(() => hasNextPageHistorija = false);
          }
        }
      } catch (e) {
        debugPrint('Greška prilikom učitavanja: $e');
      } finally {
        if (!mounted) return; 
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
                                heroTag: "fab_rezervacije",
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
                                heroTag: "fab_historija",
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
                  if (!mounted) return; 
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
                        if (!mounted) return; 
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
                          if (!mounted) return; 
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
                  backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                  foregroundColor: const Color.fromARGB(199, 0, 0, 0),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(150, 59),
                ),
                onPressed: () {
                  if (!mounted) return; 
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
                onTap: () async {
                  _lastActiveTab = _tabController.index;

                  if (_tabController.index == 0) {
                    _lastScrollOffsetAktivne = scrollControllerRezervacije.offset;
                  } else {
                    _lastScrollOffsetHistorija = scrollControllerHistorija.offset;
                  }
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DetaljiRezervacijeScreen(rezervacija: e),
                    ),
                  );

                  if (result == true) {
                    _tabController.index = _lastActiveTab;      
                    await _reloadCurrentTab();                  
                    if (_lastActiveTab == 0) {
                      scrollControllerRezervacije.jumpTo(_lastScrollOffsetAktivne); 
                    } else {
                      scrollControllerHistorija.jumpTo(_lastScrollOffsetHistorija);
                    }
                  }
                },
                child: Stack(
                  children: [
                    AnimatedContainer(
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
                          Row(
                            children: [
                              Icon(
                                e.stateMachine == "kreirana"
                                    ? Icons.calendar_today_outlined
                                    : Icons.event_available_outlined,
                                color: Colors.black,
                                size: e.stateMachine == "kreirana" ? 22 : 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Rezervacija #${e.sifra}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
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
                                    .join(", ") ?? 'Nema stavki',
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

                    if (isHovered) Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                          () {
                            if (AuthProvider.korisnikId == e.frizerId) {
                              if (e.stateMachine == "kreirana") {
                                return "Klikni za detalje i da odobriš rezervaciju.";
                              } else if (e.stateMachine == "odobrena") {
                                final sada = DateTime.now();
                                final vrijemeParts = e.vrijemePocetka?.split(":");
                                final hour = int.tryParse(vrijemeParts?[0] ?? "0") ?? 0;
                                final minute = int.tryParse(vrijemeParts?[1] ?? "0") ?? 0;

                                final datumVrijemeRezervacije = DateTime(
                                  e.datumRezervacije!.year,
                                  e.datumRezervacije!.month,
                                  e.datumRezervacije!.day,
                                  hour,
                                  minute,
                                );

                                if (sada.isAfter(datumVrijemeRezervacije)) {
                                  return "Klikni za detalje i da završiš rezervaciju.";
                                } else {
                                  return "Klikni za detalje i da završiš/otkažeš rezervaciju.";
                                }
                              }
                            }
                            return "Klikni za detalje";
                          }(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
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
        orderBy: 'DatumRezervacije', 
        sortDirection: 'desc',
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

  Future<void> _reloadCurrentTab() async {

    if (!mounted) return;
    bool isAktivneTab = _tabController.index == 0;

    searchRequest['stateMachine'] = isAktivneTab
        ? ['kreirana', 'odobrena']
        : ['zavrsena', 'ponistena'];

    var result = await rezervacijaProvider.get(
      filter: searchRequest,
      page: 1,
      pageSize: limit,
      orderBy: 'DatumRezervacije',
      sortDirection: isAktivneTab ? 'desc' : 'asc',
    );

    if (!mounted) return;

    setState(() {
      if (isAktivneTab) {
        rezervacijeAktivne = result.result;
        hasNextPageAktivne = result.result.length >= limit;
      } else {
        rezervacijeHistorija = result.result;
        hasNextPageHistorija = result.result.length >= limit;
      }
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DetaljiRezervacijeScreen(rezervacija: e),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    AnimatedContainer(
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
                          Row(
                            children: [
                              Icon(
                                e.stateMachine == "zavrsena"
                                    ? Icons.check_circle_outline
                                    : Icons.cancel_outlined,
                                color: Colors.black,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Rezervacija #${e.sifra}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
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

                    if (isHovered)
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Klikni za detalje",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
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
      if (!mounted) return;
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
                    if (!mounted) return;
                    setState(() {
                      isHoveredDatumGTE = true;
                    });
                  },
                  onExit: (_) {
                    if (!mounted) return;
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
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 180, 140, 218),
                ),
                child: InkWell(
                  onTap: () async {
                    datumGTE = null;
                    searchRequest['DatumRezervacijeGTE'] = null;
                    _firstLoad();
                    if (!mounted) return;
                    setState(() {});
                  },
                  child:const Center(
                    child: Text(
                      "Očisti filter",
                      style: TextStyle(
                        fontSize: 16,
                        color:  Color.fromARGB(199, 0, 0, 0),
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
