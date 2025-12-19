import 'package:esalon_mobile/main.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:esalon_mobile/models/recenzija.dart';
import 'package:esalon_mobile/models/recenzija_odgovor.dart';
import 'package:esalon_mobile/providers/recenzija_provider.dart';
import 'package:esalon_mobile/providers/recenzija_odgovor_provider.dart';
import 'package:esalon_mobile/models/search_result.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class RecenzijeScreen extends StatefulWidget {
  final int uslugaId;
  const RecenzijeScreen({super.key, required this.uslugaId});

  @override
  State<RecenzijeScreen> createState() => _RecenzijeScreenState();
}

class _RecenzijeScreenState extends State<RecenzijeScreen> {
  late RecenzijaProvider recenzijaProvider;
  late RecenzijaOdgovorProvider recenzijaOdgovorProvider;

  SearchResult<Recenzija>? recenzijaResult;
  Map<int, SearchResult<RecenzijaOdgovor>> odgovoriResult = {};
  final Map<int, bool> _isLoadingOdgovori = {};
  final Map<int, bool> _isOdgovoriVisible = {};
  bool _isLoading = true;

  final Map<int, bool> _showInsertOdgovor = {};
  final Map<int, TextEditingController> _odgovorControllers = {};
  bool _isSendingOdgovor = false;

  bool _showInsertRecenzija = false;
  final TextEditingController _recenzijaController = TextEditingController();
  bool _isSendingRecenzija = false;

  Map<int, bool?> _reakcijeKorisnika = {};
  bool _isLoadingReakcije = true;

  final Map<int, bool?> _reakcijeKorisnikaOdgovora = {};
  final Map<int, bool> _isLoadingReakcijeOdgovora = {};

  @override
  void initState() {
    super.initState();
    recenzijaProvider = context.read<RecenzijaProvider>();
    recenzijaOdgovorProvider = context.read<RecenzijaOdgovorProvider>();
    _loadRecenzije();
  }

