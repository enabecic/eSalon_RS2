import 'package:esalon_desktop/providers/utils.dart';
import 'package:esalon_desktop/screens/frizer_obavijest_details.dart';
import 'package:flutter/material.dart';
import 'package:esalon_desktop/models/obavijest.dart';
import 'package:esalon_desktop/providers/obavijest_provider.dart';
import 'package:esalon_desktop/providers/auth_provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class FrizerObavijestScreen extends StatefulWidget {
  final VoidCallback? onObavijestRead;//
  const FrizerObavijestScreen({super.key , this.onObavijestRead});//

  @override
  State<FrizerObavijestScreen> createState() => _FrizerObavijestScreenState();
}

class _FrizerObavijestScreenState extends State<FrizerObavijestScreen> {
  List<Obavijest> obavijesti = [];
  bool isLoadMoreRunning = false;
  bool hasNextPage = true;
  int page = 1;
  final int limit = 10;
  final ScrollController scrollController = ScrollController();
  Map<int, bool> hoverMap = {};
  late ObavijestProvider obavijestProvider = ObavijestProvider();

  bool? _filterJePogledana;

  @override
  void initState() {
    super.initState();
    _loadObavijesti();
    scrollController.addListener(_loadMoreOnScroll);
  }

  Future<void> _loadObavijesti() async {
    if (!mounted) return;
    setState(() => isLoadMoreRunning = true);
    if (!mounted) return;
    var result = await obavijestProvider.get(
      filter: <String, dynamic>{
        'KorisnikId': AuthProvider.korisnikId,
        if (_filterJePogledana != null) 'JePogledana': _filterJePogledana,
      },
      pageSize: limit,
      page: 1,
      orderBy: 'DatumObavijesti',
      sortDirection: 'desc',
    );

    if (!mounted) return;

    List<Obavijest> filtered = result.result.map((e) => e).toList();

    setState(() {
      obavijesti = filtered;
      hasNextPage = filtered.length >= limit;
      isLoadMoreRunning = false;
      page = 1;
    });
  }

  void _loadMoreOnScroll() async {
    if (!mounted || isLoadMoreRunning || !hasNextPage) return;

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      setState(() => isLoadMoreRunning = true);
      page++;
      if (!mounted) return;
      var result = await obavijestProvider.get(
        filter: <String, dynamic>{
          'KorisnikId': AuthProvider.korisnikId,
          if (_filterJePogledana != null) 'JePogledana': _filterJePogledana,
        },
        pageSize: limit,
        page: page,
        orderBy: 'DatumObavijesti',
        sortDirection: 'desc',
      );

      if (!mounted) return;

      List<Obavijest> more = result.result.map((e) => e).toList();

      setState(() {
        obavijesti.addAll(more);
        hasNextPage = more.length >= limit;
        isLoadMoreRunning = false;
      });
    }
  }

  Future<void> _markAsRead(Obavijest o) async {
    if (!o.jePogledana) { 
      try {
        if (!mounted) return;
        await obavijestProvider.oznaciKaoProcitanu(o.obavijestId);
        if (!mounted) return;

        if (_filterJePogledana == false) {
          if (!mounted) return;
          await _loadObavijesti();
        } else {
          setState(() {
            o.jePogledana = true;
          });
        }

        widget.onObavijestRead?.call();//
      } catch (e) {
        if (!mounted) return;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: e.toString(), 
          title: 'Greška',
          confirmBtnText: 'OK',
          confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
          textColor: Colors.black,
          titleColor: Colors.black,
        );
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
          child: Text(
            "Obavijesti",
            style: TextStyle(fontSize: 26, color: Colors.black),
          ),
        ),
        _buildFilterRow(), 
        _buildObavijestiCards(), 
      ],
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Text(
            "Pretraga po pregledanosti: ",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(width: 8),
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
                    DropdownMenuItem(value: null, child: Text("Sve")),
                    DropdownMenuItem(value: true, child: Text("Pregledane")),
                    DropdownMenuItem(value: false, child: Text("Nepregledane")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterJePogledana = value;
                    });
                    _loadObavijesti();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 180, 140, 218),
              foregroundColor: const Color.fromARGB(199, 0, 0, 0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(150, 63),
            ),
            onPressed: () {
              setState(() {
                _filterJePogledana = null;
              });
              _loadObavijesti();
            },
            child: const Text("Očisti"),
          ),
        ],
      ),
    );
  }

  Widget _buildObavijestiCards() {
    return Expanded(
      child: Container(
        color: const Color.fromARGB(255, 251, 240, 255),
        width: double.infinity,
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      ...obavijesti.asMap().entries.map((entry) {
                        int index = entry.key;
                        var o = entry.value;
                        bool isHovered = hoverMap[index] ?? false;

                        return MouseRegion(
                          onEnter: (_) {
                            setState(() => hoverMap[index] = true);
                          },
                          onExit: (_) {
                            setState(() => hoverMap[index] = false);
                          },
                          child: InkWell(
                            onTap: () async {
                              await _markAsRead(o);
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FrizerObavijestDetailsScreen(
                                          obavijest: o),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              width: double.infinity,
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(20),
                              margin:
                                  const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isHovered
                                    ? const Color(0xFFE0D7F5)
                                    : (o.jePogledana
                                        ? Colors.white
                                        :const Color.fromARGB(255, 192, 181, 195)),

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
                                    "Obavijest: ${o.naslov.length > 70 ? '${o.naslov.substring(0, 70)}...' : o.naslov}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: o.jePogledana
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: o.jePogledana
                                          ? Colors.black87
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Datum obavijesti: ${formatirajDatum(o.datumObavijesti)}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: o.jePogledana
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: o.jePogledana
                                          ? Colors.black87
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Sadržaj: ${o.sadrzaj.length > 75 ? '${o.sadrzaj.substring(0, 75)}...' : o.sadrzaj}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: o.jePogledana
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: o.jePogledana
                                          ? Colors.black87
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      if (isLoadMoreRunning)
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(),
                        ),
                      if (!hasNextPage)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            "Nema obavijesti za prikazati.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Visibility(
                visible: scrollController.hasClients &&
                    scrollController.offset > 300,
                child: FloatingActionButton(
                  onPressed: () {
                    scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    );
                  },
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  mini: false,
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
