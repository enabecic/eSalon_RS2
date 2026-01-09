import 'package:esalon_desktop/providers/auth_provider.dart';
import 'package:esalon_desktop/providers/korisnik_provider.dart';
import 'package:esalon_desktop/providers/report_provider.dart';
import 'package:esalon_desktop/providers/rezervacija_provider.dart';
import 'package:esalon_desktop/models/search_result.dart';
import 'package:file_selector/file_selector.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class FrizerHomeScreen extends StatefulWidget {
  const FrizerHomeScreen({super.key});

  @override
  State<FrizerHomeScreen> createState() => _FrizerHomeScreenState();
}

class _FrizerHomeScreenState extends State<FrizerHomeScreen> {
  late KorisnikProvider korisnikProvider;
  late RezervacijaProvider rezervacijaProvider;

  SearchResult rezervacije = SearchResult(); 

  bool isLoading = true;

  int brojKorisnika = 0;
  String? _selectedState; 
  final List<String> _states = ['odobrena', 'ponistena', 'zavrsena','kreirana'];


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      korisnikProvider = context.read<KorisnikProvider>();
      rezervacijaProvider = context.read<RezervacijaProvider>();

      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    if (AuthProvider.korisnikId == null) return; 

    try {
      if (!mounted) return;
      final korisniciResult = await korisnikProvider.get();
      if (!mounted) return;
      final rezervacijaResult = await rezervacijaProvider.get();
      rezervacije = rezervacijaResult;

      if (!mounted) return;
      setState(() {
        brojKorisnika = korisniciResult.count;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Greška',
        text: e.toString(),
        confirmBtnText: 'OK',
        confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
        textColor: Colors.black,
        titleColor: Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final brojOtkazanih = rezervacije.result
        .where((r) => r.stateMachine?.toLowerCase() == "ponistena")
        .length;
    final brojZavrsenih = rezervacije.result
        .where((r) => r.stateMachine?.toLowerCase() == "zavrsena")
        .length;
    final brojUkupno = rezervacije.result.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
          child: Text(
            "Statistika",
            style: TextStyle(fontSize: 26, color: Colors.black),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildCard("Ukupan broj rezervacija", brojUkupno.toString(), icon: Icons.calendar_today)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildCard("Broj završenih rezervacija", brojZavrsenih.toString(), icon: Icons.check_circle)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildCard("Broj otkazanih rezervacija", brojOtkazanih.toString(), icon: Icons.cancel)),
                  ],
                ),
                 const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Text(
                        'Filtriraj rezervacije po stanju:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        height: 45, 
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedState,
                          hint: const Text('Sve'),
                          dropdownColor: Colors.white, 
                          underline: const SizedBox.shrink(), 
                          borderRadius: BorderRadius.circular(8), 
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Sve')),
                            ..._states.map((stanje) => DropdownMenuItem(
                                  value: stanje,
                                  child: Text(
                                    stanje[0].toUpperCase() + stanje.substring(1),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                )),
                          ],
                          onChanged: (value) {
                            if (!mounted) return;
                            setState(() {
                              _selectedState = value;
                            });
                          },
                          isExpanded: false, 
                        ),
                      ),
                      const SizedBox(width: 20),
                      if (_selectedState != null)
                        TextButton(
                          onPressed: () {
                            if (!mounted) return;
                            setState(() {
                              _selectedState = null;
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size(100, 52), 
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline, size: 18, color: Color.fromARGB(199, 0, 0, 0)),
                              SizedBox(width: 6),
                              Text('Očisti filter', style: TextStyle(color: Color.fromARGB(199, 0, 0, 0))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              if (_selectedState != null) 
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 0, left: 8),
                  child: Text(
                    'Broj rezervacija po filteru $_selectedState: '
                    '${rezervacije.result.where((r) => r.stateMachine?.toLowerCase() == _selectedState).length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                 _buildLineChart(),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                       onPressed: () async {
                        if (!mounted) return;
                        await _promptSaveReport();
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                      foregroundColor: const Color.fromARGB(199, 0, 0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(160, 53), 
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.download, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Sačuvaj izvještaj",
                          style: TextStyle(color: Color.fromARGB(199, 0, 0, 0)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(String label, String value, {IconData? icon}) {
    return Container(
      //height: 130,
      constraints: const BoxConstraints(
        minHeight: 130,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 225, 205, 235),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.deepPurple,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.deepPurple,
              size: 30,
            ),
            const SizedBox(height: 2),
          ],
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  final GlobalKey _chartKey = GlobalKey();
  
  Widget _buildLineChart() {
    if (rezervacije.result.isEmpty || 
        rezervacije.result.where((r) => r.datumRezervacije != null && r.stateMachine != 'ponistena').isEmpty) {
      return const Center(
        child: Text(
          'Trenutno nema podataka za prikazati na grafu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    List<int> mjeseci = List.filled(12, 0);
    for (var r in rezervacije.result) {
         if (r.datumRezervacije != null &&
    (_selectedState == null || r.stateMachine?.toLowerCase() == _selectedState))
      {
        DateTime datum = r.datumRezervacije!;
        mjeseci[datum.month - 1]++;
      }
    }

    List<FlSpot> spots = List.generate(
      12,
      (index) => FlSpot(index.toDouble(), mjeseci[index].toDouble()),
    );
    return RepaintBoundary(
      key: _chartKey, 
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 40), 
              child: Center(
                child: Text(
                  'Broj rezervacija po mjesecima',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          SizedBox(
            height: 400,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                width: 50,
                child: Align(
                  alignment: Alignment.center,
                  child: Transform.translate(
                    offset: const Offset(0, 50),
                    child: Transform.rotate(
                      angle: -1.5708,
                      child: Text(
                        _selectedState == null
                            ? 'Broj rezervacija svih stanja'
                            : 'Broj rezervacija stanja: ${_selectedState![0].toUpperCase()}${_selectedState!.substring(1)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ),
              ),
                // Grafikon
                Expanded(
                  child: LineChart(
                    LineChartData(
                      showingTooltipIndicators: List.generate(spots.length, (index) => ShowingTooltipIndicators([
                      LineBarSpot(
                        LineChartBarData(spots: spots),
                        0,
                        spots[index],
                      )
                    ])),
                      lineTouchData: LineTouchData(
                        enabled: false,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (spot) => Colors.transparent,
                          tooltipPadding: EdgeInsets.zero,
                          tooltipMargin: 0,
                          tooltipBorder: const BorderSide(color: Colors.transparent),
                          tooltipRoundedRadius: 0,
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '${spot.y.toInt()} rezervacija/e',
                                const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false), 
                        ),
                        bottomTitles: AxisTitles(
                          axisNameWidget: const Padding(
                            padding: EdgeInsets.only(bottom: 10), 
                          child: Text(
                            "Mjesec",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                            ),
                          ),
                          axisNameSize: 40,
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              const mjeseciNazivi = [
                                'Jan', 'Feb', 'Mar', 'Apr', 'Maj', 'Jun',
                                'Jul', 'Avg', 'Sep', 'Okt', 'Nov', 'Dec'
                              ];
                              if (value < 0 || value > 11) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Text(
                                  mjeseciNazivi[value.toInt()],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false), 
                      borderData: FlBorderData(show: true),
                      minX: 0,
                      maxX: 11,
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.deepPurple,
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.deepPurple.withAlpha((0.2 * 255).round()),
                          ),
                          dotData: const FlDotData(show: true),
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
    );
  }

  Future<void> _promptSaveReport() async {
    if (!mounted) return;
    bool? potvrda = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Potvrda"),
        content: const Text("Jeste li sigurni da želite sačuvati izvještaj?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Ne",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Da",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (potvrda != true) return;

    if (potvrda == true) {
      if (!mounted) return;

      try {
        if (!mounted) return;
        final bytes =
            await context.read<ReportProvider>().getFrizerStatistikaPdf(
                  stateMachine: _selectedState,
                );

        if (bytes.isEmpty) return;
        final name =
            'FrizerStatistika_${DateFormat('ddMMyyyy_HHmm').format(DateTime.now().toLocal())}.pdf';
        if (!mounted) return;
        final location = await getSaveLocation(
          suggestedName: name,
          acceptedTypeGroups: [
            const XTypeGroup(label: 'PDF', extensions: ['pdf']),
          ],
        );

        if (location == null) return;

        final file = XFile.fromData(
          Uint8List.fromList(bytes),
          name: name,
          mimeType: 'application/pdf',
        );
        if (!mounted) return;
        await file.saveTo(location.path);

        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Uspjeh"),
            content:
                Text("PDF je uspješno preuzet na lokaciju:\n${location.path}."),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
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
      } catch (e) {
        if (!mounted) return;
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Greška',
          text: e.toString(),
          confirmBtnText: 'OK',
          confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
          textColor: Colors.black,
          titleColor: Colors.black,
        );
      }
    }
  }

}