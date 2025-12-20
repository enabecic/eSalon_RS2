import 'package:esalon_mobile/models/obavijest.dart';
import 'package:esalon_mobile/providers/obavijest_provider.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class ObavijestiDetailsScreen extends StatefulWidget {
  final int obavijestId;

  const ObavijestiDetailsScreen({super.key, required this.obavijestId});

  @override
  State<ObavijestiDetailsScreen> createState() => _ObavijestiDetailsScreenState();
}

class _ObavijestiDetailsScreenState extends State<ObavijestiDetailsScreen> {
  final ObavijestProvider _provider = ObavijestProvider();

  Obavijest? _obavijest;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
       if (!mounted) return;
      var data = await _provider.getById(widget.obavijestId);
      if (!mounted) return;
      setState(() {
        _obavijest = data;
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
          _isLoading = false;
        });
      }
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
            : _obavijest == null
                ? const Center(
                    child: Text("Nema podataka."),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 28),
                              _buildDetailCard(context, _obavijest!),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _zatvoriDugme(),
                      ),
                    ],
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
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 210, 209, 210),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                "Detalji obavijesti",
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
            Icon(Icons.notifications_active, color: Colors.black, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, Obavijest obavijest) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_on_outlined,
                      size: 28, color: Colors.black),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      obavijest.naslov,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 24, color: Colors.black),
                  const SizedBox(width: 12),
                  Text(
                    formatirajDatum(obavijest.datumObavijesti),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.description, size: 24, color: Colors.black),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      obavijest.sadrzaj,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
