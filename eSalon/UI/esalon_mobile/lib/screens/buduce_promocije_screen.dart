import 'package:esalon_mobile/screens/promocija_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:esalon_mobile/models/promocija.dart';
import 'package:esalon_mobile/providers/promocija_provider.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class BuducePromocijeScreen extends StatefulWidget {
  const BuducePromocijeScreen({super.key});

  @override
  State<BuducePromocijeScreen> createState() => _BuducePromocijeScreenState();
}

class _BuducePromocijeScreenState extends State<BuducePromocijeScreen> {
  late PromocijaProvider _promocijaProvider;
  List<Promocija> _buducePromocije = [];
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

  @override
  void initState() {
    super.initState();
    _promocijaProvider = context.read<PromocijaProvider>();
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
      if (!mounted) return;
      if (!showBtn) setState(() => showBtn = true);
    } else {
      if (!mounted) return;
      if (showBtn) setState(() => showBtn = false);
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
        'SamoBuduce': true,
        'NazivOpisFTS': _searchController.text,
        'page': page,
        'pageSize': pageSize,
        'orderBy': 'DatumPocetka',
        'sortDirection': 'asc',
        if (_popustFilter != null) 'PopustGTE': _popustFilter!.start,
        if (_popustFilter != null) 'PopustLTE': _popustFilter!.end,
      };
      if (!mounted) return;
      final result = await _promocijaProvider.get(filter: filter);
      if (!mounted) return;
      setState(() {
        _buducePromocije = result.result;
        total = result.count;
        hasNextPage = (page * pageSize) < total;
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
      if (mounted) {
        setState(() {
          isFirstLoadRunning = false;
         _isLoading = false;
        });
      }
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
        'SamoBuduce': true,
        'NazivOpisFTS': _searchController.text,
        'page': page,
        'pageSize': pageSize,
        'orderBy': 'DatumPocetka',
        'sortDirection': 'asc',
        if (_popustFilter != null) 'PopustGTE': _popustFilter!.start,
        if (_popustFilter != null) 'PopustLTE': _popustFilter!.end,
      };
      if (!mounted) return;
      final result = await _promocijaProvider.get(filter: filter);
      if (!mounted) return;

      if (result.result.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _buducePromocije.addAll(result.result);
          total = result.count;
          hasNextPage = (page * pageSize) < total;
        });
      } else {
        if (!mounted) return;
        setState(() => hasNextPage = false);
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
      ),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible( 
              child: Text(
                "Buduće promocije",
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
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PromocijaDetailsScreen(promocija: promocija),
          ),
        );
      },
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
            const SizedBox(height: 4),
            Text(
              "${promocija.datumPocetka != null ? formatDate(promocija.datumPocetka!.toIso8601String()) : ""} - "
              "${promocija.datumKraja != null ? formatDate(promocija.datumKraja!.toIso8601String()) : ""}",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? slikaBase64) {
    if (slikaBase64 == null || slikaBase64.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          "assets/images/praznaUsluga.png",
          height: 140,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
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
    final visibleList = _buducePromocije;
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
                        const Text(
                          "Otkrijte posebne ponude i ostvarite popuste koji uskoro postaju dostupni!",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Pretraži po nazivu ili opisu...",
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
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Ukupan broj budućih promocija: $total",
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
                  return _buildPromocijaItem(visibleList[listIndex]);
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
                              ? "Trenutno nema budućih promocija."
                              : "Nema više budućih promocija za prikazati.",
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
