import 'package:esalon_desktop/providers/auth_provider.dart';
import 'package:esalon_desktop/providers/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:esalon_desktop/models/korisnik.dart';
import 'package:esalon_desktop/models/rezervacija.dart';
import 'package:esalon_desktop/models/search_result.dart';
import 'package:esalon_desktop/models/stavke_rezervacije.dart';
import 'package:esalon_desktop/providers/korisnik_provider.dart';
import 'package:esalon_desktop/providers/stavke_rezervacije_provider.dart';
import 'package:esalon_desktop/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:esalon_desktop/providers/rezervacija_provider.dart';

class DetaljiRezervacijeScreen extends StatefulWidget {
  final Rezervacija? rezervacija;

  const DetaljiRezervacijeScreen({super.key, required this.rezervacija});

  @override
  State<DetaljiRezervacijeScreen> createState() => _DetaljiNarudzbeScreenState();
}

class _DetaljiNarudzbeScreenState extends State<DetaljiRezervacijeScreen> {
  late StavkeRezervacijeProvider stavkeRezervacijeProvider;
  late KorisnikProvider korisniciProvider;

  SearchResult<StavkeRezervacije>? stavkeRezervacijeResult;
  SearchResult<Korisnik>? korisnikResult;
  Map<String, dynamic> searchRequest = {};

  @override
  void initState() {
    super.initState();
    stavkeRezervacijeProvider = context.read<StavkeRezervacijeProvider>();
    korisniciProvider = context.read<KorisnikProvider>();
    _initForm();
  }

