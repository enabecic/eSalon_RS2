import 'package:esalon_mobile/main.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/screens/usluga_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:esalon_mobile/models/ocjena.dart';
import 'package:esalon_mobile/models/usluga.dart';
import 'package:esalon_mobile/models/favorit.dart';
import 'package:esalon_mobile/models/search_result.dart';
import 'package:esalon_mobile/providers/ocjena_provider.dart';
import 'package:esalon_mobile/providers/favorit_provider.dart';
import 'package:esalon_mobile/providers/usluga_provider.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class UslugeFilterScreen extends StatefulWidget {
  final int? vrstaId;        
  final String? vrstaNaziv;   

  const UslugeFilterScreen({super.key, this.vrstaId, this.vrstaNaziv});

  @override
  State<UslugeFilterScreen> createState() => _UslugeFilterScreenState();
}

class _UslugeFilterScreenState extends State<UslugeFilterScreen> {
  late UslugaProvider uslugaProvider;
  late OcjenaProvider ocjenaProvider;
  late FavoritProvider favoritProvider;

  SearchResult<Usluga>? uslugaResult;
  SearchResult<Ocjena>? ocjenaResult;
  SearchResult<Favorit>? favoritResult;
  bool isFavorit = false;
  List<Usluga> uslugaList = [];
  int page = 1;
  final int limit = 20;
  int total = 0;
  bool showbtn = false;
  bool isFirstLoadRunning = false;
  bool hasNextPage = true;
  bool isLoadMoreRunning = false;

  late ScrollController scrollController = ScrollController();

  final Map<String, Widget> _cachedImages = {};
  Map<String, dynamic> searchRequest = {};
  late TextEditingController _searchController;

  RangeValues? _cijenaFilter;
  RangeValues? _trajanjeFilter;

  String? _orderBy = 'DatumObjavljivanja';
  String  _sortDirection = 'desc';
  bool _changed = false;

