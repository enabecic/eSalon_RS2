import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/rezervacija_cart_provider.dart';
import 'package:esalon_mobile/providers/rezervacija_provider.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:esalon_mobile/screens/rezervacija_placanje_kod_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:table_calendar/table_calendar.dart';

class RezervacijaTerminaScreen extends StatefulWidget {
  final int frizerId;

  const RezervacijaTerminaScreen({super.key, required this.frizerId});

  @override
  State<RezervacijaTerminaScreen> createState() => _RezervacijaTerminaScreenState();
}

class _RezervacijaTerminaScreenState extends State<RezervacijaTerminaScreen> {

  late RezervacijaProvider rezervacijaProvider;
  List<Map<String, String>> _kalendar = [];
  bool _isLoadingKalendar = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, String> _events = {}; 

  List<TimeOfDay> _allSlots = [];
  TimeOfDay? _selectedSlot;

  List<Map<String, String>> _zauzetiTermini = [];
  bool _isLoadingZauzeti = false;

  bool _isSaving = false;
  RezervacijaCartProvider? rezervacijaCartProvider;
  Map<String, dynamic> usluge = {};

  @override
  void initState() {
    super.initState();
    rezervacijaProvider = context.read<RezervacijaProvider>();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _loadKalendar(widget.frizerId, now.year, now.month);
    _generateAllSlots();
    _loadZauzetiTermini();
    if (AuthProvider.korisnikId != null) {
      rezervacijaCartProvider = RezervacijaCartProvider(AuthProvider.korisnikId!);
      _loadUsluge();
    }
  }

