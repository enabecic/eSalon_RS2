import 'package:esalon_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:esalon_mobile/providers/korisnik_provider.dart';
import 'package:esalon_mobile/providers/uloga_provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class RegistracijaScreen extends StatefulWidget {
  const RegistracijaScreen({super.key});

  @override
  State<RegistracijaScreen> createState() => _RegistracijaScreenState();
}

class _RegistracijaScreenState extends State<RegistracijaScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late KorisnikProvider _korisnikProvider;
  late UlogaProvider _ulogaProvider;

  int? _korisnikUlogaId;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isHidden = true;
  bool _isHiddenConfirm = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _korisnikProvider = context.read<KorisnikProvider>();
    _ulogaProvider = context.read<UlogaProvider>();
    _loadKorisnikUloga();
  }

  Future<void> _loadKorisnikUloga() async {
    try {
      if (!mounted) return;
      final result = await _ulogaProvider.get();
      final korisnikUloga =
          result.result.firstWhere((x) => x.naziv == "Klijent");
      if (!mounted) return;
      setState(() {
        _korisnikUlogaId =korisnikUloga.ulogaId;
      });
    } catch (e) {
      if (!mounted) return;
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Greška',
        text: 'Neuspješno učitavanje uloge Klijent.',
        confirmBtnText: 'OK',
        confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
        textColor: Colors.black,
        titleColor: Colors.black,
      );
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  InputDecoration _decoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _korisnikUlogaId == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/pozadina.png',
                    fit: BoxFit.fill,
                  ),
                ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: FormBuilder(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Kreirajmo vaš račun!",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 150,
                            ),
                          ),
                          const SizedBox(height: 17),
                          const Text(
                            "Unesite vaše podatke:",
                            style: TextStyle(fontSize: 17),
                          ),
                          const SizedBox(height: 17),
                          FormBuilderTextField(
                            name: 'ime',
                            decoration: _decoration('Ime', 'Unesite ime'),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                  errorText: "Ime je obavezno."),
                              FormBuilderValidators.minLength(1,
                                  errorText: "Ime ne može biti prazno."),
                              FormBuilderValidators.maxLength(50,
                                  errorText:
                                      "Ime može imati najviše 50 karaktera."),
                              FormBuilderValidators.match(
                                r'^[A-ZČĆŽĐŠ][a-zA-ZčćžđšČĆŽĐŠ\s]*$',
                                errorText:
                                    "Ime mora početi velikim slovom i sadržavati samo slova.",
                              ),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          FormBuilderTextField(
                            name: 'prezime',
                            decoration:
                                _decoration('Prezime', 'Unesite prezime'),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                  errorText: "Prezime je obavezno."),
                              FormBuilderValidators.minLength(1,
                                  errorText: "Prezime ne može biti prazno."),
                              FormBuilderValidators.maxLength(50,
                                  errorText:
                                      "Prezime može imati najviše 50 karaktera."),
                              FormBuilderValidators.match(
                                r'^[A-ZČĆŽĐŠ][a-zA-ZčćžđšČĆŽĐŠ\s]*$',
                                errorText:
                                    "Prezime mora početi velikim slovom i sadržavati samo slova.",
                              ),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          FormBuilderTextField(
                            name: "korisnickoIme",
                            decoration: _decoration(
                                'Korisničko ime', 'Unesite korisničko ime'),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                  errorText: "Korisničko ime je obavezno."),
                              FormBuilderValidators.minLength(4,
                                  errorText: "Minimalno 4 karaktera."),
                              FormBuilderValidators.maxLength(30,
                                  errorText: "Maksimalno 30 karaktera."),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          FormBuilderTextField(
                            name: "email",
                            decoration:
                                _decoration('Email', 'Unesite email adresu'),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                  errorText: "Email je obavezan."),
                              FormBuilderValidators.email(
                                  errorText: 'Neispravan email.'),
                              FormBuilderValidators.maxLength(100,
                                  errorText:
                                      "Email može imati najviše 100 karaktera."),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          FormBuilderTextField(
                            name: "telefon",
                            decoration: _decoration(
                                'Telefon', 'Unesite telefon (npr. +387...)'),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                  errorText: "Telefon je obavezan."),
                              FormBuilderValidators.match(
                                r'^\+\d{7,15}$',
                                errorText:
                                    'Telefon mora početi sa + i imati 7-15 cifara.',
                              ),
                              FormBuilderValidators.maxLength(20,
                                  errorText:
                                      "Telefon može imati najviše 20 karaktera."),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _isHidden,
                            decoration: InputDecoration(
                              labelText: "Lozinka",
                              hintText: "Unesite lozinku",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              filled: true, 
                              fillColor: Colors.white, 
                              suffixIcon: IconButton(
                                icon: Icon(_isHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  if (!mounted) return;
                                  setState(() {
                                    _isHidden = !_isHidden;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Unesite lozinku';
                              }
                              if (value.length < 6) {
                                return 'Lozinka mora imati minimalno 6 karaktera';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _isHiddenConfirm,
                            decoration: InputDecoration(
                              labelText: "Potvrdi lozinku",
                              hintText: "Ponovo unesite lozinku",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              filled: true, 
                              fillColor: Colors.white, 
                              suffixIcon: IconButton(
                                icon: Icon(_isHiddenConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  if (!mounted) return;
                                  setState(() {
                                    _isHiddenConfirm = !_isHiddenConfirm;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Potvrdite lozinku';
                              }
                              if (value != _passwordController.text) {
                                return 'Lozinke se ne podudaraju';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: _isSaving
                                  ? null
                                  : () async {
                                    if (!mounted) return;
                                      final potvrda = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Registracija"),
                                          content: const Text(
                                              "Da li ste sigurni da želite kreirati račun?"),
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
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold),
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
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold),
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
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>((states) {
                                  if (states.contains(MaterialState.hovered)) {
                                    return Colors.deepPurple;
                                  }
                                  return Colors.deepPurple;
                                }),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                elevation: MaterialStateProperty.all(4),
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                shadowColor: MaterialStateProperty.all(Colors.black54),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check, color: Colors.white, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          "Kreirajte račun",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Imate račun?",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Prijavite se!",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _save() async {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) return;
    if (!mounted) return;
    setState(() => _isSaving = true);

    final formValues = Map<String, dynamic>.from(_formKey.currentState!.value);

    final request = {
      'ime': formValues['ime'],
      'prezime': formValues['prezime'],
      'korisnickoIme': formValues['korisnickoIme'],
      'email': formValues['email'],
      'telefon': formValues['telefon'],
      'lozinka': _passwordController.text,
      'lozinkaPotvrda': _confirmPasswordController.text,
      'uloge': [_korisnikUlogaId],
    };

    try {
      if (!mounted) return;
      await _korisnikProvider.insert(request);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromARGB(255, 138, 182, 140), 
          duration: Duration(milliseconds: 2000),
          content: Center(
            child: Text(
              "Račun je uspješno kreiran. Molimo prijavite se.",
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ),
      );
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 2000));

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
        title: "Greška",
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
}