import 'package:esalon_mobile/main.dart';
import 'package:esalon_mobile/models/obavijest.dart';
import 'package:esalon_mobile/providers/obavijest_provider.dart';
import 'package:esalon_mobile/screens/obavijesti_details_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class ObavijestiScreen extends StatefulWidget {
  const ObavijestiScreen({super.key});

  @override
  State<ObavijestiScreen> createState() => _ObavijestiScreenState();
}

class _ObavijestiScreenState extends State<ObavijestiScreen> {
  late ObavijestProvider obavijestProvider;
  Map<String, dynamic> searchRequest = {};

  List<Obavijest> obavijestList = [];
  int page = 1;

  final int pageSize = 10;
  int total = 0;
  bool isFirstLoadRunning = false;
  bool hasNextPage = true;
  bool showbtn = false;

  bool isLoadMoreRunning = false;
  late final ScrollController scrollController;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true; 
  bool _initialLoaded = false; 
  bool? _filterJePogledana; 

  DateTime? _filterDatumOd;
  DateTime? _filterDatumDo;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    searchRequest = {
      'KorisnikId': AuthProvider.korisnikId,
      'orderBy': 'DatumObavijesti',
      'sortDirection': 'desc',
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    obavijestProvider = context.read<ObavijestProvider>();

    if (!_initialLoaded) {
      _initialLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialData();
      });
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const double showOffset = 10.0;
    if (scrollController.offset > showOffset) {
      if (!mounted) return;
      if (!showbtn) setState(() => showbtn = true);
    } else {
      if (!mounted) return;
      if (showbtn) setState(() => showbtn = false);
    }

