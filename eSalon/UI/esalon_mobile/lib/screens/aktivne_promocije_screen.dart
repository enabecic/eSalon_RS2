import 'package:esalon_mobile/main.dart';
import 'package:esalon_mobile/models/search_result.dart';
import 'package:esalon_mobile/providers/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:esalon_mobile/models/promocija.dart';
import 'package:esalon_mobile/models/aktivirana_promocija.dart';
import 'package:esalon_mobile/providers/promocija_provider.dart';
import 'package:esalon_mobile/providers/aktivirana_promocija_provider.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AktivnePromocijeScreen extends StatefulWidget {
  const AktivnePromocijeScreen({super.key});

  @override
  State<AktivnePromocijeScreen> createState() => _AktivnePromocijeScreenState();
}

class _AktivnePromocijeScreenState extends State<AktivnePromocijeScreen> {
  late PromocijaProvider _promocijaProvider;
  late AktiviranaPromocijaProvider _aktiviranaProvider;
  List<Promocija> _aktivnePromocije = [];
  List<AktiviranaPromocija> _aktiviranePromocije = [];
  int page = 1;
  final int pageSize = 10;
  int total = 0;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  bool hasNextPage = true;
  bool showBtn = false;
  late final ScrollController scrollController;
  bool _isLoading = true;
  late TextEditingController _searchController;
  RangeValues? _popustFilter;
  final Map<String, Widget> _cachedImages = {};

  int _selectedTabIndex = 0; 
  final Map<int, bool> _itemLoading = {};

  @override
  void initState() {
    super.initState();
    _promocijaProvider = context.read<PromocijaProvider>();
    _aktiviranaProvider = context.read<AktiviranaPromocijaProvider>();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    _searchController = TextEditingController();
    _loadInitialData();
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _searchController.dispose();
    _cachedImages.clear();
    super.dispose();
  }

