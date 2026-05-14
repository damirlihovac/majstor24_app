import 'package:flutter/material.dart';

class RequestConfirmationModalResult {
  final DateTime? date;
  final TimeOfDay? time;
  final bool hitno;
  final bool poziv;

  RequestConfirmationModalResult({
    required this.date,
    required this.time,
    required this.hitno,
    required this.poziv,
  });

  Map<String, dynamic> toJson() {
    String? d;
    String? t;

    if (date != null) {
      d = "${date!.year.toString().padLeft(4, '0')}-"
          "${date!.month.toString().padLeft(2, '0')}-"
          "${date!.day.toString().padLeft(2, '0')}";
    }

    if (time != null) {
      t =
          "${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}";
    }

    return {
      "datum": d,
      "vrijeme": t,
      "hitno": hitno ? 1 : 0,
      "poziv": poziv ? 1 : 0,
    };
  }
}

class RequestConfirmationModal extends StatefulWidget {
  const RequestConfirmationModal({super.key});

  @override
  State<RequestConfirmationModal> createState() =>
      _RequestConfirmationModalState();
}

class _RequestConfirmationModalState extends State<RequestConfirmationModal> {
  bool _hitno = false;
  bool _poziv = false;

  DateTime? _selectedDate;

  int _selectedHour = 9;
  int _selectedMinuteIndex = 0;

  final List<int> minutes = [0, 15, 30, 45];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 5));
  }

  TimeOfDay get _time =>
      TimeOfDay(hour: _selectedHour, minute: minutes[_selectedMinuteIndex]);

  String _formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}."
        "${d.month.toString().padLeft(2, '0')}."
        "${d.year}.";
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

/* ================= HEADER ================= */

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFF1E293B),
        Color(0xFF0F172A),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
  ),
  child: const Text(
    "Potvrda zahtjeva",
    style: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  ),
),

          /// BODY
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text("Datum i vrijeme dolaska majstora"),

                const SizedBox(height: 10),

                Row(
                  children: [

                    /// DATE
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () async {
                          final tomorrow =
                              DateTime.now().add(const Duration(days: 5));

                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? tomorrow,
                            firstDate: tomorrow,
                            lastDate:
                                tomorrow.add(const Duration(days: 60)),
                          );

                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          decoration: _boxDecoration(),
                          child: Text(
                            _selectedDate == null
                                ? "mm/dd/yyyy"
                                : _formatDate(_selectedDate!),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// HOUR
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: _boxDecoration(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButton<int>(
  value: _selectedHour,
  isExpanded: true,
  underline: const SizedBox(),
  items: List.generate(12, (i) => i + 8)
      .map((e) => DropdownMenuItem(
            value: e,
            child: Text(
              e.toString().padLeft(2, '0'),
              style: const TextStyle(fontSize: 14),
            ),
          ))
      .toList(),
  onChanged: (v) => setState(() => _selectedHour = v!),
),
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// MINUTE
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: _boxDecoration(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButton<int>(
                          value: minutes[_selectedMinuteIndex],
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: minutes
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e.toString().padLeft(2, '0'),
                                      style:
                                          const TextStyle(fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() =>
                              _selectedMinuteIndex =
                                  minutes.indexOf(v!)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                CheckboxListTile(
                  value: _poziv,
                  onChanged: (v) => setState(() => _poziv = v!),
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Neka me majstor pozove"),
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                CheckboxListTile(
                  value: _hitno,
                  onChanged: (v) => setState(() => _hitno = v!),
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    "Hitna intervencija",
                    style: TextStyle(color: Colors.red),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(
                        RequestConfirmationModalResult(
                          date: _hitno ? null : _selectedDate,
                          time: _hitno ? null : _time,
                          hitno: _hitno,
                          poziv: _poziv,
                        ),
                      );
                    },
                    child: const Text("Dalje"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}