  Future<void> _loadRecenzije() async {
    try {
      if (!mounted) return;
      final recenzije = await recenzijaProvider.get(filter: {
        "UslugaId": widget.uslugaId,
      });

      if (AuthProvider.korisnikId != null) {
        if (!mounted) return;
        final reakcije = await recenzijaProvider.getReakcijeKorisnika(
          AuthProvider.korisnikId!,
          widget.uslugaId,
        );

        _reakcijeKorisnika = reakcije;
      }
      if (!mounted) return;
      setState(() {
        recenzijaResult = recenzije;
        _isLoading = false;
        _isLoadingReakcije = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingReakcije = false;
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
    }
  }

  Future<void> _loadReakcijeOdgovora(int recenzijaId) async {
    if (AuthProvider.korisnikId == null) return;
    if (!mounted) return;
    setState(() => _isLoadingReakcijeOdgovora[recenzijaId] = true);

    try {
      if (!mounted) return;
      final reakcije = await recenzijaOdgovorProvider.getReakcijeKorisnika(
        AuthProvider.korisnikId!,
        recenzijaId,
      );

      if (!mounted) return;
      setState(() {
        _reakcijeKorisnikaOdgovora.addAll(reakcije);
        _isLoadingReakcijeOdgovora[recenzijaId] = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingReakcijeOdgovora[recenzijaId] = false);
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

  Future<void> _loadOdgovori(int recenzijaId) async {
    if (!mounted) return;
    setState(() {
      _isLoadingOdgovori[recenzijaId] = true;
      _isLoadingReakcijeOdgovora[recenzijaId] = true; 
    });

    try {
      if (!mounted) return;
      final odgovori = await recenzijaOdgovorProvider.get(filter: {
        "RecenzijaId": recenzijaId,
      });

      if (!mounted) return;
      setState(() {
        odgovoriResult[recenzijaId] = odgovori;
        _isOdgovoriVisible[recenzijaId] = true;
        _isLoadingOdgovori[recenzijaId] = false;
      });

      if (!mounted) return;
      await _loadReakcijeOdgovora(recenzijaId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingOdgovori[recenzijaId] = false;
        _isLoadingReakcijeOdgovora[recenzijaId] = false;
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
                "Recenzije",
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
              Icons.rate_review_outlined,
              color: Colors.black,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecenzijaHeader(Recenzija recenzija) {
    final isOwner = recenzija.korisnikId == AuthProvider.korisnikId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, 
      children: [
        Text(
          recenzija.korisnickoIme ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: isOwner ? TextAlign.right : TextAlign.left,
        ),
        const SizedBox(height: 8),
        Text(
          recenzija.komentar,
          textAlign: isOwner ? TextAlign.right : TextAlign.left,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildRecenzijaLikeDislikeRow(Recenzija recenzija, BuildContext context) {
    final reakcija = _reakcijeKorisnika[recenzija.recenzijaId];

    return Row(
      children: [
        Text(
          formatDatumRecenzije(recenzija.datumDodavanja),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: () {
            if (!mounted) return;
            setState(() {
              _showInsertOdgovor[recenzija.recenzijaId!] =
                  !(_showInsertOdgovor[recenzija.recenzijaId!] ?? false);
              _odgovorControllers[recenzija.recenzijaId!] ??= TextEditingController();
            });
          },
          child: const Text(
            'Odgovori',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () async {
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
                          text: "Morate biti prijavljeni da lajkate recenziju. ",
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
            try {
              final trenutna = _reakcijeKorisnika[recenzija.recenzijaId];
              if (!mounted) return;
              await recenzijaProvider.toggleLike(recenzija.recenzijaId!, AuthProvider.korisnikId!);
              if (!mounted) return;
              setState(() {
                  if (trenutna == true) {
                    _reakcijeKorisnika.remove(recenzija.recenzijaId);
                  } else {
                    _reakcijeKorisnika[recenzija.recenzijaId!] = true;
                  }
                });
              _loadRecenzije();
            } catch (e) {
              if (!context.mounted) return;
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
          child: Row(
            children: [
              Text('${recenzija.brojLajkova}'),
              const SizedBox(width: 4),
              Icon(
                reakcija == true
                    ? Icons.thumb_up_alt
                    : Icons.thumb_up_alt_outlined,
                size: 16,
                color: Colors.black,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () async {
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
                          text: "Morate biti prijavljeni da dislajkate recenziju. ",
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
            try {
              final trenutna = _reakcijeKorisnika[recenzija.recenzijaId];
              if (!mounted) return;
              await recenzijaProvider.toggleDislike(recenzija.recenzijaId!, AuthProvider.korisnikId!);
              if (!mounted) return;
              setState(() {
                  if (trenutna == false) {
                    _reakcijeKorisnika.remove(recenzija.recenzijaId);
                  } else {
                    _reakcijeKorisnika[recenzija.recenzijaId!] = false;
                  }
                });
              _loadRecenzije();
            } catch (e) {
              if (!context.mounted) return;
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
          child: Row(
            children: [
              Text('${recenzija.brojDislajkova}'),
              const SizedBox(width: 4),
              Icon(
                reakcija == false
                    ? Icons.thumb_down_alt
                    : Icons.thumb_down_alt_outlined,
                size: 16,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsertRecenzijaField(int uslugaId) {
    if (!_showInsertRecenzija) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 4.0),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 48, 
                  child: TextField(
                    controller: _recenzijaController,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: "Unesite recenziju...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      counterText: "",
                      suffixIcon: _recenzijaController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                if (!mounted) return;
                                setState(() {
                                  _recenzijaController.clear();
                                });
                              },
                            ),
                    ),
                    onChanged: (val) {
                      if (!mounted) return;
                      setState(() {});
                  },
                ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0, right: 4),
                    child: Text(
                      '${_recenzijaController.text.length}/500',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 40, 
            child: _isSendingRecenzija
                ? const CircularProgressIndicator(strokeWidth: 2)
                : IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {

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
                                text: "Morate biti prijavljeni da biste dodali recenziju. ",
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
                      final komentarText = _recenzijaController.text.trim();
                      if (komentarText.isEmpty) return;
                      if (!mounted) return;
                      setState(() => _isSendingRecenzija = true);

                      final request = {
                        "korisnikId": AuthProvider.korisnikId,
                        "uslugaId": uslugaId,
                        "komentar": komentarText,
                      };

                      try {
                        if (!mounted) return;
                        await recenzijaProvider.insert(request);
                        if (!mounted) return;
                        setState(() {
                          _showInsertRecenzija = false;
                          _recenzijaController.clear();
                          _isSendingRecenzija = false;
                        });
                        if (!mounted) return;
                        await _loadRecenzije();

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color.fromARGB(255, 138, 182, 140),
                            content: Center(child: Text("Recenzija uspješno dodana.")),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        setState(() => _isSendingRecenzija = false);
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
                                textAlign: TextAlign.center, 
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddRecenzijaButton(int uslugaId) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          if (!mounted) return;
          setState(() {
            _showInsertRecenzija = !_showInsertRecenzija;
          });
        },
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
        label: const Text(
          'Dodaj recenziju',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 210, 193, 214),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildInsertOdgovorField(int recenzijaId) {
    if (_showInsertOdgovor[recenzijaId] != true) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 14.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 48, 
                  child: TextField(
                    controller: _odgovorControllers[recenzijaId] ??= TextEditingController(),
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: "Unesite odgovor...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      counterText: "",
                      suffixIcon: (_odgovorControllers[recenzijaId]?.text.isEmpty ?? true)
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                if (!mounted) return;
                                setState(() {
                                  _odgovorControllers[recenzijaId]?.clear();
                                });
                              },
                            ),
                    ),
                    onChanged: (val) {
                      if (!mounted) return;
                      setState(() {});
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0, right: 4),
                    child: Text(
                      '${_odgovorControllers[recenzijaId]?.text.length ?? 0}/500',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 65,
            child: Align(
              alignment: Alignment.topCenter,
              child: _isSendingOdgovor
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
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
                                text: "Morate biti prijavljeni da biste dodali odgovor. ",
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
                        final komentarText = _odgovorControllers[recenzijaId]?.text.trim() ?? "";
                        if (komentarText.isEmpty) return;
                        if (!mounted) return;
                        setState(() => _isSendingOdgovor = true);

                        final request = {
                          "recenzijaId": recenzijaId,
                          "korisnikId": AuthProvider.korisnikId,
                          "komentar": komentarText,
                        };

                        try {
                          if (!mounted) return;
                          await recenzijaOdgovorProvider.insert(request);
                          if (!mounted) return;
                          setState(() {
                            _showInsertOdgovor[recenzijaId] = false;
                            _odgovorControllers[recenzijaId]?.clear();
                            _isSendingOdgovor = false;
                          });

                          _loadOdgovori(recenzijaId);
                          _loadRecenzije();

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color.fromARGB(255, 138, 182, 140),
                              content: Center(child: Text("Odgovor uspješno dodan.")),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          setState(() => _isSendingOdgovor = false);
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
                    ),
            ), 
          ),
        ],
      ),
    );
  }

  List<Widget>? _buildOdgovori(Recenzija recenzija) {
    if (_isOdgovoriVisible[recenzija.recenzijaId] != true) return null;

    return odgovoriResult[recenzija.recenzijaId]?.result.map((o) {
      final isMyOdgovor = o.korisnikId == AuthProvider.korisnikId;

      final reakcija = _reakcijeKorisnikaOdgovora[o.recenzijaOdgovorId]; 

      Widget odgovorContent = Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 8, left: 0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: isMyOdgovor ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              o.korisnickoIme ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: isMyOdgovor ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: 4),
            Text(
              o.komentar,
              textAlign: isMyOdgovor ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  formatDatumRecenzije(o.datumDodavanja),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
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
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                );
                              },
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  text:
                                      "Morate biti prijavljeni da lajkate odgovor. ",
                                  style:
                                      TextStyle(color: Colors.white, fontSize: 15),
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
                    try {
                      final trenutna = _reakcijeKorisnikaOdgovora[o.recenzijaOdgovorId];
                      if (!mounted) return;
                      await recenzijaOdgovorProvider.toggleLike(o.recenzijaOdgovorId!, AuthProvider.korisnikId!);
                      if (!mounted) return;
                      setState(() {
                        if (trenutna == true) {
                          _reakcijeKorisnikaOdgovora.remove(o.recenzijaOdgovorId);
                        } else {
                          _reakcijeKorisnikaOdgovora[o.recenzijaOdgovorId!] = true;
                        }
                      });
                      _loadOdgovori(recenzija.recenzijaId!);
                    } catch (e) {
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
                  child: Row(
                    children: [
                      Text('${o.brojLajkova}'),
                      const SizedBox(width: 4),
                      Icon(
                        reakcija == true
                            ? Icons.thumb_up_alt
                            : Icons.thumb_up_alt_outlined,
                        size: 16,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
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
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                );
                              },
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  text:
                                      "Morate biti prijavljeni da dislajkate odgovor. ",
                                  style:
                                      TextStyle(color: Colors.white, fontSize: 15),
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
                    try {
                      final trenutna = _reakcijeKorisnikaOdgovora[o.recenzijaOdgovorId];
                      if (!mounted) return;
                      await recenzijaOdgovorProvider.toggleDislike(o.recenzijaOdgovorId!, AuthProvider.korisnikId!);
                      if (!mounted) return;
                      setState(() {
                        if (trenutna == false) {
                          _reakcijeKorisnikaOdgovora.remove(o.recenzijaOdgovorId);
                        } else {
                          _reakcijeKorisnikaOdgovora[o.recenzijaOdgovorId!] = false;
                        }
                      });
                      _loadOdgovori(recenzija.recenzijaId!);
                    } catch (e) {
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
                  child: Row(
                    children: [
                      Text('${o.brojDislajkova}'),
                      const SizedBox(width: 4),
                      Icon(
                        reakcija == false
                            ? Icons.thumb_down_alt
                            : Icons.thumb_down_alt_outlined,
                        size: 16,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      return Container(
        margin: const EdgeInsets.only(bottom: 8, left: 40),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isMyOdgovor
            ? Slidable(
                startActionPane: ActionPane(
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) async {
                        try {
                          if (!mounted) return;
                          await recenzijaOdgovorProvider.delete(o.recenzijaOdgovorId!);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color.fromARGB(255, 138, 182, 140),
                              duration: Duration(seconds: 1),
                              content:
                                  Center(child: Text("Odgovor uspješno obrisan.")),
                            ),
                          );
                          _loadOdgovori(recenzija.recenzijaId!);
                          _loadRecenzije(); 
                        } catch (e) {
                          if (!context.mounted) return;
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
                      backgroundColor: Colors.red,
                      icon: Icons.delete,
                      label: 'Obriši',
                      spacing: 0,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                child: odgovorContent,
              )
            : odgovorContent,
      );
    }).toList();
  }

  Widget _buildRecenzijaCard(Recenzija recenzija) {
    final brojOdgovora = recenzija.brojOdgovora;
    final isMyRecenzija = recenzija.korisnikId == AuthProvider.korisnikId;

    Widget content = Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildRecenzijaHeader(recenzija),
          _buildRecenzijaLikeDislikeRow(recenzija, context),
          _buildInsertOdgovorField(recenzija.recenzijaId!),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isMyRecenzija
              ? Slidable(
                  startActionPane: ActionPane(
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          try {
                            if (!mounted) return;
                            await recenzijaProvider.delete(recenzija.recenzijaId!);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color.fromARGB(255, 138, 182, 140),
                                duration: Duration(seconds: 1),
                                content: Center(child: Text("Recenzija uspješno obrisana.")),
                              ),
                            );
                            _loadRecenzije();
                          } catch (e) {
                            if (!context.mounted) return;
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
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        label: 'Obriši',
                        spacing: 0,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  child: content,
                )
              : content,
        ),

        if (brojOdgovora > 0)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
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
                              text: "Morate biti prijavljeni da biste vidjeli odgovore. ",
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

                if (_isOdgovoriVisible[recenzija.recenzijaId] == true) {
                  if (!mounted) return;
                  setState(() {
                    _isOdgovoriVisible[recenzija.recenzijaId!] = false;
                  });
                } else {
                  _loadOdgovori(recenzija.recenzijaId!);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                padding: EdgeInsets.zero, 
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB( 12, 1, 6, 16,),
                child: Text(
                  _isOdgovoriVisible[recenzija.recenzijaId] == true
                      ? 'Sakrij odgovore'
                      : 'Odgovori ($brojOdgovora)',
                ),
              ),
            ),
          ),

        if ((_isLoadingOdgovori[recenzija.recenzijaId] == true) || (_isLoadingReakcijeOdgovora[recenzija.recenzijaId] == true))
          const Center(child: CircularProgressIndicator()),

        if (_isOdgovoriVisible[recenzija.recenzijaId] == true)
          ...?_buildOdgovori(recenzija),
      ],
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
        child: 
        (_isLoading || _isLoadingReakcije) 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildAddRecenzijaButton(widget.uslugaId),
                    const SizedBox(height: 10),
                    _buildInsertRecenzijaField(widget.uslugaId),
                    const SizedBox(height: 16),
                    if (recenzijaResult == null || recenzijaResult!.result.isEmpty)
                      const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.rate_review_outlined, 
                              size: 40,
                              color: Color.fromARGB(255, 76, 72, 72),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Usluga nema recenzija za prikazati.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...recenzijaResult!.result.map(_buildRecenzijaCard),
                  ],
                ),
              ),
      ),
    );
  }
}