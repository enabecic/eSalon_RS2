import 'dart:convert';
import 'dart:io';
import 'package:esalon_desktop/models/usluga.dart';
import 'package:esalon_desktop/models/vrsta_usluge.dart';
import 'package:esalon_desktop/providers/usluga_provider.dart';
import 'package:esalon_desktop/providers/utils.dart';
import 'package:esalon_desktop/providers/vrsta_usluge_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:esalon_desktop/models/search_result.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AdminUrediDodajUsluguScreen extends StatefulWidget {
  final Usluga? usluga;

  const AdminUrediDodajUsluguScreen({super.key, this.usluga});

  @override
  State<AdminUrediDodajUsluguScreen> createState() =>
      _AdminUrediDodajUsluguScreenState();
}

class _AdminUrediDodajUsluguScreenState
    extends State<AdminUrediDodajUsluguScreen> {
  late UslugaProvider _provider;
  late VrstaUslugeProvider vrstaUslugeProvider;
  SearchResult<VrstaUsluge>? vrstaUslugeResult;
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  SearchResult<Usluga>? _uslugaResult;
  String? uslugaError;

  bool _isTextFieldHovered = false;
  bool _isOpisFieldHovered = false;
  bool _isCijenaFieldHovered = false;
  bool _isTrajanjeFieldHovered = false;
  bool _isDropdownHovered = false;
  bool _isImageFieldHovered = false;
  bool _isSaveHovered = false;

  File? _image;
  String? _base64Image;
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
    _initialValue = {
      'naziv': widget.usluga?.naziv,
      'opis': widget.usluga?.opis,
      'cijena': widget.usluga?.cijena?.toStringAsFixed(2), 
      'trajanje': widget.usluga?.trajanje?.toString(),
      'vrstaId': widget.usluga?.vrstaId, 
    };
    _base64Image = widget.usluga?.slika;
    if (_base64Image != null) {
      _imageProvider = MemoryImage(base64Decode(_base64Image!));
    }
        vrstaUslugeProvider = context.read<VrstaUslugeProvider>();
    _loadVrsteUsluga();
    _provider = context.read<UslugaProvider>();
    _loadUsluge();
  }

  Future<void> _loadUsluge() async {
    _uslugaResult = await _provider.get();
    if (!mounted) return;
    setState(() {}); 
  }

  Future<void> _loadVrsteUsluga() async {
    vrstaUslugeResult = await vrstaUslugeProvider.get();
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
                  widget.usluga == null
                      ? "Dodaj uslugu"
                      : "Uredi uslugu / Detalji usluge",
                  style: const TextStyle(fontSize: 22),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: vrstaUslugeResult == null
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
              // Lijeva kolona 
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const SizedBox(height: 10), 
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
                    const SizedBox(height: 60),
                    MouseRegion(
                      onEnter: (_) => setState(() => _isImageFieldHovered = true),
                      onExit: (_) => setState(() => _isImageFieldHovered = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isImageFieldHovered
                              ? const Color(0xFFE0D7F5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: FormBuilderField(
                          name: "slika",
                          builder: (field) {
                            return InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Odaberite sliku',
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.image),
                                title: const Text("Izaberite sliku"),
                                trailing: const Icon(Icons.file_upload),
                                onTap: getImage,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              // Desna kolona 
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
                            labelText: 'Naziv usluge',
                            hintText: 'Unesite naziv usluge',
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            errorText: uslugaError,
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
                              errorText:
                                  "Naziv mora početi velikim slovom i sadržavati samo slova.",
                            ),
                            FormBuilderValidators.required(errorText: "Obavezno polje."),
                            FormBuilderValidators.minLength(1, errorText: "Minimalna dužina je 1 znak."),
                            FormBuilderValidators.maxLength(100, errorText: "Maksimalna dozvoljena dužina je 100 znakova."),
                          ]),
                          onChanged: (value) async {
                            _formKey.currentState?.fields['naziv']?.validate();
                            if (value != null && _uslugaResult?.result != null) {
                              final postoji = _uslugaResult!.result.any(
                                (e) =>
                                    (e.naziv?.toLowerCase() ?? '') == value.toLowerCase() &&
                                    (widget.usluga == null || e.uslugaId != widget.usluga!.uslugaId),
                              );
                              final newError = postoji ? "Usluga sa tim imenom već postoji." : null;
                              if (uslugaError != newError) {
                                if (!mounted) return;
                                setState(() {
                                  uslugaError = newError;
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
                            labelText: 'Opis usluge',
                            hintText: 'Unesite opis usluge',
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
                    // Cijena
                    SizedBox(
                      height: 80,
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _isCijenaFieldHovered = true),
                        onExit: (_) => setState(() => _isCijenaFieldHovered = false),
                        child: FormBuilderTextField(
                          name: 'cijena',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Cijena (KM)',
                            hintText: 'Cijena (npr. 34 ili 34.00)',
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
                            fillColor: _isCijenaFieldHovered ? const Color(0xFFE0D7F5) : Colors.white,
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: "Cijena je obavezna."),
                            FormBuilderValidators.numeric(errorText: "Cijena mora biti broj i veća od 1."),
                            FormBuilderValidators.min(1, errorText: "Cijena mora biti najmanje 1."),
                            FormBuilderValidators.max(1000, errorText: "Cijena ne može biti veća od 1000."),
                          ]),
                        ),
                      ),
                    ),
                    // Trajanje
                    SizedBox(
                      height: 80,
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _isTrajanjeFieldHovered = true),
                        onExit: (_) => setState(() => _isTrajanjeFieldHovered = false),
                        child: FormBuilderTextField(
                          name: 'trajanje',
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Trajanje (u minutama)',
                            hintText: 'Trajanje (npr. 30 ili 100)',
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
                            fillColor: _isTrajanjeFieldHovered ? const Color(0xFFE0D7F5) : Colors.white,
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: "Trajanje je obavezno."),
                            FormBuilderValidators.integer(errorText: "Unesite cijeli broj."),
                            FormBuilderValidators.min(10, errorText: "Trajanje mora biti najmanje 10 minuta."),
                            FormBuilderValidators.max(300, errorText: "Trajanje ne može biti veće od 300 minuta."),
                          ]),
                        ),
                      ),
                    ),
                    // Vrsta usluge
                    MouseRegion(
                      onEnter: (_) => setState(() => _isDropdownHovered = true),
                      onExit: (_) => setState(() => _isDropdownHovered = false),
                      child: FormBuilderDropdown<int>(
                        name: 'vrstaId',
                        decoration: InputDecoration(
                          labelText: 'Vrsta usluge',
                          hintText: 'Odaberite vrstu usluge',
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
                        validator: FormBuilderValidators.required(errorText: "Vrsta usluge je obavezna."),
                        items: vrstaUslugeResult?.result
                                .map((vrsta) => DropdownMenuItem(
                                      value: vrsta.vrstaId,
                                      child: Text(vrsta.naziv ?? ""),
                                    ))
                                .toList() ??
                            [],
                      ),
                    ),
                    
                    if (widget.usluga != null && widget.usluga!.datumObjavljivanja != null) ...[
                      const SizedBox(height: 35),
                      FormBuilderTextField(
                        name: 'datum',
                        enabled: false,
                        initialValue: formatDateTime(widget.usluga!.datumObjavljivanja!),
                        style: const TextStyle(
                          color: Colors.black87, 
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Datum objavljivanja',
                          hintText: 'Datum kada je usluga dodana',
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
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.7),
                          ),
                        ),
                      ),
                    ],
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
                      content: Text(widget.usluga == null
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
                              borderRadius: BorderRadius.circular(8),
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

                  if (potvrda == true) {
                    final req = Map.from(_formKey.currentState!.value);
                    req['slika'] = _base64Image;
                    req['cijena'] = double.tryParse(req['cijena'] ?? '0'); 
                    req['trajanje'] = int.tryParse(req['trajanje'] ?? '0');

                    try {
                      if (widget.usluga == null) {
                        await _provider.insert(req);
                      } else {
                        await _provider.update(widget.usluga!.uslugaId!, req);
                      }
                      if (!mounted) return;
                      Navigator.pop(context, true);
                      clearInput();
                    }  catch (e) {
                      if (!mounted) return;
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

  void getImage() async {
    var result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      final bytes = await _image!.readAsBytes();
      _base64Image = base64Encode(bytes);
      _imageProvider = MemoryImage(bytes);
      if (!mounted) return;
      setState(() {});
    }
  }

  void clearInput() {
    _formKey.currentState?.reset();
    uslugaError = null;
    _base64Image = null;
  }
}
 
