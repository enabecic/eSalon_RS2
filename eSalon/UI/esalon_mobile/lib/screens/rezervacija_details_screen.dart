import 'package:esalon_mobile/layouts/master_screen.dart';
import 'package:esalon_mobile/models/nacin_placanja.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/korisnik_provider.dart';
import 'package:esalon_mobile/providers/nacin_placanja_provider.dart';
import 'package:esalon_mobile/providers/rezervacija_cart_provider.dart';
import 'package:esalon_mobile/providers/rezervacija_provider.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class RezervacijaDetailsScreen extends StatefulWidget {
  final int frizerId;
  final DateTime datumRezervacije;
  final TimeOfDay vrijemePocetka;
  final String? kodPromocije;
  final RezervacijaCartProvider rezervacijaCartProvider;

  const RezervacijaDetailsScreen({
    super.key,
    required this.frizerId,
    required this.datumRezervacije,
    required this.vrijemePocetka,
    this.kodPromocije,
     required this.rezervacijaCartProvider,
  });

  @override
  State<RezervacijaDetailsScreen> createState() =>
      _RezervacijaDetailsScreenState();
}

class _RezervacijaDetailsScreenState extends State<RezervacijaDetailsScreen> {

  bool _isSaving = false;
  RezervacijaCartProvider? rezervacijaCartProvider;
  late RezervacijaProvider rezervacijaProvider;
  Map<String, dynamic> usluge = {};
  bool _isLoadingUsluge = true;

  late KorisnikProvider korisnikProvider;
  String frizerImePrezime = "";
  bool _isLoadingFrizer = true;

  late NacinPlacanjaProvider nacinPlacanjaProvider;
  String nacinPlacanjaNaziv = ""; 

  bool _placanjeOdabrano = false; 
  List<NacinPlacanja> _naciniPlacanja = [];
  bool _isLoadingPlacanja = true;
  int? _selectedNacinPlacanjaId;
   
  final Map<int, Image> _cachedImages = {}; 
  double _ukupnaCijena = 0.0;

  @override
  void initState() {
    super.initState();
    rezervacijaProvider = context.read<RezervacijaProvider>();
    korisnikProvider = context.read<KorisnikProvider>();
    nacinPlacanjaProvider = context.read<NacinPlacanjaProvider>();
    if (AuthProvider.korisnikId != null) {
      rezervacijaCartProvider = widget.rezervacijaCartProvider;
      _loadUsluge();
      _loadFrizer();
      _loadPlacanja();
    }
  }

