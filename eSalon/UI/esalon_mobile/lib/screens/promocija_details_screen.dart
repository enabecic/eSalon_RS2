import 'dart:convert';
import 'dart:typed_data';
import 'package:esalon_mobile/main.dart';
import 'package:esalon_mobile/models/promocija.dart';
import 'package:esalon_mobile/providers/aktivirana_promocija_provider.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _prepareImage();
    _provjeriAktivaciju();
  }

  Future<void> _prepareImage() async {
    final base64 = widget.promocija.slikaUsluge;
    if (base64 == null || base64.trim().isEmpty) return;
    if (!mounted) return;
    setState(() => _isLoading = true);

    final key = widget.promocija.promocijaId ?? base64.hashCode;
    try {
      final bytes = _imageBytesCache[key] ??= base64Decode(base64);
      final mem = _memoryImageCache[key] ??= MemoryImage(bytes);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        precacheImage(mem, context);
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _provjeriAktivaciju() async {
    if (AuthProvider.korisnikId == null) return;
    if (!mounted) return;
    final result = await _aktiviranaPromocijaProvider.get(filter: {
      'KorisnikId': AuthProvider.korisnikId,
      'PromocijaId': widget.promocija.promocijaId
    });

    if (result.result.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _jeAktivirana = true;
        _aktiviranaPromocijaId = result.result.first.aktiviranaPromocijaId;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _jeAktivirana = false;
        _aktiviranaPromocijaId = null;
      });
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
            content: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: RichText(
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
      Navigator.of(context).pop(true);
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
      Navigator.of(context).pop(true);
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.black),
            const SizedBox(width: 10),

            SizedBox(
              width: 100, 
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  softWrap: true,
                ),
              ),
            ),
          ],
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
              "Detalji promocije",
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

  Widget _buildInfoSection() {
    final p = widget.promocija;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: _buildImage()),
          const SizedBox(height: 16),
          _buildInfoRow("Naziv:", p.naziv ?? "/", Icons.label_outline),
          _buildInfoRow("Opis:", p.opis ?? "/", Icons.article_outlined),
          if (!_jeBuducaPromocija && _jeAktivirana)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_open_outlined, size: 20, color: Colors.black),
                  const SizedBox(width: 10),
                  const SizedBox(
                    width: 100,
                    child: Text(
                      "Kod:",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600, 
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _showCode ? (p.kod ?? "/") : "••••••",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                letterSpacing: 2,
                              ),
                              softWrap: true,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showCode = !_showCode;
                              });
                            },
                            child: Icon(
                              _showCode ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey[700],
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildInfoRow(
              "Popust:", p.popust != null ? "${p.popust!.round()}%" : "/", Icons.percent),
          _buildInfoRow("Usluga:", p.uslugaNaziv ?? "/", Icons.content_cut),
          _buildInfoRow(
              "Vrijedi od:",
              p.datumPocetka != null ? formatDate(p.datumPocetka.toString()) : "/",
              Icons.calendar_month),
          _buildInfoRow(
              "Vrijedi do:",
              p.datumKraja != null ? formatDate(p.datumKraja.toString()) : "/",
              Icons.calendar_today),
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
