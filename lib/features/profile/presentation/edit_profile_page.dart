import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> initialProfile;

  const EditProfilePage({
    super.key,
    required this.initialProfile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _zipCtrl;
  late final TextEditingController _cityCtrl;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;

    _firstNameCtrl = TextEditingController(text: p['firstname'] ?? '');
    _lastNameCtrl  = TextEditingController(text: p['lastname'] ?? '');
    _streetCtrl    = TextEditingController(text: p['mailingstreet'] ?? '');
    _zipCtrl       = TextEditingController(text: p['mailingzip'] ?? '');
    _cityCtrl      = TextEditingController(text: p['mailingcity'] ?? '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _streetCtrl.dispose();
    _zipCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  String? _required(String? v, String label) {
    if ((v ?? '').trim().isEmpty) return '$label je obavezno.';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final api = ApiClient();

final data = await api.post(
  'profile/update.php',
  body: {
    'firstname': _firstNameCtrl.text.trim(),
    'lastname': _lastNameCtrl.text.trim(),
    'mailingstreet': _streetCtrl.text.trim(),
    'mailingzip': _zipCtrl.text.trim(),
    'mailingcity': _cityCtrl.text.trim(),
  },
);

      if (!mounted) return;

      if (data['success'] == true) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _error = data['error'] ?? 'Greška pri snimanju.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uredi profil')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),

              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(labelText: 'Ime'),
                validator: (v) => _required(v, 'Ime'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Prezime'),
                validator: (v) => _required(v, 'Prezime'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _streetCtrl,
                decoration: const InputDecoration(labelText: 'Ulica'),
                validator: (v) => _required(v, 'Ulica'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _zipCtrl,
                decoration: const InputDecoration(labelText: 'Poštanski broj'),
                validator: (v) => _required(v, 'Poštanski broj'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(labelText: 'Grad'),
                validator: (v) => _required(v, 'Grad'),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const CircularProgressIndicator()
                    : const Text('Sačuvaj'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}