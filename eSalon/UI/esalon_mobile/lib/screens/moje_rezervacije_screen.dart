import 'dart:async';
import 'package:esalon_mobile/main.dart';
import 'package:esalon_mobile/screens/historija_rezervacija_screen.dart';
import 'package:esalon_mobile/screens/detalji_rezervacije_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:esalon_mobile/models/rezervacija.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/rezervacija_provider.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class MojeRezervacijeScreen extends StatefulWidget {
  const MojeRezervacijeScreen({super.key});

  @override
  State<MojeRezervacijeScreen> createState() => _MojeRezervacijeScreenState();
}

class _MojeRezervacijeScreenState extends State<MojeRezervacijeScreen>
    with SingleTickerProviderStateMixin {

  late RezervacijaProvider rezervacijaProvider;
  Map<String, dynamic> searchRequest = {};
  int page = 1;
  int total = 0;
  bool hasNextPage = true;
  bool showbtn = false;
  late TabController _tabController;
  bool isLoadMoreRunning = false;

  late ScrollController aktivneScrollController;
  late ScrollController odobreneScrollController;

  bool isAktivneLoading = false;
  bool isOdobreneLoading = false;
  List<Rezervacija>? aktivneRezervacije;
  List<Rezervacija>? odobreneRezervacije;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    searchRequest = {
      'KorisnikId': AuthProvider.korisnikId,
    };
    
    _tabController = TabController(length: 2, vsync: this);
    rezervacijaProvider = context.read<RezervacijaProvider>();

    aktivneScrollController = ScrollController();
    odobreneScrollController = ScrollController();

    _firstLoad();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) { 
        showbtn = false;
        _firstLoad();
      }
    });

    aktivneScrollController.addListener(() => _scrollListener(isAktivneTab: true));
    odobreneScrollController.addListener(() => _scrollListener(isAktivneTab: false));

    _initForm();
  }

  void _scrollListener({required bool isAktivneTab}) {
    final controller = isAktivneTab ? aktivneScrollController : odobreneScrollController;
    
    double showOffset = 10.0;
    if (controller.offset > showOffset) {
      showbtn = true;
    } else {
      showbtn = false;
    }

    if (!mounted) return;
    setState(() {});

    if (controller.position.maxScrollExtent == controller.position.pixels) {
      _loadMore();
    }
  }

  void _firstLoad() async {
    if (!mounted) return;
    bool isAktivneTab = _tabController.index == 0;
    setState(() {
      if (isAktivneTab) {
        isAktivneLoading = true;
      } else {
        isOdobreneLoading = true;
      }

      page = 1;
      hasNextPage = true;
      isLoadMoreRunning = false;
    });

    searchRequest['StateMachine'] = isAktivneTab ? 'kreirana' : 'odobrena';

    if (AuthProvider.isSignedIn) {
      try {
        if (!mounted) return;
        var rezervacijaResult = await rezervacijaProvider.get(
          filter: searchRequest,
          page: page,
          pageSize: 10,
          orderBy: 'DatumRezervacije',
          sortDirection: 'desc',
        );

        if (!mounted) return;
        setState(() {
          if (isAktivneTab) {
          aktivneRezervacije = rezervacijaResult.result;
          total = rezervacijaResult.count;
          isAktivneLoading = false;
        } else {
          odobreneRezervacije = rezervacijaResult.result;
          total = rezervacijaResult.count;
          isOdobreneLoading = false;
        }
          if (10 * page > total) hasNextPage = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          if (isAktivneTab) {
            isAktivneLoading = false;
          } else {
            isOdobreneLoading = false;
          }
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
  }

  void _loadMore() async {
    bool isAktivneTab = _tabController.index == 0;
    ScrollController controller = isAktivneTab ? aktivneScrollController : odobreneScrollController;

    if ((isAktivneTab ? isAktivneLoading : isOdobreneLoading) || isLoadMoreRunning) return;
    if (!hasNextPage || controller.position.extentAfter > 300) return;

    if (!mounted) return;
    setState(() {
      isLoadMoreRunning = true;
    });

    try {
      page += 1;
      searchRequest['StateMachine'] = isAktivneTab ? 'kreirana' : 'odobrena';
      if (!mounted) return;
      var rezervacijaResult = await rezervacijaProvider.get(
        filter: searchRequest,
        page: page,
        pageSize: 10,
        orderBy: 'DatumRezervacije',
        sortDirection: 'desc',
      );

      if (!mounted) return;

      if (rezervacijaResult.result.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          if (isAktivneTab) {
            aktivneRezervacije ??= [];
            aktivneRezervacije!.addAll(rezervacijaResult.result);
          } else {
            odobreneRezervacije ??= [];
            odobreneRezervacije!.addAll(rezervacijaResult.result);
          }

          total = rezervacijaResult.count;
          if (10 * page >= total) hasNextPage = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          hasNextPage = false;
        });
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
    } finally {
      if (mounted) {
          setState(() {
            isLoadMoreRunning = false;
          });
        }
    }
  }

  Future _initForm() async {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
  if (!AuthProvider.isSignedIn) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 244, 247),
      body: Center(
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 244, 247),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
              child: _buildHeader(), 
            ),
            Container(
              padding: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 7),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "Aktivne"),
                  Tab(text: "Odobrene"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildAktivne(), _buildOdobrene()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 1000),
        opacity: showbtn ? 1.0 : 0.0,
        child: FloatingActionButton(
          onPressed: () {
            bool isAktivneTab = _tabController.index == 0;
            ScrollController controller =
                isAktivneTab ? aktivneScrollController : odobreneScrollController;

            controller.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
            );
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
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible( 
              child: Text(
                "Moje rezervacije",
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
              Icons.calendar_today,
              color: Colors.black,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAktivne() {
    if (isAktivneLoading || aktivneRezervacije == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      controller: aktivneScrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(97, 158, 158, 158),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Napomena: Rezervacija se može otkazati najkasnije 3 dana prije termina i ako se plaća gotovinom.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Broj rezervacija: $total",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const HistorijaRezervacijaScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 210, 193, 214),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min, 
                            children: [
                              Icon(
                                Icons.event_note,
                                size: 18,
                                color: Colors.black87,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Historija rezervacija",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (aktivneRezervacije!.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 26),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 38,
                      color: Color.fromARGB(255, 76, 72, 72),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Nemate trenutno aktivnih rezervacija.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (aktivneRezervacije!.isNotEmpty)
            ...aktivneRezervacije!.map(
              (e) => InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DetaljiRezervacijeScreen(rezervacija: e),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 135,
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
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Slidable(
                    startActionPane: ActionPane(
                      motion: const BehindMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            try {
                              String? nacinPlacanja = e.nacinPlacanjaNaziv?.toLowerCase();
                              DateTime? termin = e.datumRezervacije;

                              bool isGotovina = nacinPlacanja == "gotovina";
                              bool is3DanaPrije = termin != null &&
                                  termin.difference(DateTime.now()).inDays >= 3;

                              if (!isGotovina || !is3DanaPrije) {
                                if (!context.mounted) return;

                                String poruka = "Rezervaciju nije moguće otkazati jer";

                                if (!isGotovina) {
                                  poruka += "\n način plaćanja nije gotovina";
                                }
                                if (!is3DanaPrije) {
                                  poruka += "\n može se otkazati najkasnije 3 dana prije termina";
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                    content: Center(
                                      child: Text(
                                        poruka,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                );
                                return; 
                              }

                              if (!mounted) return;
                              await rezervacijaProvider.ponisti(e.rezervacijaId!);

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color.fromARGB(255, 138, 182, 140),
                                  duration: Duration(seconds: 1),
                                  content: Center(
                                    child: Text("Rezervacija je uspješno poništena."),
                                  ),
                                ),
                              );

                              if (!mounted) return;
                              var rezervacijaResult = await rezervacijaProvider.get(
                                filter: searchRequest,
                                orderBy: 'DatumRezervacije',
                                sortDirection: 'desc',
                              );

                              if (!mounted) return;
                              setState(() {
                                aktivneRezervacije = rezervacijaResult.result.isNotEmpty
                                    ? rezervacijaResult.result
                                    : [];
                                total = rezervacijaResult.count;
                              });

                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  duration: const Duration(milliseconds: 1800),
                                  content: Center(
                                    child: Text(
                                      e.toString(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          backgroundColor: Colors.red,
                          icon: Icons.close,
                          label: 'Otkaži',
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, top: 0, bottom: 0),
                            child: SizedBox(
                              width: 120,
                              height: 100,
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: Image.asset(
                                    "assets/images/praznaUsluga.png",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        "Rezervacija: #${e.sifra}",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Ukupna cijena: ${formatNumber(e.ukupnaCijena)} KM",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Color.fromARGB(255, 108, 108, 108),
                                            fontWeight: FontWeight.w600,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Datum rezervacije: \n${formatDate(e.datumRezervacije.toString())}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 108, 108, 108),
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (aktivneRezervacije!.isNotEmpty) ...[
              if (hasNextPage) const CircularProgressIndicator(),
              if (!hasNextPage)
                Container(
                  width: 300,
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
            ]
        ],
      ),
    );
  }

  Widget _buildOdobrene() {
    if (isOdobreneLoading || odobreneRezervacije == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      controller: odobreneScrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Broj rezervacija: $total",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const HistorijaRezervacijaScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 210, 193, 214),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min, 
                            children: [
                              Icon(
                                Icons.event_note,
                                size: 18,
                                color: Colors.black87,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Historija rezervacija",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (odobreneRezervacije!.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 26),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 40,
                      color: Color.fromARGB(255, 76, 72, 72),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Nemate odobrenih rezervacija.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (odobreneRezervacije!.isNotEmpty)
            ...odobreneRezervacije!.map(
              (e) => InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DetaljiRezervacijeScreen(rezervacija: e),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 135,
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
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: SizedBox(
                            width: 120,
                            height: 100,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(12)),
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Image.asset(
                                  "assets/images/praznaUsluga.png",
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.event_available_outlined,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Rezervacija: #${e.sifra}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Ukupna cijena: ${formatNumber(e.ukupnaCijena)} KM",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Color.fromARGB(255, 108, 108, 108),
                                          fontWeight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Datum rezervacije: \n${formatDate(e.datumRezervacije.toString())}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 108, 108, 108),
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (odobreneRezervacije!.isNotEmpty) ...[
            if (hasNextPage) const CircularProgressIndicator(),
            if (!hasNextPage)
              Container(
                width: 300,
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
        ],
      ),
    );
  }

}