  Future<void> _loadUsluge() async {
    if (rezervacijaCartProvider == null) return;

    try {
      if (!mounted) return;
      final lista = await rezervacijaCartProvider!.getRezervacijaList();
      if (!mounted) return;
      setState(() {
        usluge = lista;
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
    }
  }
  Future<bool> _saveRezervaciju() async {
    if (_isSaving) return false;

    if (_selectedDay == null || _selectedSlot == null) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 1800),
          content: Center(
            child: Text(
              'Molimo odaberite datum i vrijeme termina.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
      return false;
    }

    if (rezervacijaCartProvider == null) return false;

    if (usluge.isEmpty) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 1800),
          content: Center(
            child: Text(
              'Morate dodati barem jednu uslugu.',
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
      "datumRezervacije": _selectedDay!.toIso8601String(),
      "vrijemePocetka": "${_selectedSlot!.hour.toString().padLeft(2, '0')}:${_selectedSlot!.minute.toString().padLeft(2, '0')}:00",
      "stavkeRezervacije": usluge.values.map((u) => {"uslugaId": u['id']}).toList(),
    };
    if (!mounted) return false;
    setState(() => _isSaving = true);
    try {
      if (!mounted) return false;
      await rezervacijaProvider.provjeriTermin(request);
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

  Future<void> _loadZauzetiTermini() async {
    if (_selectedDay == null) return;
    if (!mounted) return;
    setState(() => _isLoadingZauzeti = true);

    try {
      if (!mounted) return;
      final data = await rezervacijaProvider.getZauzetiTermini(
        frizerId: widget.frizerId,
        datumRezervacije: _selectedDay!,
      );
      if (!mounted) return;
      setState(() {
        _zauzetiTermini = data;
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
      if (mounted) setState(() => _isLoadingZauzeti = false);
    }
  }

  void _generateAllSlots() {
    _allSlots = [];
    TimeOfDay start = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 16, minute: 0);

    TimeOfDay current = start;
    while (_compareTimeOfDay(current, end) <= 0) {
      _allSlots.add(current);

      int newMinute = current.minute + 5;
      int newHour = current.hour + newMinute ~/ 60;
      newMinute = newMinute % 60;
      current = TimeOfDay(hour: newHour, minute: newMinute);
    }
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    return a.hour == b.hour ? a.minute - b.minute : a.hour - b.hour;
  }

  String formatTime24(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildSlotsBox() {
    final now = DateTime.now();

    if (_isLoadingZauzeti) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.coffee,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  "Pauza: 12:00 - 12:30",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 13,
            runSpacing: 13,
            children: _allSlots.map((slot) {
              bool isSelected = _selectedSlot != null &&
                                _compareTimeOfDay(slot, _selectedSlot!) == 0;

              bool isPastSlot = false;
              if (_selectedDay != null) {
                if (_selectedDay!.year == now.year &&
                    _selectedDay!.month == now.month &&
                    _selectedDay!.day == now.day) {
                  if (_compareTimeOfDay(slot, TimeOfDay(hour: now.hour, minute: now.minute)) < 0) {
                    isPastSlot = true;
                  }
                } else if (_selectedDay!.isBefore(DateTime(now.year, now.month, now.day))) {
                  isPastSlot = true;
                }
              }
              bool isZauzet = false;
              bool isPauza = false;
              if (_zauzetiTermini.isNotEmpty) {
                for (var t in _zauzetiTermini) {
                  if (t['vrijemePocetka'] == null || t['vrijemeKraja'] == null) continue;

                  final startParts = t['vrijemePocetka']!.split(':');
                  final endParts = t['vrijemeKraja']!.split(':');
                  final start = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
                  final end = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
                  if (start.hour == 12 && start.minute == 0 && end.hour == 12 && end.minute == 30) {
                    if (_compareTimeOfDay(slot, start) >= 0 && _compareTimeOfDay(slot, end) < 0) {
                      isPauza = true;
                    }
                  }
                  if (_compareTimeOfDay(slot, start) >= 0 && _compareTimeOfDay(slot, end) <= 0) {
                    isZauzet = true;
                    break;
                  }
                }
              }
              if (slot.hour == 12 && slot.minute == 30) {
                isPauza = true;
              }
              return GestureDetector(
                onTap: (isPastSlot || isZauzet) ? null : () {
                  if (!mounted) return;
                  setState(() {
                    _selectedSlot = slot;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isPastSlot
                        ? Colors.grey.withOpacity(0.5)
                        : isPauza
                            ? Colors.grey.withOpacity(0.5)   
                            : isZauzet
                                ? Colors.red.withOpacity(0.5)
                                : isSelected
                                    ? const Color.fromARGB(255, 210, 193, 214)
                                    : Colors.green.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    formatTime24(slot),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool _isPastDay(DateTime day) {
    final now = DateTime.now();
    return day.isBefore(DateTime(now.year, now.month, now.day));
  }

  Future<void> _loadKalendar(int frizerId, int godina, int mjesec) async {
    if (!mounted) return;
    setState(() => _isLoadingKalendar = true);
    try {
      if (!mounted) return;
      final data = await rezervacijaProvider.getKalendar(
        frizerId: frizerId,
        godina: godina,
        mjesec: mjesec,
      );
      if (!mounted) return;
      setState(() {
        _kalendar = data;
        _events = {};
        for (var d in _kalendar) {
          final datumStr = d['datum'];
          final statusStr = d['status'];

          if (datumStr == null || statusStr == null) continue; 

          final datum = DateTime.parse(datumStr);
          _events[DateTime(datum.year, datum.month, datum.day)] = statusStr;
        }
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
      if (mounted) setState(() => _isLoadingKalendar = false);
    }
  }

  Widget _buildColorCodedCalendar() {
    if (_isLoadingKalendar) {
      return const Center(child: CircularProgressIndicator());
    }
    Color getStatusColor(String status) {
      switch (status) {
        case 'slobodan':
          return Colors.green;
        case 'zauzet':
          return Colors.red;
        case 'djelomicno':
          return Colors.orange;
        case 'neradni_dan':
          return Colors.grey;
        default:
          return Colors.transparent;
      }
    }
    return TableCalendar(
      firstDay: DateTime(2023),
      lastDay: DateTime(2100),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      calendarFormat: CalendarFormat.month,
      enabledDayPredicate: (day) {
        return !_isPastDay(day);
      },
      startingDayOfWeek: StartingDayOfWeek.monday, 
      onDaySelected: (selectedDay, focusedDay) {
        if (_isPastDay(selectedDay) || selectedDay.weekday == DateTime.sunday) return;
        if (!mounted) return;
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _selectedSlot = null; 
        });
        _loadZauzetiTermini(); 
      },
      headerStyle: const HeaderStyle(
        formatButtonVisible: false, 
        titleCentered: true,
      ),
      availableGestures: AvailableGestures.none,
      onPageChanged: (focusedDay) {
        if (!mounted) return;
        setState(() => _focusedDay = focusedDay);
        _loadKalendar(widget.frizerId, focusedDay.year, focusedDay.month);
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          if (_isPastDay(day)) {
            return Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          final status = _events[DateTime(day.year, day.month, day.day)];
          final color = status != null ? getStatusColor(status) : Colors.transparent;

          return Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text('${day.day}'),
          );
        },
        selectedBuilder: (context, day, focusedDay) {
          return Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 210, 193, 214),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
        todayBuilder: (context, day, focusedDay) {
          if (_isPastDay(day)) {
            return Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text('${day.day}', style: const TextStyle(color: Colors.grey)),
            );
          }
          return Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 210, 193, 214),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color.fromARGB(255, 156, 135, 160), width: 2),
            ),
            alignment: Alignment.center,
            child: Text('${day.day}', style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  Widget _buildLegenda() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendaItem(Colors.green, "Slobodno"),
        _buildLegendaItem(Colors.red, "Zauzeto"),
        _buildLegendaItem(Colors.orange, "Djelimično"),
        _buildLegendaItem(Colors.grey, "Neradno"),
      ],
    );
  }

  Widget _buildLegendaItem(Color color, String text) {
    return Flexible(
      fit: FlexFit.tight, 
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Odaberite početak termina",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (_selectedDay != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event, size: 18),
                const SizedBox(width: 6),
                Text(
                  formatirajDatumSaDanom(_selectedDay!),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          if (_selectedSlot != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.schedule, size: 18),
                const SizedBox(width: 6),
                Text(
                  "${formatTime24(_selectedSlot!)} - ${formatTime24(calculateEndTime())}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  TimeOfDay calculateEndTime() {
    if (_selectedSlot == null || usluge.isEmpty) {
      return _selectedSlot!;
    }

    int totalMinutes = 0;
    for (var u in usluge.values) {
      totalMinutes += (u['trajanje'] ?? 0) as int;
    }

    int startMinutes =
        _selectedSlot!.hour * 60 + _selectedSlot!.minute;

    int endMinutes = startMinutes + totalMinutes;

    int endHour = endMinutes ~/ 60;
    int endMinute = endMinutes % 60;

    return TimeOfDay(hour: endHour, minute: endMinute);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildColorCodedCalendar(),
                    const SizedBox(height: 16),
                    _buildLegenda(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSlotsHeader(),
              _buildSlotsBox(),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "*Napomena: Ako odaberete više usluga čije ukupno trajanje prelazi vrijeme dostupnih termina, "
                  "molimo da tada rezervaciju rezervišete u više manjih termina.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
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

  void _navigateToPlacanje() {
    if (_selectedDay == null || _selectedSlot == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RezervacijaPlacanjeKodScreen(
          frizerId: widget.frizerId,
          datumRezervacije: _selectedDay!,
          vrijemePocetka: _selectedSlot!,
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
            onPressed: (_selectedDay == null || _selectedSlot == null || _isSaving)
                ? null
                : () async {
                    if (!mounted) return;
                    bool ok = await _saveRezervaciju();

                    if (ok) {
                      _navigateToPlacanje(); 
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: (_selectedDay != null && _selectedSlot != null && !_isSaving)
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
                : const Row(
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
                "Odaberite termin",
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
              Icons.calendar_today,
              color: Colors.black,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