  Future<void> _loadPlacanja() async {
    if (!mounted) return;
    setState(() => _isLoadingPlacanja = true);

    try {
      if (!mounted) return;
      final data = await nacinPlacanjaProvider.get();
      if (!mounted) return;
      setState(() {
        _naciniPlacanja = data.result;
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
      if (mounted) setState(() => _isLoadingPlacanja = false);
    }
  }

  Future<void> _loadFrizer() async {
    if (widget.frizerId == 0) return;
    if (!mounted) return;
    setState(() => _isLoadingFrizer = true);

    try {
      if (!mounted) return;
      final frizer = await korisnikProvider.getById(widget.frizerId); 
      if (!mounted) return;
      setState(() {
        frizerImePrezime = "${frizer.ime} ${frizer.prezime}";
        _isLoadingFrizer = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingFrizer = false);
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

  Future<void> _loadUsluge() async {
    if (rezervacijaCartProvider == null) return;
    if (!mounted) return;
    setState(() => _isLoadingUsluge = true);

    try {
      if (!mounted) return;
      final lista = await rezervacijaCartProvider!.getRezervacijaList();
      if (!mounted) return;
      setState(() {
        usluge = lista;
        _isLoadingUsluge = false; 
        _updateUkupnaCijena();
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

  Future<bool> _saveGotovina() async {
    if (!mounted) return false;
    setState(() => _isSaving = true);

    try {
      final request = {
        "korisnikId": AuthProvider.korisnikId,
        "frizerId": widget.frizerId,
        "datumRezervacije": widget.datumRezervacije.toIso8601String(),
        "vrijemePocetka":
            "${widget.vrijemePocetka.hour.toString().padLeft(2, '0')}:${widget.vrijemePocetka.minute.toString().padLeft(2, '0')}:00",
        "nacinPlacanjaId": _selectedNacinPlacanjaId,
        "kodPromocije": widget.kodPromocije?.isEmpty ?? true ? null : widget.kodPromocije,
        "stavkeRezervacije": usluge.values.map((u) => {"uslugaId": u['id']}).toList(),
      };
      if (!mounted) return false;
      await rezervacijaProvider.insert(request);
      if (!mounted) return false;
      await rezervacijaCartProvider?.clearRezervacijaList();
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromARGB(255, 138, 182, 140),
          duration: Duration(milliseconds: 1800),
          content: Center(
            child: Text(
              "Uspješno kreirana rezervacija.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 1800),
          content: Center(
            child: Text(
              e.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _savePaypal() async {
    // 
    return false; //
  }
  
  Future<bool> _saveRezervaciju() async {
    if (_isSaving) return false;

    if (_selectedNacinPlacanjaId == null) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 1800),
          content: Center(
            child: Text(
              'Molimo odaberite način plaćanja.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
      return false;
    }

    if (usluge.isEmpty) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 1800),
          content: Center(
            child: Text(
              'Morate imati barem jednu uslugu u korpi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
      return false;
    }

    final odabraniNacin = _naciniPlacanja.firstWhere((x) => x.nacinPlacanjaId == _selectedNacinPlacanjaId,);
    final nazivPlacanja = (odabraniNacin.naziv ?? "").toLowerCase();

    if (nazivPlacanja == "gotovina") {
      if (!mounted) return false;
      return await _saveGotovina();
    } else if (nazivPlacanja.contains("paypal")) {
      if (!mounted) return false;
      return await _savePaypal();
    } else {
      return false;
    }
  }

  Widget _buildNaciniPlacanja() {
    if (_isLoadingPlacanja) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: _naciniPlacanja.map((nacin) {
        bool isSelected = _selectedNacinPlacanjaId == nacin.nacinPlacanjaId;

        IconData icon = Icons.payments;
        if ((nacin.naziv ?? "").toLowerCase().contains("gotovina")) {
          icon = Icons.attach_money;
        } else if ((nacin.naziv ?? "").toLowerCase().contains("paypal")) {
          icon = Icons.credit_card;
        }

        return GestureDetector(
          onTap: () {
            if (!mounted) return;
            setState(() {
              _selectedNacinPlacanjaId = nacin.nacinPlacanjaId;
              _placanjeOdabrano = true;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(255, 247, 238, 250)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, size: 30, color: Colors.black87),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    nacin.naziv ?? "",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if ((nacin.naziv ?? "").toLowerCase().contains("paypal"))
                  const Text(
                    '>',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildZavrsiButton() {
    bool canClick = !_isSaving && !_isLoadingUsluge && !_isLoadingFrizer && !_isLoadingPlacanja && _placanjeOdabrano;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(
          color: Colors.grey,
          thickness: 1,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canClick
                ? () async {
                    if (!mounted) return;
                    final potvrda = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Potvrda"),
                        content: const Text(
                            "Da li ste sigurni da želite kreirati rezervaciju?"),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              "Ne",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              "Da",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (potvrda == true) {
                      if (!mounted) return;
                      bool ok = await _saveRezervaciju();
                      if (!mounted) return;
                      if (ok) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MasterScreen(),
                          ),
                        );
                      }
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canClick ? const Color(0xFFD2C1D6) : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 6,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.deepPurple,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Završi rezervaciju",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRowValueOnly(
            Icons.calendar_today,
            formatirajDatumSaDanom(widget.datumRezervacije),
          ),
          _buildInfoRowValueOnly(
            Icons.access_time,
            "${formatTime24(widget.vrijemePocetka)} - ${formatTime24(calculateEndTime())} (${calculateTotalDuration()}min)",
          ),
          _buildInfoRow(
            "Frizer:",
            _isLoadingFrizer ? "Učitavanje..." : frizerImePrezime,
            Icons.person_outline
          ),
          const SizedBox(height: 8),
          const Padding(
          padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.content_cut, color: Colors.black, size: 20),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Usluge:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey, thickness: 1),
          const SizedBox(height: 8),
          if (_isLoadingUsluge)
            const Center(child: CircularProgressIndicator())
          else if (usluge.isEmpty)
            const Text("Nema odabranih usluga.")
          else ...[
            Text(
              "${usluge.length} usluga/usluge",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...usluge.values.map((u) => _buildUslugaRow(u)),

            const SizedBox(height: 12),
            const Divider(thickness: 1),
            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Ukupna cijena: ${_ukupnaCijena.toStringAsFixed(2)} KM",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildInfoRowValueOnly(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 20),
          const SizedBox(width: 6), 
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  int calculateTotalDuration() {
    int totalMinutes = 0;
    for (var u in usluge.values) {
      totalMinutes += (u['trajanje'] ?? 0) as int; 
    }
    return totalMinutes;
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 20),
          const SizedBox(width: 6), 
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  TimeOfDay calculateEndTime() {
    if (usluge.isEmpty) {
      return widget.vrijemePocetka;
    }
    int totalMinutes = 0;
    for (var u in usluge.values) {
      totalMinutes += (u['trajanje'] ?? 0) as int; 
    }
    int startMinutes = widget.vrijemePocetka.hour * 60 + widget.vrijemePocetka.minute;
    int endMinutes = startMinutes + totalMinutes;
    if (endMinutes > 16 * 60) {
      endMinutes = 16 * 60;
    }
    int endHour = endMinutes ~/ 60;
    int endMinute = endMinutes % 60;
    return TimeOfDay(hour: endHour, minute: endMinute);
  }

  void _updateUkupnaCijena() {
    double total = 0;
    for (var u in usluge.values) {
      double cijena = (u['cijena'] ?? 0).toDouble();
      if (rezervacijaCartProvider?.popustUslugaId == u['id']) {
        final popust = rezervacijaCartProvider?.popustIznos ?? 0;
        cijena = cijena - (cijena * popust / 100);
      }
      total += cijena;
    }
    if (!mounted) return;
    setState(() {
      _ukupnaCijena = total;
    });
  }

  Widget _buildUslugaRow(Map<String, dynamic> u) {

    bool imaPopust =
    rezervacijaCartProvider?.popustUslugaId == u['id'];
    double punaCijena = (u['cijena'] ?? 0).toDouble();
    double snizenaCijena = punaCijena;
    if (imaPopust) {
      final popust = rezervacijaCartProvider?.popustIznos ?? 0;
      snizenaCijena = punaCijena - (punaCijena * popust / 100);
    }

    Image imgWidget;

    if (u['slika'] != null && u['slika'].isNotEmpty) {
      if (_cachedImages.containsKey(u['id'])) {
        imgWidget = _cachedImages[u['id']]!;
      } else {
        imgWidget = imageFromString(u['slika']); 
        _cachedImages[u['id']] = imgWidget;
      }
    } else {
      imgWidget = Image.asset(
        "assets/images/praznaUsluga.png",
        fit: BoxFit.cover,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 100,
              height: 120,
              child: FittedBox(
                fit: BoxFit.cover,
                child: imgWidget,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  u['naziv'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imaPopust) ...[
                      Text(
                        "${punaCijena.toStringAsFixed(2)} KM",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${snizenaCijena.toStringAsFixed(2)} KM",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ] else ...[
                      Text(
                        "${punaCijena.toStringAsFixed(2)} KM",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
          backgroundColor: const Color.fromARGB(255, 247, 244, 247),
          automaticallyImplyLeading: false,
          toolbarHeight: kToolbarHeight + 25,
          surfaceTintColor: Colors.transparent,
          forceMaterialTransparency: false,
          title: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black, size: 40),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildInfoBox(),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Odaberite način plaćanja:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildNaciniPlacanja(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildZavrsiButton(),
            ],
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
                "Pregled rezervacije",
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
            Icon(Icons.event_available, color: Colors.black, size: 28),
          ],
        ),
      ),
    );
  }
}
