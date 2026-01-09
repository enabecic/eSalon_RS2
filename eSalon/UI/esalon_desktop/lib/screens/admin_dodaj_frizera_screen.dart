import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:esalon_desktop/providers/korisnik_provider.dart';
import 'package:esalon_desktop/providers/report_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:esalon_desktop/models/korisnik.dart';
import 'package:esalon_desktop/models/search_result.dart';
import 'package:esalon_desktop/models/uloga.dart';
import 'package:esalon_desktop/providers/uloga_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AdminDodajFrizeraScreen extends StatefulWidget {
  const AdminDodajFrizeraScreen({super.key});

  @override
  State<AdminDodajFrizeraScreen> createState() =>
      _AdminDodajFrizeraScreenState();
}

class _AdminDodajFrizeraScreenState extends State<AdminDodajFrizeraScreen> {
  late KorisnikProvider korisnikProvider;
  late UlogaProvider ulogeProvider;

  SearchResult<Korisnik>? korisniciResult;
  SearchResult<Uloga>? ulogeResult;

  bool _isSaving = false;

  bool _isUsernameHovered = false;
  bool _isLozinkaHovered = false;
  bool _isLozinkaPotvrdaHovered = false;
  bool _isImeHovered = false; 
  bool _isPrezimeHovered = false; 
  bool _isEmailHovered = false; 
  bool _isTelefonHovered = false; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  final _formKey = GlobalKey<FormBuilderState>();
  String? usernameError;
  String? confirmPasswordError;
  bool _isImageFieldHovered = false;
  ImageProvider? _imageProvider;
  bool _obscureLozinka = true;
  bool _obscureLozinkaPotvrda = true;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
 if (_base64Image != null) {
      _imageProvider = MemoryImage(base64Decode(_base64Image!));
    }
    ulogeProvider = context.read<UlogaProvider>();
    _loadUloga();
    korisnikProvider = context.read<KorisnikProvider>();
    _initForm();
  }

  Future _initForm() async {
    if (!mounted) return;
    korisniciResult = await korisnikProvider.get();
    if (!mounted) return;
    setState(() {});
  }

   Future<void> _loadUloga() async {
    if (!mounted) return;
    ulogeResult = await ulogeProvider.get();
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
              const Text(
                    "Dodavanje frizera",
                    style: TextStyle(fontSize: 22),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    if (ulogeResult == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: FormBuilder(
        key: _formKey,
        child: Padding(
          padding:const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isUsernameHovered = true),
                      onExit: (_) => setState(() => _isUsernameHovered = false),
                        child: FormBuilderTextField(
                          name: 'korisnickoIme',
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')), 
                          ],
                          decoration: InputDecoration(
                            labelText: 'Korisničko ime',
                            hintText: 'Unesite korisničko ime',
                            errorText: usernameError,
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 108, 108, 108),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: _isUsernameHovered ? const Color(0xFFE0D7F5) : Colors.white,
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                                errorText: "Obavezno polje."),
                            FormBuilderValidators.minLength(4,
                                errorText: "Minimalno 4 karaktera."),
                            FormBuilderValidators.maxLength(30,
                                errorText: "Maksimalno 30 karaktera."),

                            (val) {
                              if (val != null && val.contains(' ')) {
                                return 'Korisničko ime ne smije sadržavati razmake.';
                              }
                              return null;
                            },
                          ]),
                          onChanged: (value) async {
                            if (value != null && korisniciResult != null) {
                              var username =  korisniciResult!.result
                                  .map((e) => e.korisnickoIme == value)
                                  .toList();

                              if (username.contains(true)) {
                                usernameError =
                                    "Korisnik s tim imenom već postoji.";
                                    if (!mounted) return;
                                setState(() {});
                              } else {
                                usernameError = null;
                              }
                            }
                            if (!mounted) return;
                            setState(() {});
                          },
                        ),
                    ),  
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: MouseRegion( 
                      onEnter: (_) => setState(() => _isLozinkaHovered = true), 
                      onExit: (_) => setState(() => _isLozinkaHovered = false),
                        child: FormBuilderTextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Lozinka',
                            errorText: confirmPasswordError,
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 108, 108, 108),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: "Lozinka",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: _isLozinkaHovered ? const Color(0xFFE0D7F5) : Colors.white,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureLozinka ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                if (!mounted) return;
                                setState(() {
                                  _obscureLozinka = !_obscureLozinka;
                                });
                              },
                            ),
                          ),
                          name: 'lozinka',
                          obscureText: _obscureLozinka,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: "Obavezno polje."),
                          ]),
                        ),
                    ),  
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: MouseRegion( 
                      onEnter: (_) => setState(() => _isLozinkaPotvrdaHovered = true), 
                      onExit: (_) => setState(() => _isLozinkaPotvrdaHovered = false),
                        child: FormBuilderTextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            errorText: confirmPasswordError,
                            labelText: 'Lozinka potvrda',
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 108, 108, 108),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: "Lozinka potvrda",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: _isLozinkaPotvrdaHovered ? const Color(0xFFE0D7F5) : Colors.white,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureLozinkaPotvrda ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                if (!mounted) return;
                                setState(() {
                                  _obscureLozinkaPotvrda = !_obscureLozinkaPotvrda;
                                });
                              },
                            ),
                          ),
                          name: 'lozinkaPotvrda',
                          obscureText: _obscureLozinkaPotvrda,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: "Obavezno polje."),
                          ]),
                          onChanged: (value) {
                            if (value != null &&
                                _formKey.currentState!.fields['lozinka']?.value != value) {
                              confirmPasswordError =
                                  "Lozinka potvrda se mora podudarati sa unesenom lozinkom.";
                            } else {
                              confirmPasswordError = null;
                            }
                            if (!mounted) return;
                            setState(() {});
                          },
                        ),
                    ),   
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromARGB(255, 180, 140, 218),
                        ),
                        child: InkWell(
                          onTap: () async {
                            if (_formKey.currentState!.fields['lozinka'] !=
                                    null &&
                                _formKey.currentState!
                                        .fields['lozinkaPotvrda'] !=
                                    null) {
                              var pw = generateRandomCharacters(10);
                              _formKey.currentState!.fields['lozinka']!
                                  .didChange(pw);
                              _formKey.currentState!.fields['lozinkaPotvrda']!
                                  .didChange(pw);
                            }
                          },
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min, 
                              children: [
                                Icon(
                                  Icons.lock_open, 
                                  size: 18,
                                  color: Color.fromARGB(199, 0, 0, 0),
                                ),
                                SizedBox(width: 6), 
                                Text(
                                  "Generiši lozinku",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(199, 0, 0, 0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isImeHovered = true), 
                      onExit: (_) => setState(() => _isImeHovered = false), 
                        child: buildFormBuilderTextField(
                          name: 'ime',
                          labelText: 'Ime',
                          hintText: "Unesite ime",
                          fillColor: _isImeHovered
                            ? const Color(0xFFE0D7F5)
                            : Colors.white,
                          validators: [
                            FormBuilderValidators.required(
                                errorText: "Obavezno polje."),
                            FormBuilderValidators.minLength(1,
                                errorText: "Ime ne može biti prazno."),
                            FormBuilderValidators.maxLength(50,
                                errorText:
                                    "Maksimalna dužina imena je 50 znakova."),
                            FormBuilderValidators.match(
                                RegExp(r'^[A-ZČĆŽĐŠ][a-zA-ZčćžđšČĆŽĐŠ]*$'),
                                errorText:
                                    "Ime mora počinjati sa velikim slovom i smije sadržavati samo slova.")
                          ],
                        ),
                    ),   
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isPrezimeHovered = true), 
                      onExit: (_) => setState(() => _isPrezimeHovered = false),
                        child: buildFormBuilderTextField(
                          name: 'prezime',
                          labelText: 'Prezime',
                          hintText: "Unesite prezime",
                          fillColor: _isPrezimeHovered
                            ? const Color(0xFFE0D7F5)
                            : Colors.white,
                          validators: [
                            FormBuilderValidators.required(
                                errorText: "Obavezno polje."),
                            FormBuilderValidators.minLength(1,
                                errorText:
                                    "Prezime ne može biti prazno."),
                            FormBuilderValidators.maxLength(50,
                                errorText:
                                    "Maksimalna dužina prezimena je 50 znakova."),
                            FormBuilderValidators.match(
                                RegExp(r'^[A-ZČĆŽĐŠ][a-zA-ZčćžđšČĆŽĐŠ]*$'),
                                errorText:
                                    "Prezime mora počinjati sa velikim slovom i smije sadržavati samo slova.")
                          ],
                        ),
                    ),  
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isEmailHovered = true), 
                      onExit: (_) => setState(() => _isEmailHovered = false),
                        child: buildFormBuilderTextField(
                          name: 'email',
                          labelText: 'Email',
                          hintText: "Unesite email",
                          fillColor: _isEmailHovered
                                ? const Color(0xFFE0D7F5)
                                : Colors.white,
                          validators: [
                            FormBuilderValidators.required(errorText: "Obavezno polje."),
                            FormBuilderValidators.email(errorText: "Email nije validan."),
                            FormBuilderValidators.maxLength(100,
                              errorText: "Email može imati najviše 100 karaktera."),
                          ],
                        ),
                    ),  
                  ),
                  const SizedBox(width: 15), 
                  Expanded(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isTelefonHovered = true), 
                      onExit: (_) => setState(() => _isTelefonHovered = false),
                        child: buildFormBuilderTextField(
                          name: 'telefon',
                          labelText: 'Broj telefona',
                          hintText: "Unesite telefon (npr. +387...)",
                          fillColor: _isTelefonHovered
                                  ? const Color(0xFFE0D7F5)
                                  : Colors.white,
                          validators: [
                            FormBuilderValidators.required(errorText: "Obavezno polje."),
                            FormBuilderValidators.match( 
                              RegExp(r'^\+\d{7,15}$'),
                                errorText:
                                    "Telefon mora imati od 7 do 15 cifara i počinjati znakom +."),
                          ],
                        ),
                    ),  
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderField(
                      name: "slika",
                      builder: (field) {
                        return MouseRegion(
                          onEnter: (_) => setState(() => _isImageFieldHovered = true),
                          onExit: (_) => setState(() => _isImageFieldHovered = false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Odaberite sliku',
                              labelStyle: const TextStyle(
                                color: Color.fromARGB(255, 108, 108, 108),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: _isImageFieldHovered
                                  ? const Color(0xFFE0D7F5)
                                  : Colors.white,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.image),
                              title: const Text("Odaberite sliku"),
                              trailing: const Icon(Icons.file_upload),
                              onTap: getImage,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    width: 150,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: _imageProvider ??
                            const AssetImage("assets/images/prazanProfil.png"),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.2 * 255).round()),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 15),
            if (ulogeResult != null && ulogeResult!.result.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isHovered = true),
                      onExit: (_) => setState(() => _isHovered = false),
                      child: FormBuilderDropdown<int>(
                        name: 'uloge',
                        decoration: InputDecoration(
                          labelText: 'Uloga',
                          hintText: 'Odaberite ulogu',
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 108, 108, 108),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: _isHovered ? const Color(0xFFE0D7F5) : Colors.white,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: "Obavezno polje."),
                        ]),
                        items: ulogeResult!.result
                            .where((element) =>
                                element.naziv != "Admin" && element.naziv != "Klijent")
                            .map((uloga) => DropdownMenuItem<int>(
                                  value: uloga.ulogaId!,
                                  child: Text(uloga.naziv ?? ''),
                                ))
                            .toList(),
                        onChanged: (val) {
                          // _selectedUlogaId = val;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(97, 158, 158, 158),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Napomena: Generisanje PDF-a sa podacima će biti omogućeno nakon dodavanja frizera.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _saveRow()),
                  const SizedBox(width: 15),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String generateRandomCharacters(int length) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    print(String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    ));
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  Widget buildFormBuilderTextField({
    required String name,
    required String labelText,
    String? hintText,
    List<String? Function(String?)>? validators,
    Color? fillColor,
  }) {
    return FormBuilderTextField(
      name: name,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 108, 108, 108),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: fillColor ?? Colors.white,
      ),
      validator: FormBuilderValidators.compose(validators ?? []),
    );
  }

  File? _image;
  String? _base64Image;

  void getImage() async {
    if (!mounted) return;
    var result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _base64Image = base64Encode(_image!.readAsBytesSync());
      if (!mounted) return;
      final bytes = await _image!.readAsBytes();
      _imageProvider = MemoryImage(bytes);
      if (!mounted) return;
      setState(() {});
    }
  }

  Widget _saveRow() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
          width: 250,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 180, 140, 218),
          ),
          child: InkWell(
            onTap: _isSaving
              ? null
              : () async {
              var isValid = _formKey.currentState!.saveAndValidate();
              if (isValid) {
                if (!mounted) return;
                bool confirmAdd = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Potvrda"),
                      content: const Text("Jeste li sigurni da želite dodati novog frizera?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "Ne",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "Da",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (!confirmAdd) {
                  return; 
                }

                setState(() => _isSaving = true);

                try {
                  var req = Map.from(_formKey.currentState!.value);
                  req['slika'] = _base64Image;
                  req['uloge'] = [_formKey.currentState!.fields['uloge']?.value];
                  if (!mounted) return;

                  Korisnik noviFrizer = await korisnikProvider.insert(req); 

                  if (!mounted) return;
                  bool shouldPrint = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Uspješno dodan frizer!"),
                        content: const Text("Želite li generisati PDF sa podacima o frizeru?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              "Ne",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              "Da",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldPrint == true) {
                    try {
                      final frizerId = noviFrizer.korisnikId; 
                      final plainPassword = _formKey.currentState!.fields['lozinka']?.value ?? '';

                      if (frizerId != null && plainPassword.isNotEmpty) {
                        if (!mounted) return;
                        final bytes = await context.read<ReportProvider>().getFrizerKreiranPdf(
                          frizerId: frizerId,
                          plainPassword: plainPassword,
                        );

                        if (bytes.isEmpty) return;

                        final name = 'Frizer_ID${frizerId}_${DateFormat('ddMMyyyy_HHmm').format(DateTime.now().toLocal())}.pdf';

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
                            content: Text("PDF sa podacima frizera je preuzet na lokaciju:\n${location.path}."),
                            actions: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  "OK",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
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
                        textColor: Colors.black,
                        titleColor: Colors.black,
                      );
                    }
                    finally {
                      if (mounted) setState(() => _isSaving = false); 
                    }
                  }
                  if (!mounted) return;
                  Navigator.pop(context, true);
                  clearinput();

                } catch (e) {
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
                    } finally {
                      if (mounted) {
                        setState(() => _isSaving = false);
                      }
                    }
                  }
                },
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.task_alt, size: 20, color: Color.fromARGB(199, 0, 0, 0)),
                        SizedBox(width: 8),
                        Text('Sačuvaj', style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,),),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void clearinput() {
    _formKey.currentState?.reset();
    usernameError = null;
    confirmPasswordError = null;
  }

}