  Future _initForm() async {
    searchRequest = {
      'rezervacijaId': widget.rezervacija!.rezervacijaId,
    };
    if (!mounted) return;
    stavkeRezervacijeResult = await stavkeRezervacijeProvider.get(
      filter: searchRequest,
    );
    if (!mounted) return;
    korisnikResult = await korisniciProvider.get();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 240, 255),
      body: Column(
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "eSalon",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 35.0, top: 30.0, bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.arrow_back, size: 28),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Detalji rezervacije",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 12, right: 30),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 212, 202, 221), 
                    borderRadius: BorderRadius.circular(10),       
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha((0.3 * 255).round()),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Šifra rezervacije: #${widget.rezervacija?.sifra ?? ''}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black, 
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 0, 27, 27),
              child: _buildPage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    if (stavkeRezervacijeResult == null || korisnikResult == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (stavkeRezervacijeResult!.result.isEmpty) {
      return Center(
        child: Container(
          width: 250,
          decoration: BoxDecoration(
            color:  Colors.deepPurple,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((0.5 * 255).round()),
                spreadRadius: 2,
                blurRadius: 7,
                offset:const Offset(0, 3),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              ".",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    final bool dozvoljenoPonistavanje = (widget.rezervacija?.nacinPlacanjaNaziv?.toLowerCase() ?? '') == "gotovina";
    final sada = DateTime.now();
    final vrijemeParts = widget.rezervacija!.vrijemePocetka?.split(":");
    final hour = int.tryParse(vrijemeParts?[0] ?? "0") ?? 0;
    final minute = int.tryParse(vrijemeParts?[1] ?? "0") ?? 0;

    final datumVrijemeRezervacije = DateTime(
      widget.rezervacija!.datumRezervacije!.year,
      widget.rezervacija!.datumRezervacije!.month,
      widget.rezervacija!.datumRezervacije!.day,
      hour,
      minute,
    );
    final razlikaUDanima = datumVrijemeRezervacije.difference(sada).inDays;
    final bool mozeOtkazati = dozvoljenoPonistavanje && razlikaUDanima >= 3; 

    return Padding(
      padding:const EdgeInsets.all(5),
      child: Column(
        children: [
             const SizedBox(height: 5,),
            _buildLabelValue(
              label: "Datum rezervacije:",
              value: formatDate(widget.rezervacija!.datumRezervacije.toString()),
            ),
            const SizedBox(height: 10,),
           _buildLabelValue(
              label: "Vrijeme početka:",
              value: widget.rezervacija!.vrijemePocetka != null
                  ? widget.rezervacija!.vrijemePocetka!.substring(0, 5)
                  : '/',
            ),
            const SizedBox(height: 10), 
            _buildLabelValue(
              label: "Vrijeme kraja:",
              value: widget.rezervacija!.vrijemeKraja != null 
                  ? widget.rezervacija!.vrijemeKraja!.substring(0,5) 
                  : '/',
            ),
             const SizedBox(height: 10,),
            _buildLabelValue(
              label: "Ukupno trajanje usluge/a:",
              value: widget.rezervacija!.ukupnoTrajanje != null 
                  ? "${widget.rezervacija!.ukupnoTrajanje} min" 
                  : '/',
            ),
            const SizedBox(height: 10,),
           Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: korisnikResult!.result
                .where((element) => element.korisnikId == widget.rezervacija?.korisnikId)
                .map((e) => _buildLabelValue(
                      label: "Rezervaciju kreirao/la:",
                      value: "${e.ime} ${e.prezime}",
                    ))
                .toList(),
          ),
             const SizedBox(height: 10,),
            _buildLabelValue(
              label: "Ime i prezime frizera:",
              value: widget.rezervacija!.frizerImePrezime ?? '/',
            ),
            const SizedBox(height: 10,),
          _buildLabelValue(
              label: "Status rezervacije:",
              value: widget.rezervacija!.stateMachine ?? '/',
            ),
            const SizedBox(height: 10,),
            _buildLabelValue(
              label: "Način plaćanja:",
              value: widget.rezervacija!.nacinPlacanjaNaziv ?? '/',
            ),
            const SizedBox(height: 10,),
            _buildLabelValue(
              label: "Aktivirana promocija:",
              value: widget.rezervacija!.aktiviranaPromocijaNaziv ?? '/',
            ),
            const SizedBox(height: 10,),
            _buildLabelValue(
              label: "Ukupan broj usluga:",
              value: widget.rezervacija!.ukupanBrojUsluga != null
                  ? "${widget.rezervacija!.ukupanBrojUsluga}"
                  : '/',
            ),
            const SizedBox(height: 20,),
            _buildLabelValue(
              label: "Usluge:",
              value:'',
            ),
            const SizedBox(height: 5),
          const Divider(thickness: 1, color: Colors.grey),
          ...stavkeRezervacijeResult!.result.map(
            (e) => Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${e.uslugaNaziv}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 17, 
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (e.originalnaCijena != null && e.originalnaCijena! > e.cijena!)
                          Text(
                            "${formatNumber(e.originalnaCijena)} KM",
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough, 
                              fontSize: 15, 
                            ),
                          ),
                        if (e.originalnaCijena != null && e.originalnaCijena! > e.cijena!)
                          const SizedBox(width: 6),
                        Text(
                          "${formatNumber(e.cijena)} KM",
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600, 
                            overflow: TextOverflow.ellipsis,
                            fontSize: 17, 
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(thickness: 1, color: Colors.grey),
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:const Color.fromARGB(255, 212, 202, 221),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.3 * 255).round()),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset:const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ukupno:',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                Flexible(
                  child: Text(
                    "${formatNumber(widget.rezervacija!.ukupnaCijena)} KM",
                    style:const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30), 
          Row(
            children: [
              if (AuthProvider.korisnikId != null &&
                  AuthProvider.korisnikId == widget.rezervacija?.frizerId) ...[
                if (widget.rezervacija?.stateMachine == "kreirana") 
                  Tooltip(
                    message: "Molimo odobrite rezervaciju što prije kako bi klijent dobio potvrdu i mogao planirati svoj dolazak.",
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(221, 92, 87, 87),
                      borderRadius: BorderRadius.circular(8), 
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    textStyle: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w600,
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!mounted) return;
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            title: const Text("Potvrda"),
                            content: const Text(
                              "Jeste li sigurni da želite odobriti rezervaciju?",
                              textAlign: TextAlign.center,
                            ),
                            actionsAlignment: MainAxisAlignment.end,
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Ne",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Da",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            final provider = RezervacijaProvider();
                            if (!mounted) return;
                            await provider.odobri(
                              widget.rezervacija!.rezervacijaId!,
                              widget.rezervacija!.frizerId!,
                            );

                            if (!mounted) return;

                            await showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                title: const Text("Uspjeh"),
                                content: const Text(
                                  "Rezervacija je uspješno odobrena.",
                                  textAlign: TextAlign.center,
                                ),
                                actionsAlignment: MainAxisAlignment.end,
                                actions: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    child: const Text(
                                      "OK",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (!mounted) return;
                            Navigator.pop(context, true);
                          } on UserException catch (e) {
                            if (!mounted) return;
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              title: "Greška",
                              text: e.toString(),
                              confirmBtnText: 'OK',
                              confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
                              textColor: Colors.black,
                              titleColor: Colors.black,
                            );
                          } catch (e) {
                            if (!mounted) return;
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              title: "Greška",
                              text: "Greška pri odobravanju rezervacije.",
                              confirmBtnText: 'OK',
                              confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
                              textColor: Colors.black,
                              titleColor: Colors.black,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                        foregroundColor: const Color.fromARGB(199, 0, 0, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fixedSize: const Size(220, 50),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text('Odobri rezervaciju'),
                        ],
                      ),
                    ),
                  ),
                if (widget.rezervacija?.stateMachine == "odobrena") ...[
                Tooltip(
                  message: "Molimo označite rezervaciju kao završenu nakon termina.",
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(221, 92, 87, 87),
                    borderRadius: BorderRadius.circular(8), 
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  textStyle: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.w600,
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!mounted) return;
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text("Potvrda"),
                          content: const Text("Jeste li sigurni da želite završiti rezervaciju?"),
                          actionsAlignment: MainAxisAlignment.end, 
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Ne",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Da",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          var provider = RezervacijaProvider();
                          if (!mounted) return;
                          await provider.zavrsi(widget.rezervacija!.rezervacijaId!);
                          if (!mounted) return;

                          await showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text("Uspjeh"),
                              content: const Text("Rezervacija je uspješno završena."),
                              actionsAlignment: MainAxisAlignment.end,
                              actions: [
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "OK",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (!mounted) return;
                          Navigator.pop(context, true); 

                        } on UserException catch (e) {
                          if (!mounted) return;
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            title: "Greška",
                            text: e.toString(),
                            confirmBtnText: 'OK',
                            confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
                            textColor: Colors.black,
                            titleColor: Colors.black,
                          );
                        } catch (e) {
                          if (!mounted) return;
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            title: "Greška",
                            text: "Greška pri završavanju rezervacije.",
                            confirmBtnText: 'OK',
                            confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
                            textColor: Colors.black,
                            titleColor: Colors.black,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                      foregroundColor: const Color.fromARGB(199, 0, 0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      fixedSize: const Size(220, 50),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.task_alt, size: 20, color: Color.fromARGB(199, 0, 0, 0)),
                        SizedBox(width: 8),
                        Text('Završi rezervaciju'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (widget.rezervacija != null && sada.isBefore(datumVrijemeRezervacije)) ...[
                  Tooltip(
                    message: !dozvoljenoPonistavanje
                      ? "Rezervacija se može otkazati samo ako je način plaćanja gotovina."
                      : razlikaUDanima < 3
                          ? "Rezervaciju je moguće otkazati najkasnije 3 dana prije termina."
                          : "Molimo da otkažete rezervaciju samo u izuzetnim slučajevima i to 3 dana prije termina i ako je način plaćanja gotovina.",
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(221, 92, 87, 87),
                      borderRadius: BorderRadius.circular(8), 
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    textStyle: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w600,
                    ),
                    child: ElevatedButton(
                      onPressed: mozeOtkazati ? () async {
                        if (!mounted) return;
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text("Potvrda"),
                            content: const Text("Jeste li sigurni da želite otkazati rezervaciju?"),
                            actionsAlignment: MainAxisAlignment.end,
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Ne", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Da", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            var provider = RezervacijaProvider();
                            if (!mounted) return;
                            await provider.ponisti(widget.rezervacija!.rezervacijaId!);
                            if (!mounted) return;

                            await showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Text("Uspjeh"),
                                content: const Text("Rezervacija je uspješno otkazana."),
                                actionsAlignment: MainAxisAlignment.end,
                                actions: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );

                            if (!mounted) return;
                            Navigator.pop(context, true);

                          } on UserException catch (e) {
                            if (!mounted) return;
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              title: "Greška",
                              text: e.toString(),
                              confirmBtnText: 'OK',
                              confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
                              textColor: Colors.black,
                              titleColor: Colors.black,
                            );
                          } catch (e) {
                            if (!mounted) return;
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              title: "Greška",
                              text: "Greška pri otkazivanju rezervacije.",
                              confirmBtnText: 'OK',
                              confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
                              textColor: Colors.black,
                              titleColor: Colors.black,
                            );
                          }
                        }
                      }: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[500],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        fixedSize: const Size(220, 50),
                        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            size: 20,
                            color: mozeOtkazati
                                ? const Color.fromARGB(199, 0, 0, 0) 
                                : Colors.black.withAlpha(97),
                          ),
                          const SizedBox(width: 8),
                          const Text('Otkaži rezervaciju'),
                        ],
                      ),
                    ),
                  ),
                ],
                ],
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context,false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                  foregroundColor: const Color.fromARGB(199, 0, 0, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  fixedSize: const Size(190, 50),//150
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.done, size: 20, color: Color.fromARGB(199, 0, 0, 0)),
                    SizedBox(width: 8),
                    Text('OK'),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLabelValue({required String label, required String value,}) {
    IconData iconData;
    switch (label) {
      case "Datum rezervacije:":
        iconData = Icons.calendar_today;
        break;
      case "Vrijeme početka:":
        iconData = Icons.access_time;
        break;
      case "Vrijeme kraja:":
        iconData = Icons.access_time;
        break;
      case "Ukupno trajanje usluge/a:":
        iconData = Icons.timer;
        break;
      case "Rezervaciju kreirao/la:":
        iconData = Icons.person;
        break;
      case "Ime i prezime frizera:":
        iconData = Icons.person_outline;
        break;
      case "Usluge:":
        iconData = Icons.content_cut; 
      break;
      case "Status rezervacije:":
        iconData = Icons.check_circle_outline;
        break;
      case "Način plaćanja:":
        iconData = Icons.payment;
        break;
      case "Aktivirana promocija:":
        iconData = Icons.local_offer;
        break;
      case "Ukupan broj usluga:":
        iconData = Icons.format_list_numbered;
        break;
      default:
        iconData = Icons.info_outline;
    }

    Color textColor = const Color(0xFF333333); 

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            iconData,
            size: 20,
            color: textColor,
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 100),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style:const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

}