    if (!isFirstLoadRunning &&
        !isLoadMoreRunning &&
        hasNextPage &&
        scrollController.position.extentAfter < 300) {
      _loadMore();
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      isFirstLoadRunning = true; 
    });

    try {
      if (!mounted) return;

      if (AuthProvider.isSignedIn) {
        page = 1;
        if (!mounted) return;
        final filter = {
        ...searchRequest, 
        if (_filterJePogledana != null) 'JePogledana': _filterJePogledana,
        if (_searchController.text.isNotEmpty) 'Naslov': _searchController.text,
        if (_filterDatumOd != null) 'DatumObavijestiGTE': _filterDatumOd,
        if (_filterDatumDo != null)
          'DatumObavijestiLTE': DateTime(
              _filterDatumDo!.year,
              _filterDatumDo!.month,
              _filterDatumDo!.day,
              23,
              59,
              59,
            ),
        };
        if (!mounted) return;
        final obavijestResult = await obavijestProvider.get(
          filter: filter,
          page: page,
          pageSize: pageSize,
        );

        if (!mounted) return;
        setState(() {
          obavijestList = obavijestResult.result;
          total = obavijestResult.count;
          hasNextPage = (page * pageSize) < total;
        });
      } else {
        if (!mounted) return;
        setState(() {
          obavijestList = [];
          total = 0;
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
          _isLoading = false;
          isFirstLoadRunning = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (!hasNextPage || isFirstLoadRunning || isLoadMoreRunning) return;
    if (!mounted) return;

    setState(() {
      isLoadMoreRunning = true;
    });

    try {
      page += 1;
      if (!mounted) return;
      final filter = {
        ...searchRequest,
        if (_filterJePogledana != null) 'JePogledana': _filterJePogledana,
        if (_searchController.text.isNotEmpty) 'Naslov': _searchController.text,
        if (_filterDatumOd != null) 'DatumObavijestiGTE': _filterDatumOd,
        if (_filterDatumDo != null) 'DatumObavijestiLTE': _filterDatumDo,
      };
      if (!mounted) return;
      final result = await obavijestProvider.get(
        filter: filter,
        page: page,
        pageSize: pageSize,
      );
      if (!mounted) return;

      if (result.result.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          obavijestList.addAll(result.result);
          total = result.count;
          hasNextPage = (page * pageSize) < total;
        });
      } else {
        if (!mounted) return;
        setState(() {
          hasNextPage = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        hasNextPage = false;
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
    } finally {
      if (mounted) {
        setState(() {
          isLoadMoreRunning = false;
        });
      }
    }
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
                "Obavijesti",
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
              Icons.notifications_active,
              color: Colors.black,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateFilterDialog() async {
    DateTime? tempDatumOd = _filterDatumOd;
    DateTime? tempDatumDo = _filterDatumDo;
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
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
                        "Filteri po datumu",
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
                        ? DateFormat('dd.MM.yyyy').format(tempDatumOd!)
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
                        ? DateFormat('dd.MM.yyyy').format(tempDatumDo!)
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
                            _filterDatumOd = null;
                            _filterDatumDo = null;
                          });
                          page = 1;
                          _loadInitialData();
                          Navigator.of(context).pop();
                        },
                        child: const Text("Izbriši filter"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (tempDatumOd != null && tempDatumDo != null) {
                            if (tempDatumOd!.isAfter(tempDatumDo!)) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
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
                            _filterDatumOd = tempDatumOd;
                            _filterDatumDo = tempDatumDo;
                          });

                          page = 1;
                          _loadInitialData();

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
  }

  Future<void> _markAsRead(Obavijest o) async {
    if (!o.jePogledana) {
      try {
        if (!mounted) return;
        await obavijestProvider.oznaciKaoProcitanu(o.obavijestId!);
        if (!mounted) return;
        if (_filterJePogledana == false) {
          if (!mounted) return;
          _loadInitialData();
        } else {
          if (!mounted) return;
          setState(() {
            o.jePogledana = true;
          });
        }
      } catch (e) {
        if (!mounted) return;
        QuickAlert.show(
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

  Widget _buildObavijestiCards(Obavijest o) {
    return InkWell(
      onTap: () async {
        if (!mounted) return;
        try {
          if (!mounted) return;
            await _markAsRead(o);
            if (!mounted) return;
            Navigator.push(context,
              MaterialPageRoute(
                builder: (context) => ObavijestiDetailsScreen(obavijestId: o.obavijestId!),
              ),
            );
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
        height: 110,
        decoration: BoxDecoration(
          color: o.jePogledana
      ? Colors.white
      : const Color.fromARGB(255, 247, 238, 250), 
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
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        o.jePogledana
                        ? const Icon(
                            Icons.notifications_active_outlined,
                            color: Colors.black87,
                            size: 20,
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), 
                            decoration: BoxDecoration(
                              color: Colors.deepPurple, 
                              borderRadius: BorderRadius.circular(4), 
                              border: Border.all(
                                color: Colors.black26, 
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'NOVO',
                              style: TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),

                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            o.naslov,
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight: o.jePogledana ? FontWeight.w500 : FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatirajDatum(o.datumObavijesti),
                      style: TextStyle(
                        fontSize: 13,
                         color: o.jePogledana
                          ? Colors.grey
                          : const Color.fromARGB(255, 60, 58, 58),
                        fontWeight: o.jePogledana ? FontWeight.normal : FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                    const Divider(color: Colors.grey, thickness: 1),
                     Text(
                      o.sadrzaj,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: o.jePogledana ? FontWeight.normal : FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersAndInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade500, width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<bool?>(
                      value: _filterJePogledana,
                      hint: const Text("Odaberi opciju"),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      dropdownColor: Colors.white,
                      items: const [
                        DropdownMenuItem(value: null, child: Text("Sve obavijesti")),
                        DropdownMenuItem(value: true, child: Text("Stare obavijesti")),
                        DropdownMenuItem(value: false, child: Text("Nove obavijesti")),
                      ],
                      onChanged: (value) {
                        if (!mounted) return;
                        setState(() {
                          _filterJePogledana = value;
                          page = 1;
                          obavijestList.clear();
                          hasNextPage = true;
                        });
                        _loadInitialData();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Pretraži po nazivu obavijesti...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              page = 1;
                              _loadInitialData();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                  onSubmitted: (value) {
                    page = 1;
                    _loadInitialData();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Ukupan broj obavijesti: $total",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: Icon(
                  (_filterDatumOd != null || _filterDatumDo != null)
                      ? Icons.filter_alt
                      : Icons.filter_list,
                  color: (_filterDatumOd != null || _filterDatumDo != null)
                      ? Colors.deepPurple
                      : Colors.black87,
                ),
                onPressed: () => _showDateFilterDialog(),
              ),
            ],
          ),
        ],
      ),
    );
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
                          MaterialPageRoute(builder: (context) => const LoginPage()),
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

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: ColoredBox(
            color: Color.fromARGB(255, 247, 244, 247), 
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple, 
              ),
            ),
          ),
        ),
      );
    }

    final visibleList = obavijestList.where((f) => f.korisnikId == AuthProvider.korisnikId).toList();
    final itemCount = 1 + visibleList.length + 1;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 244, 247),
      body: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(10),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 25),
                  _buildFiltersAndInfo(),
                ],
              ),
            );
          }
          final listIndex = index - 1;
          if (listIndex < visibleList.length) {
            final e = visibleList[listIndex];
            return _buildObavijestiCards(e);
          }

          if (isLoadMoreRunning) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: 
            Center(
              child: visibleList.isEmpty
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_active, 
                          size: 40,
                          color: Color.fromARGB(255, 76, 72, 72),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Nema obavijesti za prikazati.",
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
                          "Nema više obavijesti za prikazati.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            )
          );
        },
      ),
      floatingActionButton: IgnorePointer(
        ignoring: !showbtn,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: showbtn ? 1.0 : 0.0,
          child: FloatingActionButton(
            onPressed: () {
              scrollController.animateTo(0,
                  duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
            },
            backgroundColor: const Color.fromARGB(255, 210, 193, 214),
            child: const Icon(Icons.arrow_upward, color: Colors.white),
          ),
        ),
      ),
    );
  }

}

