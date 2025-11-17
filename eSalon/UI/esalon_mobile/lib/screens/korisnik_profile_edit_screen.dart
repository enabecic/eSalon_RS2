import 'package:esalon_mobile/providers/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:esalon_mobile/providers/korisnik_provider.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/main.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class KorisnikProfileEditScreen extends StatefulWidget {
  const KorisnikProfileEditScreen({super.key});

  @override
  State<KorisnikProfileEditScreen> createState() => _KorisnikProfileEditScreenState();
}

class _KorisnikProfileEditScreenState extends State<KorisnikProfileEditScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late KorisnikProvider _provider;
  bool _isLoading = true;
  bool _promijeniLozinku = false;
  bool _isOldPasswordHidden = true;
  bool _isNewPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  Map<String, dynamic> _initialValue = {};

  @override
  void initState() {
    super.initState();
    _provider = context.read<KorisnikProvider>();
    _loadKorisnik();
  }

  Future<void> _loadKorisnik() async {
    try {
      if (!mounted) return;
      final korisnik = await _provider.getById(AuthProvider.korisnikId!);
      _initialValue = {
        'ime': korisnik.ime ?? '',
        'prezime': korisnik.prezime ?? '',
        'telefon': korisnik.telefon ?? '',
        'promijeniLozinku': false,
      };
    } catch (e) {
      if (!mounted) return;
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Greška',
        text: 'Neuspješno učitavanje podataka o korisniku.',
        confirmBtnText: 'OK',
        confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
        textColor: Colors.black,
        titleColor: Colors.black,
      );
      if (!mounted) return;
      Navigator.pop(context);
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
              child: 
              Row(
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
                              const SizedBox(height: 28),
                              _buildForm(),
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

  InputDecoration _decoration(String label, String hint) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
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
                "Uredi korisnički profil",
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
              Icons.edit,
              color: Colors.black,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(0),//
      child: FormBuilder(
        key: _formKey,
        initialValue: _initialValue,
        child: Column(
          children: [
            FormBuilderTextField(
              name: 'ime',
              decoration: _decoration('Ime', 'Unesite ime'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: "Ime je obavezno."),
                FormBuilderValidators.maxLength(50,
                    errorText: "Maksimalno 50 karaktera."),
                FormBuilderValidators.match(
                  r'^[A-ZČĆŽĐŠ][a-zA-ZčćžđšČĆŽĐŠ\s]*$',
                  errorText:
                      "Ime mora početi velikim slovom i sadržavati samo slova.",
                ),
              ]),
            ),
            const SizedBox(height: 15),
            FormBuilderTextField(
              name: 'prezime',
              decoration: _decoration('Prezime', 'Unesite prezime'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                    errorText: "Prezime je obavezno."),
                FormBuilderValidators.maxLength(50,
                    errorText: "Maksimalno 50 karaktera."),
                FormBuilderValidators.match(
                  r'^[A-ZČĆŽĐŠ][a-zA-ZčćžđšČĆŽĐŠ\s]*$',
                  errorText:
                      "Prezime mora početi velikim slovom i sadržavati samo slova.",
                ),
              ]),
            ),
            const SizedBox(height: 15),
            FormBuilderTextField(
              name: 'telefon',
              decoration:
                  _decoration('Telefon', 'Unesite telefon (npr. +387...)'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                    errorText: "Telefon je obavezan."),
                FormBuilderValidators.match(
                  r'^\+\d{7,15}$',
                  errorText: 'Telefon mora početi sa + i imati 7-15 cifara.',
                ),
              ]),
            ),
            const SizedBox(height: 15),
            FormBuilderCheckbox(
              name: 'promijeniLozinku',
              title: const Text(
                'Promijeni lozinku',
                style: TextStyle(fontSize: 15),
              ),
              onChanged: (val) {
                if (!mounted) return;
                setState(() {
                  _promijeniLozinku = val ?? false;
                });
              },
            ),
            if (_promijeniLozinku) ...[
              const SizedBox(height: 15),
              FormBuilderTextField(
                name: 'staraLozinka',
                obscureText: _isOldPasswordHidden,
                decoration: _decoration('Stara lozinka', '').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_isOldPasswordHidden
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        _isOldPasswordHidden = !_isOldPasswordHidden;
                      });
                    },
                  ),
                ),
                validator: (val) {
                if (val == null || val.isEmpty) {
                    return 'Stara lozinka je obavezna.';
                  }

                  if (val != AuthProvider.password) {
                    return 'Unesite ispravnu lozinku.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),
              FormBuilderTextField(
                name: 'lozinka',
                obscureText: _isNewPasswordHidden,
                decoration: _decoration('Nova lozinka', '').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_isNewPasswordHidden
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        _isNewPasswordHidden = !_isNewPasswordHidden;
                      });
                    },
                  ),
                ),
                validator: (val) {
                  final oldPassword = _formKey.currentState?.fields['staraLozinka']?.value ?? '';
                  if (val == null || val.isEmpty) {
                    return 'Nova lozinka je obavezna.';
                  }
                  if (val.length < 6) {
                    return 'Najmanje 6 karaktera.';
                  }
                  if (val.length > 40) {
                    return 'Najviše 40 karaktera.';
                  }
                  if (val == oldPassword) {
                    return 'Nova lozinka ne može biti ista kao stara.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              FormBuilderTextField(
                name: 'lozinkaPotvrda',
                obscureText: _isConfirmPasswordHidden,
                decoration: _decoration('Potvrda lozinke', '').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordHidden
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                      });
                    },
                  ),
                ),
                validator: (val) {
                  final lozinka =
                      _formKey.currentState?.fields['lozinka']?.value;
                  if (val == null || val.isEmpty) {
                    return 'Potvrda je obavezna.';
                  }
                  if (val != lozinka) {
                    return 'Lozinke se ne podudaraju.';
                  }
                  return null;
                },  
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
                onPressed: () async {
                  if (!mounted) return;
                  final potvrda = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Potvrda"),
                      content: const Text("Da li ste sigurni da želite sačuvati promjene?"),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              ),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text(
                            "Ne",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            "Da",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (potvrda == true) {
                        if (!mounted) return;
                          await _save();
                        }
                      },
              icon: const Icon(Icons.check, color: Colors.black),
              label: const Text(
                "Sačuvaj",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 210, 193, 214),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _onDeaktivirajPressed,
              icon: const Icon(Icons.block, color: Colors.black),
              label: const Text(
                "Deaktiviraj profil",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 210, 209, 210),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

   void _onDeaktivirajPressed() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Deaktivacija profila"),
          content: const Text("Da li ste sigurni da želite deaktivirati svoj profil?"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Otkaži",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Deaktiviraj",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                try {
                  if (AuthProvider.korisnikId == null) throw UserException("KorisnikId je null.");
                  if (!mounted) return;
                  await _provider.deaktiviraj(AuthProvider.korisnikId!);

                  AuthProvider.username = null;
                  AuthProvider.password = null;
                  AuthProvider.korisnikId = null;
                  AuthProvider.ime = null;
                  AuthProvider.prezime = null;
                  AuthProvider.email = null;
                  AuthProvider.telefon = null;
                  AuthProvider.uloge = null;
                  AuthProvider.slika = null;
                  AuthProvider.isSignedIn = false;
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color.fromARGB(255, 138, 182, 140), 
                      duration: Duration(milliseconds: 1500),
                      content: Center(
                        child: Text(
                          "Profil je uspješno deaktiviran.",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                  if (!mounted) return;
                  await Future.delayed(const Duration(milliseconds: 1500));

                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
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
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _save() async {
    final isValid = _formKey.currentState?.saveAndValidate();
    if (isValid != true) return;

    final formValues = Map<String, dynamic>.from(_formKey.currentState!.value);
    final request = {
      'ime': formValues['ime'],
      'prezime': formValues['prezime'],
      'email': AuthProvider.email,
      'telefon': formValues['telefon'],
    };

    if (_promijeniLozinku) {
      request['staraLozinka'] = formValues['staraLozinka'];
      request['lozinka'] = formValues['lozinka'];
      request['lozinkaPotvrda'] = formValues['lozinkaPotvrda'];
    }

    try {
      if (!mounted) return;
      await _provider.update(AuthProvider.korisnikId!, request);

      if (_promijeniLozinku &&
          formValues['lozinka'] != null &&
          formValues['lozinka'] != '') {
        AuthProvider.password = formValues['lozinka'];
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor:  Color.fromARGB(255, 138, 182, 140), 
          duration:  Duration(milliseconds: 1500),
          content:  Center(
            child: Text(
              "Profil uspješno ažuriran.",
            ),
          ),
        ),
      );
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;
      Navigator.pop(context, true);

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
}