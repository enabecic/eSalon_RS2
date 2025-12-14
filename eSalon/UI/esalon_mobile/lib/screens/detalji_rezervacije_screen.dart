import 'package:esalon_mobile/providers/usluga_provider.dart';
import 'package:esalon_mobile/screens/usluga_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:esalon_mobile/models/rezervacija.dart';
import 'package:esalon_mobile/models/stavke_rezervacije.dart';
import 'package:esalon_mobile/providers/stavke_rezervacije_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:esalon_mobile/providers/utils.dart';

class DetaljiRezervacijeScreen extends StatefulWidget {
  final Rezervacija rezervacija;

  const DetaljiRezervacijeScreen({super.key, required this.rezervacija});

  @override
  State<DetaljiRezervacijeScreen> createState() => _DetaljiRezervacijeScreenState();
}

class _DetaljiRezervacijeScreenState extends State<DetaljiRezervacijeScreen> {
  late StavkeRezervacijeProvider _stavkeProvider;
  late UslugaProvider uslugaProvider;

  List<StavkeRezervacije> _stavkeRezervacije = [];
  bool _isLoading = true;
  final Map<String, Widget> _cachedImages = {};

  @override
  void initState() {
    super.initState();
    _stavkeProvider = context.read<StavkeRezervacijeProvider>();
    uslugaProvider = context.read<UslugaProvider>();
    _fetchStavke();
  }

  Future<void> _fetchStavke() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final filter = {'RezervacijaId': widget.rezervacija.rezervacijaId};
      final result = await _stavkeProvider.get(filter: filter);
      if (!mounted) return;
      setState(() {
        _stavkeRezervacije = result.result;
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.rezervacija;
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
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 16),
                          _buildInfoSection(r),
                          const SizedBox(height: 20),
                          _buildUkupnoBox(r),
                        ],
                      ),
                    ),
                  );
                },
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, 
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              "Detalji rezervacije #${widget.rezervacija.sifra ?? ''}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center, 
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Rezervacija r) {
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
          _buildInfoRow("Datum rezervacije:", formatDate(r.datumRezervacije.toString()), Icons.calendar_today),
          _buildInfoRow("Vrijeme:", "${r.vrijemePocetka?.substring(0, 5) ?? '/'} - ${r.vrijemeKraja?.substring(0, 5) ?? '/'}", Icons.access_time,),
          _buildInfoRow("Ukupno trajanje usluge/a:", "${r.ukupnoTrajanje ?? 0} min", Icons.timer,),
          _buildInfoRow("Ime i prezime klijenta:", r.klijentImePrezime ?? '/', Icons.person),
          _buildInfoRow("Ime i prezime frizera:", r.frizerImePrezime ?? '/', Icons.person_outline),
          _buildInfoRow("Status rezervacije:", r.stateMachine ?? '/', Icons.check_circle_outline,),
          _buildInfoRow("Način plaćanja:", r.nacinPlacanjaNaziv ?? '/', Icons.payment),
          _buildInfoRow("Aktivirana promocija:", r.aktiviranaPromocijaNaziv ?? '/', Icons.local_offer),
          const SizedBox(height: 8),
          _buildInfoRow("Usluge:", "", Icons.content_cut),
          const Divider(color: Colors.grey, thickness: 1),
          const SizedBox(height: 8),
          Text(
            "${_stavkeRezervacije.length} usluga/usluge",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ..._stavkeRezervacije.map((e) => _buildStavkeRow(e)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor ?? Colors.black, size: 20),
          const SizedBox(width: 10),
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          Expanded( 
            child: Padding(
              padding: const EdgeInsets.only(left: 16), 
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStavkeRow(StavkeRezervacije e) {
    return GestureDetector(
      onTap: () async {
        try {
          final uslugaDetalji = await uslugaProvider.getById(e.uslugaId!);
          if (!mounted) return;

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UslugaDetailsScreen(usluga: uslugaDetalji),
            ),
          );

        } catch (err) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              duration: Duration(milliseconds: 1800),
              content: Center(
                child: Text(
                  "Nemoguće otvoriti detalje usluge.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
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
                height: 130,
                child: (e.slika != null && e.slika!.isNotEmpty)
                    ? FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: (_cachedImages[e.slika!] ??= imageFromString(e.slika!)),
                      )
                    : Image.asset(
                        "assets/images/praznaUsluga.png",
                        fit: BoxFit.cover,
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
                    e.uslugaNaziv ?? '',
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
                      if (e.originalnaCijena != null && e.originalnaCijena! > (e.cijena ?? 0))
                        Text(
                          "${formatNumber(e.originalnaCijena)} KM",
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      if (e.originalnaCijena != null && e.originalnaCijena! > (e.cijena ?? 0))
                        const SizedBox(height: 2),
                      Text(
                        "${formatNumber(e.cijena ?? 0)} KM",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87, 
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUkupnoBox(Rezervacija r) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 210, 193, 214),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Ukupno:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(
            "${formatNumber(r.ukupnaCijena ?? 0)} KM",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}