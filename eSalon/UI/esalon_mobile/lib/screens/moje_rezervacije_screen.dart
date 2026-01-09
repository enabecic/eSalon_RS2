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
        searchRequest.remove('DatumRezervacijeGTE');
        searchRequest.remove('DatumRezervacijeLTE');
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
    if (!mounted) return;
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
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 5),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HistorijaRezervacijaScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 210, 193, 214),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha((0.5 * 255).round()),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 4),
                      ),
                    ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ukupan broj rezervacija: $total",
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
                  child: Builder(
                    builder: (scaffoldContext) {
                      return IconButton(
                        icon: Icon(
                          (searchRequest['DatumRezervacijeGTE'] != null ||
                                  searchRequest['DatumRezervacijeLTE'] != null)
                              ? Icons.filter_alt
                              : Icons.filter_list,
                          color: (searchRequest['DatumRezervacijeGTE'] != null ||
                                  searchRequest['DatumRezervacijeLTE'] != null)
                              ? Colors.deepPurple
                              : Colors.black87,
                        ),
                        onPressed: () async {
                          DateTime? tempDatumOd = searchRequest['DatumRezervacijeGTE'];
                          DateTime? tempDatumDo = searchRequest['DatumRezervacijeLTE'];
                          if (!mounted) return;
                          await showModalBottomSheet(
                            context: scaffoldContext,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setModalState) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).viewInsets.bottom,
                                      top: 16,
                                      left: 16,
                                      right: 16,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 12),
                                          child: Center(
                                            child: Text(
                                              "Filteri",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: const Text("Datum od"),
                                          subtitle: Text(tempDatumOd != null
                                              ? formatDate(tempDatumOd.toString())
                                              : "Odaberite datum"),
                                          trailing: const Icon(Icons.calendar_today),
                                          onTap: () async {
                                            if (!mounted) return;
                                            DateTime? selected = await showDatePicker(
                                              context: context,
                                              initialDate: tempDatumOd ?? DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                            );
                                            if (selected != null) {
                                              setModalState(() {
                                                tempDatumOd = selected;
                                              });
                                            }
                                          },
                                        ),
                                        ListTile(
                                          title: const Text("Datum do"),
                                          subtitle: Text(tempDatumDo != null
                                              ? formatDate(tempDatumDo.toString())
                                              : "Odaberite datum"),
                                          trailing: const Icon(Icons.calendar_today),
                                          onTap: () async {
                                            if (!mounted) return;
                                            DateTime? selected = await showDatePicker(
                                              context: context,
                                              initialDate: tempDatumDo ?? DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                            );
                                            if (selected != null) {
                                              setModalState(() {
                                                tempDatumDo = selected;
                                              });
                                            }
                                          },
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                setModalState(() {
                                                  tempDatumOd = null;
                                                  tempDatumDo = null;
                                                });
                                                if (!mounted) return;
                                                setState(() {
                                                  searchRequest.remove('DatumRezervacijeGTE');
                                                  searchRequest.remove('DatumRezervacijeLTE');
                                                });
                                                _firstLoad();
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Izbriši filter"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (tempDatumOd != null && tempDatumDo != null) {
                                                  if (tempDatumOd!.isAfter(tempDatumDo!)) {
                                                    Navigator.of(context).pop();
                                                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                                      const SnackBar(
                                                        content: Center(
                                                          child: Text(
                                                            "Datum od ne može biti nakon datuma do!",
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        backgroundColor: Colors.red,
                                                        duration: Duration(seconds: 2),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                }
                                                if (!mounted) return;
                                                setState(() {
                                                  searchRequest['DatumRezervacijeGTE'] = tempDatumOd;
                                                  searchRequest['DatumRezervacijeLTE'] = tempDatumDo;
                                                });
                                                _firstLoad();
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Filtriraj"),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
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
                        color: Colors.grey.withAlpha((0.5 * 255).round()),
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
                                    child: Text("Rezervacija je uspješno otkazana."),
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
                          icon: Icons.delete,
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
                                    "assets/images/rezervacija.png",
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
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Ukupna cijena: ${formatNumber(e.ukupnaCijena)} KM",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Color.fromARGB(255, 56, 54, 54),
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
                        color: Colors.grey.withAlpha((0.5 * 255).round()),
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
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 5),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HistorijaRezervacijaScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 210, 193, 214),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha((0.5 * 255).round()),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 4),
                      ),
                    ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ukupan broj rezervacija: $total",
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
                  child: Builder(
                    builder: (scaffoldContext) {
                      return IconButton(
                        icon: Icon(
                          (searchRequest['DatumRezervacijeGTE'] != null ||
                                  searchRequest['DatumRezervacijeLTE'] != null)
                              ? Icons.filter_alt
                              : Icons.filter_list,
                          color: (searchRequest['DatumRezervacijeGTE'] != null ||
                                  searchRequest['DatumRezervacijeLTE'] != null)
                              ? Colors.deepPurple
                              : Colors.black87,
                        ),
                        onPressed: () async {
                          DateTime? tempDatumOd = searchRequest['DatumRezervacijeGTE'];
                          DateTime? tempDatumDo = searchRequest['DatumRezervacijeLTE'];
                          if (!mounted) return;
                          await showModalBottomSheet(
                            context: scaffoldContext,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setModalState) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).viewInsets.bottom,
                                      top: 16,
                                      left: 16,
                                      right: 16,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 12),
                                          child: Center(
                                            child: Text(
                                              "Filteri",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: const Text("Datum od"),
                                          subtitle: Text(tempDatumOd != null
                                              ? formatDate(tempDatumOd.toString())
                                              : "Odaberite datum"),
                                          trailing: const Icon(Icons.calendar_today),
                                          onTap: () async {
                                            if (!mounted) return;
                                            DateTime? selected = await showDatePicker(
                                              context: context,
                                              initialDate: tempDatumOd ?? DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                            );
                                            if (selected != null) {
                                              setModalState(() {
                                                tempDatumOd = selected;
                                              });
                                            }
                                          },
                                        ),
                                        ListTile(
                                          title: const Text("Datum do"),
                                          subtitle: Text(tempDatumDo != null
                                              ? formatDate(tempDatumDo.toString())
                                              : "Odaberite datum"),
                                          trailing: const Icon(Icons.calendar_today),
                                          onTap: () async {
                                            if (!mounted) return;
                                            DateTime? selected = await showDatePicker(
                                              context: context,
                                              initialDate: tempDatumDo ?? DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                            );
                                            if (selected != null) {
                                              setModalState(() {
                                                tempDatumDo = selected;
                                              });
                                            }
                                          },
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                setModalState(() {
                                                  tempDatumOd = null;
                                                  tempDatumDo = null;
                                                });
                                                if (!mounted) return;
                                                setState(() {
                                                  searchRequest.remove('DatumRezervacijeGTE');
                                                  searchRequest.remove('DatumRezervacijeLTE');
                                                });
                                                _firstLoad();
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Izbriši filter"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (tempDatumOd != null && tempDatumDo != null) {
                                                  if (tempDatumOd!.isAfter(tempDatumDo!)) {
                                                    Navigator.of(context).pop();
                                                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                                      const SnackBar(
                                                        content: Center(
                                                          child: Text(
                                                            "Datum od ne može biti nakon datuma do!",
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        backgroundColor: Colors.red,
                                                        duration: Duration(seconds: 2),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                }
                                                if (!mounted) return;
                                                setState(() {
                                                  searchRequest['DatumRezervacijeGTE'] = tempDatumOd;
                                                  searchRequest['DatumRezervacijeLTE'] = tempDatumDo;
                                                });
                                                _firstLoad();
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Filtriraj"),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
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
                        color: Colors.grey.withAlpha((0.5 * 255).round()),
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
                                    child: Text("Rezervacija je uspješno otkazana."),
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
                                odobreneRezervacije = rezervacijaResult.result.isNotEmpty
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
                          icon: Icons.delete,
                          label: 'Otkaži',
                        ),
                      ],
                    ),
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
                                    "assets/images/rezervacija.png",
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
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Ukupna cijena: ${formatNumber(e.ukupnaCijena)} KM",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Color.fromARGB(255, 56, 54, 54),
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
                      color: Colors.grey.withAlpha((0.5 * 255).round()),
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
