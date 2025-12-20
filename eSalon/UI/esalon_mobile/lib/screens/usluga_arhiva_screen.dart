import 'package:esalon_mobile/main.dart';
import 'package:esalon_mobile/providers/usluga_provider.dart';
import 'package:esalon_mobile/screens/usluga_details_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:esalon_mobile/models/ocjena.dart';
import 'package:esalon_mobile/models/arhiva.dart';
import 'package:esalon_mobile/models/search_result.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/ocjena_provider.dart';
import 'package:esalon_mobile/providers/arhiva_provider.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class UslugaArhivaScreen extends StatefulWidget {
  const UslugaArhivaScreen({super.key});

  @override
  State<UslugaArhivaScreen> createState() => _UslugaArhivaScreenState();
}

class _UslugaArhivaScreenState extends State<UslugaArhivaScreen> {
  late ArhivaProvider uslugaArhivaProvider;
  late OcjenaProvider ocjenaProvider;
  late UslugaProvider uslugaProvider;

  SearchResult<Ocjena>? ocjenaResult;
  Map<String, dynamic> searchRequest = {};

  List<Arhiva> arhivaList = [];
  int page = 1;

  final int pageSize = 10;
  int total = 0;
  bool isFirstLoadRunning = false;
  bool hasNextPage = true;
  bool showbtn = false;
  Map<int, int> brojArhiviranjaMap = {};

  bool isLoadMoreRunning = false;
  late final ScrollController scrollController;

  bool _isLoading = true;
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    searchRequest = {
      'KorisnikId': AuthProvider.korisnikId,
      'orderBy': 'DatumDodavanja',
      'sortDirection': 'desc',
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    uslugaArhivaProvider = context.read<ArhivaProvider>();
    ocjenaProvider = context.read<OcjenaProvider>();
    uslugaProvider = context.read<UslugaProvider>();

    if (!_initialLoaded) {
      _initialLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialData();
      });
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      if (!mounted) return;
      await _firstLoad();
      if (!mounted) return;
      await _loadBrojArhiviranja();
      if (!mounted) return;
      await _initForm();
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
        });
      }
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

  Future<void> _initForm() async {
    try {
      if (!mounted) return;
      final r = await ocjenaProvider.get();
      if (!mounted) return;
      setState(() {
        ocjenaResult = r;
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
    }
  }

  Future<void> _firstLoad() async {
    if (!mounted) return;

    setState(() {
      isFirstLoadRunning = true;
      //arhivaList = [];
      page = 1;
      hasNextPage = true;
      isLoadMoreRunning = false;
    });

    try {
      if (AuthProvider.isSignedIn) {
        if (!mounted) return;
        final arhivaResult = await uslugaArhivaProvider.get(
          filter: searchRequest,
          page: page,
          pageSize: pageSize,
        );

        if (!mounted) return;

        setState(() {

          arhivaList = arhivaResult.result;
          total = arhivaResult.count;
          hasNextPage = (page * pageSize) < total;
        });
      } else {
        if (!mounted) return;
        setState(() {
          arhivaList = [];
          total = 0;
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
      final result = await uslugaArhivaProvider.get(
        filter: searchRequest,
        page: page,
        pageSize: pageSize,
      );

      if (!mounted) return;

      if (result.result.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          arhivaList.addAll(result.result);
          total = result.count;
          hasNextPage = (page * pageSize) < total;
        });
        if (!mounted) return;
        await _loadBrojArhiviranja();
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

  final Map<String, Widget> _cachedImages = {};

  Widget _buildImage(String? base64OrNull) {
    if (base64OrNull == null || base64OrNull.trim().isEmpty) {
      return Image.asset("assets/images/praznaUsluga.png", fit: BoxFit.cover);
    }

    if (_cachedImages.containsKey(base64OrNull)) {
      return _cachedImages[base64OrNull]!;
    }

    try {
      final widget = imageFromString(base64OrNull);
      _cachedImages[base64OrNull] = widget;
      return widget;
    } catch (e) {
      final fallback = Image.asset("assets/images/praznaUsluga.png", fit: BoxFit.cover);
      _cachedImages[base64OrNull] = fallback;
      return fallback;
    }
  }

  Future<void> _loadBrojArhiviranja() async {
    for (var e in arhivaList) {
      if (e.uslugaId != null && !brojArhiviranjaMap.containsKey(e.uslugaId)) {
        try {
          if (!mounted) return;
          int broj = await uslugaArhivaProvider.getBrojArhiviranja(e.uslugaId!);
          brojArhiviranjaMap[e.uslugaId!] = broj;
        } catch (_) {
          brojArhiviranjaMap[e.uslugaId!] = 0;
        }
        if (!mounted) return;
        setState(() {});
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
                "Moja lista 'Želim probati'",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1, 
                overflow: TextOverflow.ellipsis, 
              ),
            ),
            SizedBox(width: 2),
            Icon(
              Icons.bookmark,
              color: Colors.black,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArhivaItem(Arhiva e) {
    return InkWell(
       onTap: () async {
        if (!mounted) return;
          try {
            if (!mounted) return;
            final usluga = await uslugaProvider.getById(e.uslugaId!);
            if (!mounted) return;
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UslugaDetailsScreen(usluga: usluga),
              ),
            );

            if (result == true) {
              if (!mounted) return;
              await _loadInitialData();
            }

          }catch (e) {
          if (!mounted) return;
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
        height: 95,
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
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        width: double.infinity,
        child: Slidable(
          startActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
                  if (!mounted) return;
                  await uslugaArhivaProvider.delete(e.arhivaId!);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color.fromARGB(255, 138, 182, 140),
                      duration: Duration(seconds: 1),
                      content: Center(child: Text("Uspješno izbačeno iz liste 'Želim probati'.")),
                    ),
                  );
                  if (!mounted) return;
                  await _firstLoad();
                  if (!mounted) return;
                  await _loadBrojArhiviranja();
                },
                backgroundColor: Colors.red,
                icon: Icons.delete,
                label: 'Obriši',
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: _buildImage(e.slika),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        e.uslugaNaziv ?? "",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.cijena != null ? "${formatNumber(e.cijena)} KM" : "",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.yellow, size: 18),
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
                          Row(
                            children: [
                              const Icon(
                                Icons.bookmark_outline,
                                color: Color.fromARGB(255, 108, 108, 108),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                brojArhiviranjaMap[e.uslugaId]?.toString() ?? '0',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 108, 108, 108),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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

    final visibleList = arhivaList.where((f) => f.korisnikId == AuthProvider.korisnikId).toList();
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
                  const SizedBox(height: 15),
                  const Text(
                    "Imajte svoje usluge koje želite probati u skorije vrijeme sve na jednom mjestu!",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 17),
                  Text(
                    "Ukupan broj usluga: $total",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          final listIndex = index - 1;
          if (listIndex < visibleList.length) {
            final e = visibleList[listIndex];
            return _buildArhivaItem(e);
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
                          Icons.cut, 
                          size: 40,
                          color: Color.fromARGB(255, 76, 72, 72),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Nemate usluga u listi 'Želim probati'.",
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
                          "Nema više usluga u listi 'Želim probati' za prikazati.",
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

  dynamic _avgOcjena(int? uslugaId) {
    if (ocjenaResult == null || ocjenaResult!.result.isEmpty) return 0;
    final ocjene = ocjenaResult!.result.where((o) => o.uslugaId == uslugaId).toList();
    if (ocjene.isEmpty) return 0;
    double avg = ocjene.map((o) => o.vrijednost ?? 0).reduce((a, b) => a + b) / ocjene.length;
    return formatNumber(avg);
  }
}