  void _onScroll() {
    const double showOffset = 10.0;
    if (scrollController.offset > showOffset) {
      if (!showBtn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => showBtn = true);
      });
    }

    } else {
     if (showBtn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => showBtn = false);
        });
      }
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
      isFirstLoadRunning = true;
      _isLoading = true;
    });

    try {
      final filter = <String, dynamic>{
        'SamoAktivne': true,
        'NazivOpisFTS': _searchController.text,
        'page': page,
        'pageSize': pageSize,
        'orderBy': 'DatumKraja',
        'sortDirection': 'asc',
        if (_popustFilter != null) 'PopustGTE': _popustFilter!.start,
        if (_popustFilter != null) 'PopustLTE': _popustFilter!.end,
      };
      if (!mounted) return; 
      final result = await _promocijaProvider.get(filter: filter);

      SearchResult<AktiviranaPromocija>? aktiviraneResult;
      if (AuthProvider.isSignedIn && AuthProvider.korisnikId != null) {
        if (!mounted) return; 
        aktiviraneResult = await _aktiviranaProvider.get(filter: {'KorisnikId': AuthProvider.korisnikId});
      }

      if (!mounted) return;
      setState(() {
        _aktivnePromocije = result.result;
        _aktiviranePromocije = aktiviraneResult?.result ?? [];
        total = _filteredList.length;
        hasNextPage = (page * pageSize) < result.count;
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
      if (!mounted) return;
      setState(() {
        isFirstLoadRunning = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!hasNextPage || isFirstLoadRunning || isLoadMoreRunning) return;
    if (!mounted) return;

    setState(() {
      isLoadMoreRunning = true;
      page += 1;
    });

    try {
      final filter = <String, dynamic>{
        'SamoAktivne': true,
        'NazivOpisFTS': _searchController.text,
        'page': page,
        'pageSize': pageSize,
        'orderBy': 'DatumKraja',
        'sortDirection': 'asc',
        if (_popustFilter != null) 'PopustGTE': _popustFilter!.start,
        if (_popustFilter != null) 'PopustLTE': _popustFilter!.end,
      };
      if (!mounted) return;
      final result = await _promocijaProvider.get(filter: filter);

      if (result.result.isNotEmpty) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _aktivnePromocije.addAll(result.result);

          total = _filteredList.length;
          hasNextPage = (page * pageSize) < result.count;
        });
      });
    } else {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => hasNextPage = false);
      });
    }
    } catch (e) {
      if (!mounted) return;
      setState(() => hasNextPage = false);
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => isLoadMoreRunning = false);
      });
    }
  }

  void _showSnack(String text, {bool success = true}) {
    final snack = SnackBar(
      content: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: success
          ? const Color.fromARGB(255, 138, 182, 140) 
          : Colors.red,
      duration: const Duration(milliseconds: 1500),
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  AktiviranaPromocija? _findAktiviranaByPromocijaId(int? promocijaId) {
    if (promocijaId == null) return null;
    try {
      return _aktiviranePromocije.firstWhere((p) =>
          p.promocijaId == promocijaId &&
          p.korisnikId == AuthProvider.korisnikId &&
          p.aktivirana == true &&
          p.iskoristena != true);
    } 
    catch (_) {
      return null;
    }
  }

  Future<void> _toggleActivationForPromocija(Promocija promocija) async {
    final pid = promocija.promocijaId;
    if (pid == null) return;

    final korisnikId = AuthProvider.korisnikId;

    if (korisnikId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 2000),
          content: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: RichText(
              text: const TextSpan(
                text: "Morate biti prijavljeni da biste aktivirali ovu promociju. ",
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
      );
      return; 
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _itemLoading[pid] = true);
    });

    try {
      final existing = _findAktiviranaByPromocijaId(pid);

      if (existing == null) {
        final request = {
          "promocijaId": pid,
          "korisnikId": korisnikId,
        };
        if (!mounted) return; 
        final dynamic result = await _aktiviranaProvider.insert(request);

        final newId = (result as AktiviranaPromocija).aktiviranaPromocijaId;

        final novi = AktiviranaPromocija(
          aktiviranaPromocijaId: newId,
          promocijaId: pid,
          korisnikId: korisnikId,
          aktivirana: true,
          iskoristena: false,
          datumAktiviranja: DateTime.now(),
          promocijaNaziv: promocija.naziv,
          kodPromocije: promocija.kod,
          slikaUsluge: promocija.slikaUsluge,
          popust: promocija.popust,
          datumPocetka: promocija.datumPocetka,
          datumKraja: promocija.datumKraja,
        );
        if (!mounted) return; 
        setState(() {
          _aktiviranePromocije.add(novi);
          total = _filteredList.length;
        });

        _showSnack("Uspješno aktivirana promocija.");
      } else {
        final idToDelete = existing.aktiviranaPromocijaId;
        if (idToDelete == null) throw UserException("Nepoznat ID za deaktivaciju.");
        if (!mounted) return; 
        await _aktiviranaProvider.delete(idToDelete);
        if (!mounted) return; 
        setState(() {
          _aktiviranePromocije.removeWhere((p) => p.aktiviranaPromocijaId == idToDelete);
          total = _filteredList.length;
        });

        _showSnack("Uspješno deaktivirana promocija.");
      }
    } catch (e) {
      _showSnack("Greška: ${e.toString()}", success: false);
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _itemLoading[pid] = false);
    });
    }
  }

  List<Promocija> get _filteredList {
    final aktiviraneNeiskoristeneIds = _aktiviranePromocije
        .where((p) =>
            p.korisnikId == AuthProvider.korisnikId &&
            p.aktivirana == true &&
            p.iskoristena != true)
        .map((p) => p.promocijaId)
        .toList();

    final iskoristeneIds = _aktiviranePromocije
        .where((p) => p.iskoristena == true && p.korisnikId == AuthProvider.korisnikId)
        .map((p) => p.promocijaId)
        .toList();

    if (_selectedTabIndex == 0) {
      return _aktivnePromocije
          .where((p) => !iskoristeneIds.contains(p.promocijaId))
          .toList();
    }

    if (_selectedTabIndex == 1) {
      return _aktivnePromocije
          .where((p) => aktiviraneNeiskoristeneIds.contains(p.promocijaId))
          .toList();
    }

    return _aktivnePromocije
        .where((p) =>
            !aktiviraneNeiskoristeneIds.contains(p.promocijaId) &&
            !iskoristeneIds.contains(p.promocijaId))
        .toList();
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(child: _tabItem("Sve promocije", 0)),
        const SizedBox(width: 8),
        Expanded(child: _tabItem("Aktivirane", 1)),
        const SizedBox(width: 8),
        Expanded(child: _tabItem("Neaktivirane", 2)),
      ],
    );
  }

  Widget _tabItem(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        if (!mounted) return;

        if (!AuthProvider.isSignedIn && index != 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              duration: const Duration(milliseconds: 1500),
              content: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    text: "Morate biti prijavljeni da biste vidjeli aktivirane/neaktivirane promocije. ",
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
          );
          return; 
        }
        if (!mounted) return; 
        setState(() {
          _selectedTabIndex = index;
          total = _filteredList.length;
        });
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 210, 193, 214)
              : const Color.fromARGB(255, 133, 131, 133).withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 15,
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
            Text(
              "Trenutno aktivne promocije",
              style: TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.local_offer,
              color: Colors.black,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromocijaItem(Promocija promocija) {
    final pid = promocija.promocijaId;
    final aktivirana = _findAktiviranaByPromocijaId(pid) != null;
    final isLoadingItem = pid != null && (_itemLoading[pid] == true);

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildImage(promocija.slikaUsluge),
            ),
            const SizedBox(height: 10),
            Text(
              promocija.naziv ?? "",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.local_offer, color: Colors.redAccent, size: 16),
                const SizedBox(width: 6),
                Text(
                  "-${promocija.popust != null ? promocija.popust!.round() : 0}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "na ${promocija.uslugaNaziv ?? ''}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.redAccent,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Vrijedi do ${promocija.datumKraja != null ? formatDate(promocija.datumKraja!.toIso8601String()) : ""}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: isLoadingItem
                        ? null
                        : () {
                            _toggleActivationForPromocija(promocija);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: aktivirana
                          ? const Color.fromARGB(255, 133, 131, 133).withOpacity(0.3) 
                          : const Color.fromARGB(255, 210, 193, 214), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
                      elevation: 0,
                    ),
                    child: isLoadingItem
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                          )
                        : Text(
                            aktivirana ? "Deaktiviraj" : "Aktiviraj",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? slikaBase64) {
    if (slikaBase64 == null || slikaBase64.isEmpty) {
      return Image.asset(
        "assets/images/praznaUsluga.png",
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    final key = slikaBase64;

    final widget = _cachedImages[key] ??= SizedBox(
      height: 140,
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: imageFromString(slikaBase64),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleList = _filteredList;
    final itemCount = 1 + visibleList.length + 1;

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 15),
                        _buildTabs(),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Pretraži po nazivu ili opisu",
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          ),
                          onChanged: (value) {
                            if (!mounted) return;
                            setState(() {}); 
                          },
                          onSubmitted: (value) {
                            page = 1;
                            _loadInitialData(); 
                          },
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Ukupan broj promocija: $total",
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_popustFilter != null)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6.0),
                                    child: Text(
                                      "${_popustFilter!.start.round()}% - ${_popustFilter!.end.round()}%",
                                      style: const TextStyle(
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  icon: Icon(
                                    _popustFilter != null ? Icons.filter_alt : Icons.filter_list,
                                    color: _popustFilter != null ? Colors.deepPurple : Colors.black87,
                                  ),
                                  onPressed: () async {
                                    if (!mounted) return; 
                                    final result = await showDialog<RangeValues>(
                                      context: context,
                                      builder: (context) {
                                        double start = _popustFilter?.start ?? 0;
                                        double end = _popustFilter?.end ?? 100;

                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return AlertDialog(
                                              title: const Text("Filtriraj po popustu"),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text("Od: ${start.round()}% do: ${end.round()}%"),
                                                  RangeSlider(
                                                    values: RangeValues(start, end),
                                                    min: 0,
                                                    max: 100,
                                                    divisions: 20,
                                                    labels: RangeLabels("${start.round()}%", "${end.round()}%"),
                                                    onChanged: (values) {
                                                      if (!mounted) return;
                                                      setState(() {
                                                        start = values.start;
                                                        end = values.end;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, null),
                                                  child: const Text("Otkaži"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(context, RangeValues(start, end)),
                                                  child: const Text("Filtriraj"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );

                                    if (result != null) {
                                      _popustFilter = result;
                                    } else {
                                      _popustFilter = null;
                                    }

                                    page = 1;
                                    _loadInitialData();
                                    if (!mounted) return; 
                                    setState(() {}); 
                                  },
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  );
                }

                final listIndex = index - 1;

                if (listIndex < visibleList.length) {
                  final p = visibleList[listIndex];
                  return _buildPromocijaItem(p);
                }

                if (isLoadMoreRunning) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          visibleList.isEmpty
                              ? "Trenutno nema promocija za prikazati."
                              : "Nema više promocija za prikazati.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: IgnorePointer(
        ignoring: !showBtn,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: showBtn ? 1.0 : 0.0,
          child: FloatingActionButton(
            onPressed: () {
              scrollController.animateTo(0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn);
            },
            backgroundColor: const Color.fromARGB(255, 210, 193, 214),
            child: const Icon(Icons.arrow_upward, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
