import 'dart:convert';
import 'package:esalon_mobile/main.dart';
import 'package:esalon_mobile/models/promocija.dart';
import 'package:esalon_mobile/providers/aktivirana_promocija_provider.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class PromocijaDetailsScreen extends StatefulWidget {
  final Promocija promocija;
  const PromocijaDetailsScreen({super.key, required this.promocija});

  @override
  State<PromocijaDetailsScreen> createState() =>
      _PromocijaDetailsScreenState();
}

class _PromocijaDetailsScreenState extends State<PromocijaDetailsScreen> {
  final Map<int, Uint8List> _imageBytesCache = {};
  final Map<int, MemoryImage> _memoryImageCache = {};

  final AktiviranaPromocijaProvider _aktiviranaPromocijaProvider =
      AktiviranaPromocijaProvider();

  bool _isLoading = false;
  bool _jeAktivirana = false;
  int? _aktiviranaPromocijaId;
  bool _showCode = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _ucitajPodatke();
  }

  Future<void> _ucitajPodatke() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    if (!mounted) return;

    try {
    if (!mounted) return;
    await _provjeriAktivaciju();
    if (!mounted) return;
    await _prepareImage();
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
    finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _prepareImage() async {
    final base64 = widget.promocija.slikaUsluge;
    if (base64 == null || base64.trim().isEmpty) return;
    if (!mounted) return;

    final key = widget.promocija.promocijaId ?? base64.hashCode;
    final bytes = _imageBytesCache[key] ??= base64Decode(base64);
    final mem = _memoryImageCache[key] ??= MemoryImage(bytes);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(mem, context);
    });
  }

  Future<void> _provjeriAktivaciju() async {
    try {
      if (AuthProvider.korisnikId == null) return;
      if (!mounted) return;

      final result = await _aktiviranaPromocijaProvider.get(filter: {
        'KorisnikId': AuthProvider.korisnikId,
        'PromocijaId': widget.promocija.promocijaId
      });

      if (!mounted) return;

      if (result.result.isNotEmpty) {
        setState(() {
          _jeAktivirana = true;
          _aktiviranaPromocijaId = result.result.first.aktiviranaPromocijaId;
        });
      } else {
        setState(() {
          _jeAktivirana = false;
          _aktiviranaPromocijaId = null;
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
    }
  }

  Future<void> _aktivirajPromociju() async {
    try {
      if (AuthProvider.korisnikId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 1500),
            content: Center( 
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: "Morate biti prijavljeni da biste aktivirali promociju. ",
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
          ),
        );
        return;
      }

      if (!mounted) return;
      await _aktiviranaPromocijaProvider.insert({
        "promocijaId": widget.promocija.promocijaId,
        "korisnikId": AuthProvider.korisnikId
      });

      if (!mounted) return;
      await _provjeriAktivaciju();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromARGB(255, 138, 182, 140),
          duration: Duration(milliseconds: 1500),
          content: Center(
            child: Text(
              "Promocija je uspješno aktivirana.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

      setState(() {
        _changed = true;
      });
     // Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 1500),
          content: Center(
            child: Text(
              "Greška: $e",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _deaktivirajPromociju() async {
    if (_aktiviranaPromocijaId == null) return;
    try {
      if (!mounted) return;
      await _aktiviranaPromocijaProvider.delete(_aktiviranaPromocijaId!);
      if (!mounted) return;
      await _provjeriAktivaciju();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromARGB(255, 138, 182, 140),
          duration: Duration(milliseconds: 1500),
          content: Center(
            child: Text(
              "Promocija je uspješno deaktivirana.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
      if (!mounted) return;
      setState(() {
        _changed = true;
      });
      //Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 1500),
          content: Center(
            child: Text(
              "Greška: $e",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }

  bool get _jeBuducaPromocija => widget.promocija.jeBuduca ?? false;

  Widget _buildImage() {
    final base64 = widget.promocija.slikaUsluge;
    if (base64 == null || base64.trim().isEmpty) {
      return Image.asset(
        "assets/images/praznaUsluga.png",
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      );
    }

    final key = widget.promocija.promocijaId ?? base64.hashCode;

    try {
      final bytes = _imageBytesCache[key] ??= base64Decode(base64);
      final mem = _memoryImageCache[key] ??= MemoryImage(bytes);
      return Image(image: mem, fit: BoxFit.cover, width: double.infinity, height: 200);
    } catch (_) {
      return Image.asset("assets/images/praznaUsluga.png",
          width: double.infinity, height: 200, fit: BoxFit.cover);
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
                "Detalji promocije",
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

  Widget buildInfoWithIcon(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$label ",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500, 
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final p = widget.promocija;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 180,
                  width: 140,
                  child: _buildImage(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.naziv ?? "Nepoznata promocija",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (p.popust != null)
                      Text(
                        "-${p.popust!.round()}%",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      "na ${p.uslugaNaziv}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          if (p.datumPocetka != null)
            buildInfoWithIcon(
              Icons.calendar_month,
              "Vrijedi od:",
              formatDate(p.datumPocetka.toString()),
            ),
          if (p.datumKraja != null)
            buildInfoWithIcon(
              Icons.calendar_today,
              "Vrijedi do:",
              formatDate(p.datumKraja.toString()),
            ),
          if (_jeAktivirana && !_jeBuducaPromocija)
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Row(
              children: [
                const Icon(Icons.lock_open_outlined, size: 20, color: Colors.black),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (p.kod != null && _showCode) {
                        Clipboard.setData(ClipboardData(text: p.kod!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color.fromARGB(255, 138, 182, 140),
                            content: Center(
                              child: Text(
                                "Kod kopiran u međuspremnik!",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: "Kod: ",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: _showCode ? (p.kod ?? "/") : "••••••",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showCode ? Icons.visibility_off : Icons.visibility,
                    size: 22,
                    color: Colors.grey[700],
                  ),
                  onPressed: () => setState(() => _showCode = !_showCode),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "O promociji:",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            p.opis ?? "-",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_jeBuducaPromocija) {
      return _zatvoriDugme();
    }
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _jeAktivirana ? _deaktivirajPromociju : _aktivirajPromociju,
        icon: Icon(
          _jeAktivirana ? Icons.remove_circle_outline : Icons.check_circle_outline,
          color: Colors.black,
        ),
        label: Text(
          _jeAktivirana ? "Deaktiviraj" : "Aktiviraj",
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _jeAktivirana
            ? const Color.fromARGB(255, 210, 209, 210)
            : const Color.fromARGB(255, 210, 193, 214),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _zatvoriDugme() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.close, color: Colors.black),
        label: const Text(
          "Zatvori",
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 210, 209, 210),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
          backgroundColor: const Color(0xFFF6F4F3),
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
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 20),
                              _buildInfoSection(),
                              const SizedBox(height: 28),
                              const Spacer(),
                              _buildActionButtons(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

}