  bool _isLoadingOcjene = true;
  bool _isLoadingFavoriti = true;
  bool _isLoadingUsluge = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    uslugaProvider = context.read<UslugaProvider>();
    ocjenaProvider = context.read<OcjenaProvider>();
    favoritProvider = context.read<FavoritProvider>();
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsluge();  
      _loadOcjene();    
      _loadFavoriti();   
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
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUsluge() async {
    try {
      final filter = <String, dynamic>{
        'NazivOpisFTS': _searchController.text,
        if (_cijenaFilter != null) 'CijenaGTE': _cijenaFilter!.start,
        if (_cijenaFilter != null) 'CijenaLTE': _cijenaFilter!.end,
        if (_trajanjeFilter != null) 'TrajanjeGTE': _trajanjeFilter!.start.round(),
        if (_trajanjeFilter != null) 'TrajanjeLTE': _trajanjeFilter!.end.round(),
        if (_orderBy != null) ...{
          'orderBy': _orderBy,
          'sortDirection': _sortDirection,
        },
        if (widget.vrstaId != null) 'VrstaId': widget.vrstaId,
      };
      if (!mounted) return;
      var uslugaResult = await uslugaProvider.get(
        filter: filter,
        page: page,
        pageSize: 10,
      );

      if (!mounted) return;
      setState(() {
        uslugaList = uslugaResult.result;
        total = uslugaResult.count;
        _isLoadingUsluge = false;

        hasNextPage = (10 * page < total);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingUsluge = false);
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

  Future<void> _loadOcjene() async {
    try {
      if (!mounted) return;
      var ocjene = await ocjenaProvider.get();
      if (!mounted) return;
      setState(() {
        ocjenaResult = ocjene;
        _isLoadingOcjene = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingOcjene = false);
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

  Future<void> _loadFavoriti() async {
    if (!mounted) return;
    setState(() {
      _isLoadingFavoriti = true;
    });
    try {
      if (AuthProvider.isSignedIn) {
        if (!mounted) return;
         var favoriti = await favoritProvider.get(filter: {
          "KorisnikId": AuthProvider.korisnikId,
        });
        if (!mounted) return;
        setState(() {
          favoritResult = favoriti;
        });
      }
      if (!mounted) return;
      setState(() => _isLoadingFavoriti = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingFavoriti = false);
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
    if (hasNextPage &&
        !isFirstLoadRunning &&
        !isLoadMoreRunning &&
        scrollController.position.extentAfter < 300) {
      if (!mounted) return;
      setState(() {
        isLoadMoreRunning = true;
      });

      try {
        page += 1;
        if (!mounted) return;
        final filter = <String, dynamic>{
          'NazivOpisFTS': _searchController.text,
          if (_cijenaFilter != null) 'CijenaGTE': _cijenaFilter!.start,
          if (_cijenaFilter != null) 'CijenaLTE': _cijenaFilter!.end,
          if (_trajanjeFilter != null) 'TrajanjeGTE': _trajanjeFilter!.start.round(),
          if (_trajanjeFilter != null) 'TrajanjeLTE': _trajanjeFilter!.end.round(),
          if (_orderBy != null) ...{
            'orderBy': _orderBy,
            'sortDirection': _sortDirection,
          },
          if (widget.vrstaId != null) 'VrstaId': widget.vrstaId,
        };
        if (!mounted) return;
        var uslugaResult = await uslugaProvider.get(
          filter: filter,
          page: page,
          pageSize: 10,
          );

        if (uslugaResult.result.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            uslugaList.addAll(uslugaResult.result);
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
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 0,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Pretraži po nazivu ili opisu...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey, size: 20), 
                        onPressed: () {
                          _searchController.clear();
                          page = 1;
                          _loadUsluge();
                          if (!mounted) return;
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), 
              ),
              onSubmitted: (value) {
                page = 1;
                _loadUsluge();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openFilterSheet() {
    RangeValues tempCijena =
        _cijenaFilter ?? const RangeValues(1, 1000);
    RangeValues tempTrajanje =
        _trajanjeFilter ?? const RangeValues(10, 300);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  const Align(
                    alignment: Alignment.center, 
                    child: Text(
                      "Filteri",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Cijena (KM)",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Od ${tempCijena.start.round()} KM do ${tempCijena.end.round()} KM",
                      style: const TextStyle(fontSize: 12,  color: Colors.black87),
                    ),
                  ),
                  RangeSlider(
                    values: tempCijena,
                    min: 1,
                    max: 1000,
                    divisions: 999,
                    labels: RangeLabels(
                      tempCijena.start.toInt().toString(),
                      tempCijena.end.toInt().toString(),
                    ),
                    onChanged: (v) {
                      setSheetState(() => tempCijena = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Trajanje (min)",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Od ${tempTrajanje.start.round()} min do ${tempTrajanje.end.round()} min",
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                  RangeSlider(
                    values: tempTrajanje,
                    min: 10,
                    max: 300,
                    divisions: 58, 
                    labels: RangeLabels(
                      "${(tempTrajanje.start / 5).round() * 5}",
                      "${(tempTrajanje.end / 5).round() * 5}",
                    ),
                    onChanged: (v) {
                      setSheetState(() {
                        tempTrajanje = RangeValues(
                          (v.start / 5).round() * 5.0,
                          (v.end / 5).round() * 5.0,
                        );
                      });
                    },
                  ),

                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      const Text(
                        "Sortiranje",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            _orderBy = "Cijena";
                            _sortDirection = "asc";
                          });
                        },
                        child: Text(
                          "Cijena: najniža → najviša",
                          style: TextStyle(
                            color: _orderBy == "Cijena" && _sortDirection == "asc"
                                ? Colors.deepPurple
                                : Colors.black87,
                            fontWeight: _orderBy == "Cijena" && _sortDirection == "asc"
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            _orderBy = "Cijena";
                            _sortDirection = "desc";
                          });
                        },
                        child: Text(
                          "Cijena: najviša → najniža",
                          style: TextStyle(
                            color: _orderBy == "Cijena" && _sortDirection == "desc"
                                ? Colors.deepPurple
                                : Colors.black87,
                            fontWeight: _orderBy == "Cijena" && _sortDirection == "desc"
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            _orderBy = "Trajanje";
                            _sortDirection = "asc";
                          });
                        },
                        child: Text(
                          "Trajanje: najniže → najviše",
                          style: TextStyle(
                            color: _orderBy == "Trajanje" && _sortDirection == "asc"
                                ? Colors.deepPurple
                                : Colors.black87,
                            fontWeight: _orderBy == "Trajanje" && _sortDirection == "asc"
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            _orderBy = "Trajanje";
                            _sortDirection = "desc";
                          });
                        },
                        child: Text(
                          "Trajanje: najviše → najniže",
                          style: TextStyle(
                            color: _orderBy == "Trajanje" && _sortDirection == "desc"
                                ? Colors.deepPurple
                                : Colors.black87,
                            fontWeight: _orderBy == "Trajanje" && _sortDirection == "desc"
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            _orderBy = "Naziv";
                            _sortDirection = "asc";
                          });
                        },
                        child: Text(
                          "Naziv: A → Z",
                          style: TextStyle(
                            color: _orderBy == "Naziv" && _sortDirection == "asc"
                                ? Colors.deepPurple
                                : Colors.black87,
                            fontWeight: _orderBy == "Naziv" && _sortDirection == "asc"
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            _orderBy = "Naziv";
                            _sortDirection = "desc";
                          });
                        },
                        child: Text(
                          "Naziv: Z → A",
                          style: TextStyle(
                            color: _orderBy == "Naziv" && _sortDirection == "desc"
                                ? Colors.deepPurple
                                : Colors.black87,
                            fontWeight: _orderBy == "Naziv" && _sortDirection == "desc"
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          if (!mounted) return;
                          setState(() {
                            _cijenaFilter = null;
                            _trajanjeFilter = null;
                            _orderBy = 'DatumObjavljivanja';
                            _sortDirection = 'desc';
                          });
                          if (!mounted) return;
                          page = 1;
                          _loadUsluge();
                        },
                        child: const Text("Izbriši filter"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          if (!mounted) return;
                          setState(() {
                            _cijenaFilter = tempCijena;
                            _trajanjeFilter = tempTrajanje;
                          });
                          if (!mounted) return;
                          page = 1;
                          _loadUsluge();
                        },
                        child: const Text("Filtriraj"),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
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
      body: _isLoadingUsluge
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,   
                      right: 16,  
                      top: 18,    
                      bottom: 15,
                    ),
                    child: _buildHeader(),
                  ),
                  _buildSearchAndFilter(),
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
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.vrstaNaziv ?? "Usluge", 
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.content_cut,
              color: Colors.black,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage() {
    if (_isLoadingUsluge && uslugaList.isEmpty) { 
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 5, 
          bottom: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ukupan broj usluga: $total",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    (_cijenaFilter != null || _trajanjeFilter != null)
                        ? Icons.filter_alt
                        : Icons.filter_list,
                    color: (_cijenaFilter != null || _trajanjeFilter != null)
                        ? Colors.deepPurple
                        : Colors.black87,
                  ),
                  onPressed: _openFilterSheet,
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                      if (!mounted) return;
                      final uslugaDetalji = await uslugaProvider.getById(e.uslugaId!);
                      if (!context.mounted) return;
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UslugaDetailsScreen(usluga: uslugaDetalji),
                        ),
                      );
                      if (result == true) {
                        page = 1;
                        _loadFavoriti();
                        _loadOcjene();
                        if (!mounted) return;
                        setState(() {
                          _changed = true;
                        });
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          duration: const Duration(milliseconds: 1800),
                          content: Center(
                            child: Text(
                              e.toString(),
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
                                          child: (_cachedImages[e.slika!] ??= imageFromString(e.slika!)),
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
                                  _isLoadingOcjene
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
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
                                onTap: _isLoadingFavoriti
                                    ? null
                                    : () async {
                                        if (AuthProvider.korisnikId == null) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red,
                                              duration: const Duration(milliseconds: 1500),
                                              content: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) => const LoginPage()),
                                                  );
                                                },
                                                child: RichText(
                                                  text: const TextSpan(
                                                    text:
                                                        "Morate biti prijavljeni da biste dodali uslugu u favorite. ",
                                                    style: TextStyle(
                                                        color: Colors.white, fontSize: 15),
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
                                          );
                                          return;
                                        }
                                        try {
                                          bool isFavorite = !_isLoadingFavoriti &&
                                            favoritResult != null &&
                                            favoritResult!.result.any((f) =>
                                                f.korisnikId == AuthProvider.korisnikId &&
                                                f.uslugaId == e.uslugaId);

                                          if (!isFavorite) {
                                            if (!mounted) return;
                                            await favoritProvider.insert({
                                              'korisnikId': AuthProvider.korisnikId,
                                              'uslugaId': e.uslugaId
                                            });
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                backgroundColor: Color.fromARGB(255, 138, 182, 140),
                                                duration: Duration(milliseconds: 1500),
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
                                                    f.korisnikId == AuthProvider.korisnikId &&
                                                    f.uslugaId == e.uslugaId);
                                            if (!mounted) return;
                                            await favoritProvider.delete(favRest.favoritId!);
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                backgroundColor: Color.fromARGB(255, 138, 182, 140),
                                                duration: Duration(milliseconds: 1500),
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
                                          setState(() {
                                            _changed = true;
                                          });
                                          if (!mounted) return;
                                          favoritResult = await favoritProvider.get(filter: {
                                            "KorisnikId": AuthProvider.korisnikId,
                                          });
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
                                child: _isLoadingFavoriti
                                    ? const Icon(Icons.favorite, color: Colors.grey) 
                                    : (favoritResult != null &&
                                            favoritResult!.result.any(
                                              (f) =>
                                                  f.korisnikId == AuthProvider.korisnikId &&
                                                  f.uslugaId == e.uslugaId,
                                            ))
                                        ? const Icon(Icons.favorite, color: Colors.red)
                                        : const Icon(Icons.favorite_border),
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
            const SizedBox(height: 15),
            if (isLoadMoreRunning)
              const Center(child: CircularProgressIndicator())
            else if (!hasNextPage)
              Center(
              child: uslugaList.isEmpty
                  ? const Column(
                      children: [
                        Icon(
                          Icons.cut, 
                          size: 40,
                          color: Color.fromARGB(255, 76, 72, 72),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Nema usluga za prikazati.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    )
                  : Container(
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
                          "Nema više usluga za prikazati.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            )
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
