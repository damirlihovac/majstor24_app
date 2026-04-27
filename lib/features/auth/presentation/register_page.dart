import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _formKey = GlobalKey<FormState>();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final zip = TextEditingController();
  final city = TextEditingController();
  final password = TextEditingController();
  final repeatPassword = TextEditingController();
  final smsCode = TextEditingController();

  bool isLoading = false;
  bool smsGenerated = false;

  final String baseUrl = "https://majstor24.ba/api/";

  // ================= PHONE NORMALIZATION =================

  String normalizePhone(String input) {
    String cleaned = input.replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleaned.startsWith('06')) {
      cleaned = '+3876${cleaned.substring(2)}';
    } else if (cleaned.startsWith('6') && !cleaned.startsWith('3876')) {
      cleaned = '+387$cleaned';
    } else if (cleaned.startsWith('3876')) {
      cleaned = '+$cleaned';
    }

    return cleaned;
  }

  bool isValidBiHNumber(String value) {
    final regex = RegExp(r'^\+3876\d{7,8}$');
    return regex.hasMatch(value);
  }

  // ================= EMAIL CHECK =================

  Future<bool> emailExists() async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}check_email.php"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "email": email.text.trim(),
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true && data["status"] == "exists") {
        return true;
      }

      return false;

    } catch (_) {
      return false;
    }
  }

  // ================= GENERATE SMS =================

  Future<void> generateSms() async {

  // Ručna validacija bez SMS polja
  if (firstName.text.isEmpty ||
      lastName.text.isEmpty ||
      mobile.text.isEmpty ||
      email.text.isEmpty ||
      address.text.isEmpty ||
      zip.text.isEmpty ||
      city.text.isEmpty ||
      password.text.isEmpty ||
      repeatPassword.text.isEmpty) {

    showMsg("Popunite sva polja prije generisanja SMS koda.");
    return;
  }

  if (!isValidBiHNumber(mobile.text.trim())) {
    showMsg("Broj mora biti u formatu +3876xxxxxxx");
    return;
  }

  if (password.text != repeatPassword.text) {
    showMsg("Šifre se ne poklapaju.");
    return;
  }

  setState(() => isLoading = true);

  if (await emailExists()) {
    showMsg("Email već postoji.");
    setState(() => isLoading = false);
    return;
  }

  try {

    final response = await http.post(
      Uri.parse("${baseUrl}submit_smss.php"),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "first_name": firstName.text.trim(),
        "last_name": lastName.text.trim(),
        "mobile_phone": mobile.text.trim(),
        "email": email.text.trim(),
        "sifra": password.text.trim(),
        "adresa": address.text.trim(),
        "pttbroj": zip.text.trim(),
        "mjesto": city.text.trim(),
      },
    );

    final data = jsonDecode(response.body);

    if (data["success"] == true) {

      setState(() {
        smsGenerated = true;
      });

      showMsg("SMS kod poslan. Unesite kod za završetak registracije.");

    } else {
      showMsg(data["message"] ?? "Greška.");
    }

  } catch (e) {
    showMsg("Greška servera.");
  }

  setState(() => isLoading = false);
}
  // ================= REGISTER =================

  Future<void> register() async {

    if (!smsGenerated) {
      showMsg("Prvo generišite SMS kod.");
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${baseUrl}submit_reg.php"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "sms_kod": smsCode.text.trim(),
          "password": password.text.trim(),
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {

        showMsg("Registracija uspješna.");

        await Future.delayed(const Duration(milliseconds: 800));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
        );

      } else {
        showMsg(data["message"] ?? "Greška pri registraciji.");
      }

    } catch (_) {
      showMsg("Greška servera.");
    }

    setState(() => isLoading = false);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Registracija")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              input(firstName, "Ime"),
              input(lastName, "Prezime"),
              phoneInput(),
              input(email, "Email"),
              input(address, "Ulica i broj"),

              Row(
                children: [
                  Expanded(child: input(zip, "PTT broj")),
                  const SizedBox(width: 10),
                  Expanded(child: input(city, "Mjesto")),
                ],
              ),

              input(password, "Šifra", obscure: true),
              input(repeatPassword, "Ponovi šifru", obscure: true),

              const SizedBox(height: 15),

              ElevatedButton(
                onPressed: isLoading ? null : generateSms,
                child: const Text("Generiši SMS kod"),
              ),

              const SizedBox(height: 15),

              input(smsCode, "SMS kod"),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (!smsGenerated || isLoading) ? null : register,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Registracija"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PHONE FIELD =================

  Widget phoneInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: mobile,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: "Mobitel (+3876xxxxxxx)",
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
        ),
        onChanged: (value) {
          final formatted = normalizePhone(value);

          if (formatted != value) {
            mobile.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(
                offset: formatted.length,
              ),
            );
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Obavezno polje";
          }
          if (!isValidBiHNumber(value)) {
            return "Neispravan format (+3876xxxxxxx)";
          }
          return null;
        },
      ),
    );
  }

  Widget input(TextEditingController controller, String label,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
        ).copyWith(labelText: label),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Obavezno polje";
          }
          return null;
        },
      ),
    );
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}