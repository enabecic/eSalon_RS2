import 'package:esalon_mobile/providers/utils.dart';
import 'package:flutter/material.dart';
import 'package:esalon_mobile/models/korisnik.dart';
import 'package:esalon_mobile/providers/korisnik_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class RezervacijaOdabirFrizeraScreen extends StatefulWidget {
  const RezervacijaOdabirFrizeraScreen({super.key});

  @override
  State<RezervacijaOdabirFrizeraScreen> createState() => _RezervacijaOdabirFrizeraScreenState();
}

class _RezervacijaOdabirFrizeraScreenState extends State<RezervacijaOdabirFrizeraScreen> {
  List<Korisnik> _frizeri = [];
  bool _isLoading = true;
  Korisnik? _odabraniFrizer;
  final Map<String, Widget> _cachedImages = {};

  @override
  void initState() {
    super.initState();
    _fetchFrizeri();
  }

  Future<void> _fetchFrizeri() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final provider = context.read<KorisnikProvider>();
      if (!mounted) return;
      final frizeriData = await provider.get(filter: {
        "JeAktivan": true,
        "UlogaId": 2,
      });
      if (!mounted) return;
      setState(() {
        _frizeri = frizeriData.result;
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
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 40,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
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
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 16),

                          ..._frizeri.map((frizer) {
                            final isSelected = _odabraniFrizer?.korisnikId == frizer.korisnikId;
                            return GestureDetector(
                              onTap: () {
                                if (!mounted) return;
                                setState(() {
                                  _odabraniFrizer = frizer;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
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
                                    SizedBox(
                                      width: 90,
                                      height: 90,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: _buildImage(frizer.slika),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 2, top: 0, bottom: 10, right: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${frizer.ime ?? "-"} ${frizer.prezime ?? "-"}",
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              frizer.telefon ?? "Nema broja",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 15),
                        const Divider(
                          color: Colors.grey, 
                          thickness: 1,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _odabraniFrizer == null
                                ? null
                                : () {
                                  // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => RezervacijaTerminaScreen(
                                    //       frizerId: _odabraniFrizer!.korisnikId!,
                                    //     ),
                                    //   ),
                                    // );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 210, 193, 214),
                              disabledBackgroundColor: const Color.fromARGB(255, 210, 209, 210),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 6,
                            ),
                            child: const Row(
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
                    ),
                  ),
                ],
              ),
      )
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
                "Odaberite frizera",
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
              Icons.person,
              color: Colors.black,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? base64OrNull) {
    if (base64OrNull == null || base64OrNull.trim().isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset("assets/images/prazanProfil.png", fit: BoxFit.cover),
      );
    }
    if (_cachedImages.containsKey(base64OrNull)) {
      return _cachedImages[base64OrNull]!;
    }
    try {
      final widget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageFromString(base64OrNull),
      );
      _cachedImages[base64OrNull] = widget;
      return widget;
    } catch (e) {
      final fallback = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset("assets/images/prazanProfil.png", fit: BoxFit.cover),
      );
      _cachedImages[base64OrNull] = fallback;
      return fallback;
    }
  }

}
