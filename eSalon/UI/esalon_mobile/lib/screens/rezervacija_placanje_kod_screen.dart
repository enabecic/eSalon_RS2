import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/rezervacija_cart_provider.dart';
import 'package:esalon_mobile/providers/rezervacija_provider.dart';
import 'package:esalon_mobile/screens/rezervacija_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class RezervacijaPlacanjeKodScreen extends StatefulWidget {
  final int frizerId;
  final DateTime datumRezervacije;
  final TimeOfDay vrijemePocetka;

  const RezervacijaPlacanjeKodScreen({
    super.key,
    required this.frizerId,
    required this.datumRezervacije,
    required this.vrijemePocetka,
  });

  @override
  State<RezervacijaPlacanjeKodScreen> createState() =>
      _RezervacijaPlacanjeKodScreenState();
}

class _RezervacijaPlacanjeKodScreenState
    extends State<RezervacijaPlacanjeKodScreen> {

  late RezervacijaProvider rezervacijaProvider;
  String? _kodUnos;

  bool _isSaving = false;
  RezervacijaCartProvider? rezervacijaCartProvider;
  Map<String, dynamic> usluge = {};
  late TextEditingController _kodController;
    
  @override
  void initState() {
    super.initState();
    rezervacijaProvider = context.read<RezervacijaProvider>();
    if (AuthProvider.korisnikId != null) {
      rezervacijaCartProvider = RezervacijaCartProvider(AuthProvider.korisnikId!);
    }
    _kodController = TextEditingController();
  }

  Future<bool> _saveRezervaciju() async {
    if (_isSaving) return false;

    if (rezervacijaCartProvider == null) return false;

    try {
      if (!mounted) return false;
      usluge = await rezervacijaCartProvider!.getRezervacijaList();
    } catch (e) {
      if (!mounted) return false;
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Greška',
          text: e.toString(),
          confirmBtnText: 'OK',
          confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
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

    final request = {
      "korisnikId": AuthProvider.korisnikId,
      "frizerId": widget.frizerId,
      "datumRezervacije": widget.datumRezervacije.toIso8601String(),
      "vrijemePocetka": "${widget.vrijemePocetka.hour.toString().padLeft(2, '0')}:${widget.vrijemePocetka.minute.toString().padLeft(2, '0')}:00",
      "kodPromocije": _kodUnos?.isEmpty ?? true ? null : _kodUnos,
      "stavkeRezervacije": usluge.values.map((u) => {"uslugaId": u['id']}).toList(),
    };
    if (!mounted) return false;
    setState(() => _isSaving = true);
    try {
      if (!mounted) return false;
      await rezervacijaProvider.provjeriTermin(request);

      if (_kodUnos != null && _kodUnos!.isNotEmpty) {
        if (!mounted) return false;
        final popustResult = await rezervacijaProvider.getPopustByKod(_kodUnos!);
        if (!mounted) return false;
        await rezervacijaCartProvider!.primijeniPopust(
          uslugaId: popustResult.uslugaId,
          popust: popustResult.popust,
        );
      }
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
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.black, size: 40),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildKodInput(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildDaljeButton(),
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
                "Unesite kod promocije",
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

  Widget _buildKodInput() {
    return Container(
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
          const SizedBox(height: 10),
          const Text(
            "Imate kod? Iskoristite ga i ostvarite popust!",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _kodController,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: "Kod...",
                hintStyle: const TextStyle(
                  color: Colors.black54, 
                  fontSize: 16,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.local_offer, 
                  color: Color.fromARGB(221, 26, 24, 24),
                  size: 22,
                ),
                suffixIcon: _kodController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black45, size: 20),
                        onPressed: () {
                          
                          if (!mounted) return;
                          setState(() {
                            _kodController.clear();
                            _kodUnos = '';
                          });
                          if (_kodUnos == null || _kodUnos!.isEmpty) {
                            rezervacijaCartProvider?.ukloniPopust();
                          }
                        },
                        
                      )
                    : null,
              ),
              onChanged: (value) {
                if (!mounted) return;
                setState(() {
                  _kodUnos = value;
                });
                if (value.isEmpty) {
                  rezervacijaCartProvider?.ukloniPopust();
                }
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _navigateToDetalji() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RezervacijaDetailsScreen(
          frizerId: widget.frizerId,
          datumRezervacije: widget.datumRezervacije,
          vrijemePocetka: widget.vrijemePocetka,
          kodPromocije: _kodUnos?.isEmpty ?? true ? null : _kodUnos,
          rezervacijaCartProvider: rezervacijaCartProvider!, 
        ),
      ),
    );
  }

  Widget _buildDaljeButton() {
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
            onPressed: (_isSaving)
                ? null
                : () async {
                    if (!mounted) return;
                    bool ok = await _saveRezervaciju();
                    if (ok) {
                      _navigateToDetalji();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: (!_isSaving)
                  ? const Color(0xFFD2C1D6)
                  : Colors.grey,
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
                : 
                const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Dalje",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
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

}