import 'dart:convert';
import 'package:esalon_desktop/models/promocija.dart';
import 'package:esalon_desktop/models/usluga.dart';
import 'package:esalon_desktop/providers/promocija_provider.dart';
import 'package:esalon_desktop/providers/usluga_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:esalon_desktop/models/search_result.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AdminPromocijaDetails extends StatefulWidget {
  final Promocija? promocija;

  const AdminPromocijaDetails({super.key, this.promocija});

  @override
  State<AdminPromocijaDetails> createState() =>
      _AdminPromocijaDetailsState();
}
class _AdminPromocijaDetailsState
    extends State<AdminPromocijaDetails> {
  late PromocijaProvider _provider;
  late UslugaProvider uslugaProvider;
  SearchResult<Usluga>? uslugaResult;
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  SearchResult<Promocija>? _promocijaResult;
  String? promocijaError;
  bool _isTextFieldHovered = false;
  bool _isOpisFieldHovered = false;
  bool _isPopustFieldHovered = false;
  bool _isDatumPocetkaFieldHovered = false;
  bool _isDatumKrajaFieldHovered = false;
  bool _isDropdownHovered = false;
  bool _isSaveHovered = false;
  bool _obscureKod = true; 

  String? _base64Image;
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
    _initialValue = {
      'naziv': widget.promocija?.naziv,
      'opis': widget.promocija?.opis,
      'uslugaId': widget.promocija?.uslugaId, 
      'popust': widget.promocija?.popust?.toInt().toString(), 
      'datumPocetka': widget.promocija?.datumPocetka, 
      'datumKraja': widget.promocija?.datumKraja,
    };
    _base64Image = widget.promocija?.slikaUsluge;
    if (_base64Image != null) {
      _imageProvider = MemoryImage(base64Decode(_base64Image!));
    }

        uslugaProvider = context.read<UslugaProvider>();
    _loadUsluga();
    _provider = context.read<PromocijaProvider>();
    _loadPromocije();
  }

  Future<void> _loadPromocije() async {
    _promocijaResult = await _provider.get();
    setState(() {}); 
  }

  Future<void> _loadUsluga() async {
    uslugaResult = await uslugaProvider.get();
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
                const Text("eSalon",
                    style:
                        TextStyle(fontSize: 36, fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                Image.asset('assets/images/logo.png',
                    height: 80, width: 80, fit: BoxFit.contain),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 35.0, top: 30.0, bottom: 20.0),
            child: Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.promocija == null
                      ? "Dodaj promociju"
                      : "Uredi promociju / Detalji promocije",
                  style: const TextStyle(fontSize: 22),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: uslugaResult == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: _buildForm(),
            ),

            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
  final bool isEditMode = widget.promocija != null;

  return FormBuilder(
    key: _formKey,
    initialValue: _initialValue,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isEditMode)
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      const Text(
                        "Slika usluge:", 
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: 300,
                        height: 290,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: _imageProvider ??
                                const AssetImage("assets/images/praznaUsluga.png"),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      TextFormField(
                          initialValue: widget.promocija?.kod ?? '',
                          readOnly: true,   
                          enabled: true,   
                          obscureText: _obscureKod, 
                          decoration: InputDecoration(
                            labelText: 'Kod promocije',
                            floatingLabelStyle: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            filled: true,
                            fillColor: const Color(0xFFE0D7F5), 
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.7),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.7), 
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureKod ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey.shade700,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureKod = !_obscureKod;
                                });
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              else
                const SizedBox(width: 0),
              
              if (isEditMode)
                const SizedBox(width: 40),

              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Naziv
                    SizedBox(
                      height: 80,
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _isTextFieldHovered = true),
                        onExit: (_) => setState(() => _isTextFieldHovered = false),
                        child: FormBuilderTextField(
                          name: 'naziv',
                          maxLength: 100,
                          decoration: InputDecoration(
                            labelText: 'Naziv promocije',
                            hintText: 'Unesite naziv promocije',
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            errorText: promocijaError,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.7),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade600, width: 2.0),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.red, width: 1.7),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.red, width: 2.0),
                            ),
                            filled: true,
                            fillColor: _isTextFieldHovered ? const Color(0xFFE0D7F5) : Colors.white,
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.match(
                              r'^[A-ZČĆŽĐŠ][a-zA-ZčćžđšČĆŽĐŠ\s]*$',
                              errorText: "Naziv mora početi velikim slovom i sadržavati samo slova.",
                            ),
                            FormBuilderValidators.required(errorText: "Obavezno polje."),
                            FormBuilderValidators.minLength(1, errorText: "Minimalna dužina je 1 znak."),
                            FormBuilderValidators.maxLength(100, errorText: "Maksimalna dozvoljena dužina je 100 znakova."),
                          ]),
                          onChanged: (value) async {
                            _formKey.currentState?.fields['naziv']?.validate();
                            if (value != null && _promocijaResult?.result != null) {
                              final postoji = _promocijaResult!.result.any(
                                (e) =>
                                    (e.naziv?.toLowerCase() ?? '') == value.toLowerCase() &&
                                    (widget.promocija == null || e.promocijaId != widget.promocija!.promocijaId),
                              );
                              final newError = postoji ? "Promocija sa tim imenom već postoji." : null;
                              if (promocijaError != newError) {
                                setState(() {
                                  promocijaError = newError;
                                });
                              }
                            }
                          },
                        ),
                      ),
                    ),

                    // Opis
                    SizedBox(
                      height: 140,
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _isOpisFieldHovered = true),
                        onExit: (_) => setState(() => _isOpisFieldHovered = false),
                        child: FormBuilderTextField(
                          name: 'opis',
                          maxLines: 4,
                          maxLength: 1000,
                          decoration: InputDecoration(
                            labelText: 'Opis promocije',
                            hintText: 'Unesite opis promocije',
                            isDense: true,
                            alignLabelWithHint: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.7),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade600, width: 2.0),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.red, width: 1.7),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.red, width: 2.0),
                            ),
                            filled: true,
                            fillColor: _isOpisFieldHovered ? const Color(0xFFE0D7F5) : Colors.white,
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.match(
                              r'^[A-ZČĆŽĐŠ][\sa-zA-ZčćžđšČĆŽĐŠ.,!?()\-]*$',
                              errorText: "Opis mora početi velikim slovom i sadržavati samo slova i razmake.",
                            ),
                            FormBuilderValidators.required(errorText: "Obavezno polje."),
                            FormBuilderValidators.minLength(1, errorText: "Minimalna dužina je 1 znak."),
                            FormBuilderValidators.maxLength(1000, errorText: "Maksimalno 1000 znakova."),
                          ]),
                        ),
                      ),
                    ),

                    // Popust
                    SizedBox(
                      height: 80,
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _isPopustFieldHovered = true),
                        onExit: (_) => setState(() => _isPopustFieldHovered = false),
                        child: FormBuilderTextField(
                          name: 'popust',
                          decoration: InputDecoration(
                            labelText: 'Popust (%)',
                            hintText: 'Unesite popust (1 - 100)',
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.7),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade600, width: 2.0),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.red, width: 1.7),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.red, width: 2.0),
                            ),
                            filled: true,
                            fillColor: _isPopustFieldHovered ? const Color(0xFFE0D7F5) : Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: "Obavezno polje."),
                            FormBuilderValidators.integer(errorText: "Unesite cijeli broj."),
                            FormBuilderValidators.min(1, errorText: "Minimalni popust je 1%"),
                            FormBuilderValidators.max(100, errorText: "Maksimalni popust je 100%"),
                          ]),
                        ),
                      ),
                    ),

                    // Datum početka
                    SizedBox(
                      height: 80,
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _isDatumPocetkaFieldHovered = true),
                        onExit: (_) => setState(() => _isDatumPocetkaFieldHovered = false),
                        child: FormBuilderDateTimePicker(
                          name: 'datumPocetka',
                          enabled: widget.promocija == null, 
                          inputType: InputType.date,
                          format: DateFormat('dd.MM.yyyy'),
                          style: widget.promocija == null
                            ? null
                            : const TextStyle(
                                color: Colors.black87, 
                              ),
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                          firstDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day), 
                          decoration: InputDecoration(
                            labelText: 'Datum početka',
                            floatingLabelStyle: widget.promocija == null
                              ? const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                )
                              : const TextStyle(
                                  color: Colors.black54, 
                                  fontWeight: FontWeight.w500,
                                ),
                            hintText: 'Odaberite datum početka',
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.7),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade600, width: 2.0),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.red, width: 1.7),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.red, width: 2.0),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.7), 
                            ),  
                            filled: true,
                            fillColor: widget.promocija == null
                              ? (_isDatumPocetkaFieldHovered ? const Color(0xFFE0D7F5) : Colors.white)
                              : const Color(0xFFE0D7F5),  
                            ),
                            validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: "Obavezno polje."),
                            (val) {
                              if (val == null) return null;
                              final now = DateTime.now();
                              final today = DateTime(now.year, now.month, now.day);
                              
                              if (widget.promocija == null && val.isBefore(today)) {
                                return 'Datum početka ne može biti u prošlosti';
                              }
                              return null;
                            },
                          ]),
                        ),
                      ),
                    ),

                    // Datum kraja
                    SizedBox(
                      height: 80,
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _isDatumKrajaFieldHovered = true),
                        onExit: (_) => setState(() => _isDatumKrajaFieldHovered = false),
                        child: FormBuilderDateTimePicker(
                          name: 'datumKraja',
                          inputType: InputType.date,
                          format: DateFormat('dd.MM.yyyy'),
                          initialEntryMode: DatePickerEntryMode.calendarOnly,  
                          firstDate: widget.promocija != null
                            ? DateTime(2000) 
                            : DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                          decoration: InputDecoration(
                            labelText: 'Datum kraja',
                            hintText: 'Odaberite datum kraja',
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.7),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade600, width: 2.0),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.red, width: 1.7),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.red, width: 2.0),
                            ),
                            filled: true,
                            fillColor: _isDatumKrajaFieldHovered ? const Color(0xFFE0D7F5) : Colors.white,
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: "Obavezno polje."),
                            (val) {
                              if (val == null) return null;

                              final pocetak = _formKey.currentState?.fields['datumPocetka']?.value;

                              if (widget.promocija == null) {
                                final today = DateTime.now();

                                if (val.isBefore(today)) {
                                  return 'Datum kraja ne može biti u prošlosti';
                                }

                                if (pocetak != null &&
                                    (val.isBefore(pocetak) || val.isAtSameMomentAs(pocetak))) {
                                  return 'Datum kraja mora biti nakon datuma početka';
                                }
                              }
                              return null;
                            }
                          ]),
                        ),
                      ),
                    ),

                    // Usluga
                    MouseRegion(
                      onEnter: (_) => setState(() => _isDropdownHovered = true),
                      onExit: (_) => setState(() => _isDropdownHovered = false),
                      child: FormBuilderDropdown<int>(
                        name: 'uslugaId',
                        decoration: InputDecoration(
                          labelText: 'Usluga',
                          hintText: 'Odaberite uslugu',
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.7),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade600, width: 2.0),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.red, width: 1.7),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.red, width: 2.0),
                          ),
                          filled: true,
                          fillColor: _isDropdownHovered ? const Color(0xFFE0D7F5) : Colors.white,
                          errorStyle: const TextStyle(
                            color: Colors.red,
                            backgroundColor: Colors.transparent,
                            fontSize: 12,
                            height: 1.2,
                          ),
                        ),
                        validator: FormBuilderValidators.required(errorText: "Usluga je obavezna."),
                        items: uslugaResult?.result
                                .map((usluga) => DropdownMenuItem(
                                      value: usluga.uslugaId,
                                      child: Text(usluga.naziv ?? ""),
                                    ))
                                .toList() ??
                            [],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _saveRow(),
        ],
      ),
    ),
  );
}
  Widget _saveRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MouseRegion(
            onEnter: (_) => setState(() => _isSaveHovered = true),
            onExit: (_) => setState(() => _isSaveHovered = false),
            child: Container(
              width: 250,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _isSaveHovered
                    ? const Color.fromARGB(255, 160, 120, 200)
                    : const Color.fromARGB(255, 180, 140, 218),
              ),
              child: InkWell(
              onTap: () async {
                var isValid = _formKey.currentState!.saveAndValidate();
                if (isValid) {
                  final potvrda = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text("Potvrda"),
                      content: Text(widget.promocija == null
                          ? "Jeste li sigurni da želite dodati?"
                          : "Jeste li sigurni da želite urediti?"),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, false), 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "NE",
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "DA",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (potvrda == true) {
                    final req = Map.from(_formKey.currentState!.value);
                    if (req.containsKey('popust')) {
                      final popustString = req['popust'];
                      if (popustString is String) {
                        req['popust'] = double.tryParse(popustString) ?? 0.0;
                      } else if (popustString is int) {
                        req['popust'] = popustString.toDouble();
                      }
                    }
                    if (req.containsKey('datumPocetka') && req['datumPocetka'] != null) {
                      final DateTime datum = req['datumPocetka'];
                      req['datumPocetka'] = datum.toIso8601String();
                    }
                    if (req.containsKey('datumKraja') && req['datumKraja'] != null) {
                      final DateTime datum = req['datumKraja'];
                      req['datumKraja'] = datum.toIso8601String();
                    }
                      try {
                        if (widget.promocija == null) {
                          await _provider.insert(req);
                        } else {
                          await _provider.update(widget.promocija!.promocijaId!, req);
                        }
                        Navigator.pop(context, true);
                        clearInput();
                      } catch (e) {
                        await QuickAlert.show(
                          context: context,
                          type: QuickAlertType.error,
                          title: 'Greška!',
                          text: e.toString(),
                          confirmBtnText: 'OK',
                          confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
                          textColor: Colors.black,
                          titleColor: Colors.black,
                        );
                      }
                  }
                }
              },
                child: const Center(
                  child: Text(
                    "Sačuvaj",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(199, 0, 0, 0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void clearInput() {
    _formKey.currentState?.reset();
    promocijaError = null;
    _base64Image = null;
  }
}
 
