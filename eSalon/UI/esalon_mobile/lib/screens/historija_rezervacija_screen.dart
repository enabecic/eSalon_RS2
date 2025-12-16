import 'dart:async';
import 'package:esalon_mobile/screens/detalji_rezervacije_screen.dart';
import 'package:flutter/material.dart';
import 'package:esalon_mobile/models/rezervacija.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/rezervacija_provider.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class HistorijaRezervacijaScreen extends StatefulWidget {
  const HistorijaRezervacijaScreen({super.key});

  @override
  State<HistorijaRezervacijaScreen> createState() => _HistorijaRezervacijaScreenState();
}

class _HistorijaRezervacijaScreenState extends State<HistorijaRezervacijaScreen>
    with SingleTickerProviderStateMixin {

  late RezervacijaProvider rezervacijaProvider;
  Map<String, dynamic> searchRequest = {};
  int page = 1;
  int total = 0;
  bool hasNextPage = true;
  bool showbtn = false;
  late TabController _tabController;
  bool isLoadMoreRunning = false;

  late ScrollController zavrseneScrollController;
  late ScrollController otkazaneScrollController;

  bool isZavrseneLoading = false;
  bool isOtkazaneLoading = false;
  List<Rezervacija>? zavrseneRezervacije;
  List<Rezervacija>? otkazaneRezervacije;

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

    zavrseneScrollController = ScrollController();
    otkazaneScrollController = ScrollController();

    _firstLoad();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) { 
        showbtn = false;
        searchRequest.remove('DatumRezervacijeGTE');
        searchRequest.remove('DatumRezervacijeLTE');
        _firstLoad();
      }
    });

    zavrseneScrollController.addListener(() => _scrollListener(isZavrseneTab: true));
    otkazaneScrollController.addListener(() => _scrollListener(isZavrseneTab: false));

    _initForm();
  }

  void _scrollListener({required bool isZavrseneTab}) {
    final controller = isZavrseneTab ? zavrseneScrollController : otkazaneScrollController;
    
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
    bool isZavrseneTab = _tabController.index == 0;
    setState(() {
      if (isZavrseneTab) {
        isZavrseneLoading = true;
      } else {
        isOtkazaneLoading = true;
      }

      page = 1;
      hasNextPage = true;
      isLoadMoreRunning = false;
    });

    searchRequest['StateMachine'] = isZavrseneTab ? 'zavrsena' : 'ponistena';

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
        if (isZavrseneTab) {
        zavrseneRezervacije = rezervacijaResult.result;
        total = rezervacijaResult.count;
        isZavrseneLoading = false;
      } else {
        otkazaneRezervacije = rezervacijaResult.result;
        total = rezervacijaResult.count;
        isOtkazaneLoading = false;
      }
        if (10 * page > total) hasNextPage = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (isZavrseneTab) {
          isZavrseneLoading = false;
        } else {
          isOtkazaneLoading = false;
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

  void _loadMore() async {
    bool isZavrseneTab = _tabController.index == 0;
    ScrollController controller = isZavrseneTab ? zavrseneScrollController : otkazaneScrollController;

    if ((isZavrseneTab ? isZavrseneLoading : isOtkazaneLoading) || isLoadMoreRunning) return;
    if (!hasNextPage || controller.position.extentAfter > 300) return;

    if (!mounted) return;
    setState(() {
      isLoadMoreRunning = true;
    });

    try {
      page += 1;
      searchRequest['StateMachine'] = isZavrseneTab ? 'zavrsena' : 'ponistena';
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
          if (isZavrseneTab) {
            zavrseneRezervacije ??= [];
            zavrseneRezervacije!.addAll(rezervacijaResult.result);
          } else {
            otkazaneRezervacije ??= [];
            otkazaneRezervacije!.addAll(rezervacijaResult.result);
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 244, 247),
       appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 25),
        child: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF6F4F3),
          automaticallyImplyLeading: false,
          toolbarHeight: kToolbarHeight + 25,
          title: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: 
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 40,
                    ),
                    onPressed: () => Navigator.pop(context),
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
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
              child: _buildHeader(), 
            ),
            Container(
              padding: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 0),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "Završene"),
                  Tab(text: "Otkazane"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildZavrsene(), _buildOtkazane()],
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
            bool isZavrseneTab = _tabController.index == 0;
            ScrollController controller =
                isZavrseneTab ? zavrseneScrollController : otkazaneScrollController;

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
                "Historija rezervacija",
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
              Icons.event_note,
              color: Colors.black,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZavrsene() {
    if (isZavrseneLoading || zavrseneRezervacije == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      controller: zavrseneScrollController,
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [
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

          if (zavrseneRezervacije!.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 26),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 38,
                      color: Color.fromARGB(255, 76, 72, 72),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Nemate završenih rezervacija.",
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

          if (zavrseneRezervacije!.isNotEmpty)
            ...zavrseneRezervacije!.map(
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
                                      Icons.check_circle_outline,
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

            if (zavrseneRezervacije!.isNotEmpty) ...[
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

  Widget _buildOtkazane() {
    if (isOtkazaneLoading || otkazaneRezervacije == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      controller: otkazaneScrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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

          if (otkazaneRezervacije!.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 26),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 40,
                      color: Color.fromARGB(255, 76, 72, 72),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Nemate otkazanih rezervacija.",
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

          if (otkazaneRezervacije!.isNotEmpty)
            ...otkazaneRezervacije!.map(
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
                                    Icons.cancel_outlined,
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

          if (otkazaneRezervacije!.isNotEmpty) ...[
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
