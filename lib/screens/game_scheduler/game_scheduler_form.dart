import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart'; 
import 'package:provider/provider.dart';
import 'package:court_finder_mobile/models/game_scheduler/event_entry.dart'; // Import Model Event

class GameSchedulerFormPage extends StatefulWidget {
  final EventEntry? event; // Tambahkan parameter opsional ini untuk Edit

  const GameSchedulerFormPage({super.key, this.event});

  @override
  State<GameSchedulerFormPage> createState() => _GameSchedulerFormPageState();
}

class _GameSchedulerFormPageState extends State<GameSchedulerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryGreen = const Color(0xFF3F6E48);

  // Variable Form
  String _title = "";
  String _description = "";
  String _location = "";
  String? _sportType; 
  String _eventType = "public"; 
  
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  final Map<String, String> _sportOptions = {
    'basketball': 'Basketball',
    'futsal': 'Futsal',
    'soccer': 'Soccer',
    'badminton': 'Badminton',
    'tennis': 'Tennis',
    'baseball': 'Baseball',
    'volleyball': 'Volleyball',
    'padel': 'Padel',
    'golf': 'Golf',
    'football': 'Football',
    'softball': 'Softball',
    'table_tennis': 'Table Tennis',
  };

  @override
  void initState() {
    super.initState();
    _sportType = _sportOptions.keys.first;

    // --- LOGIKA EDIT: Jika ada data event, isi form ---
    if (widget.event != null) {
      final f = widget.event!.fields;
      _title = f.title;
      _description = f.description;
      _location = f.location;
      _eventType = f.eventType.toLowerCase(); // pastikan lowercase
      
      // Cek apakah sportType ada di opsi, kalau tidak default ke basketball
      if (_sportOptions.containsKey(f.sportType)) {
        _sportType = f.sportType;
      }

      _titleController.text = _title;
      _descController.text = _description;
      _locController.text = _location;

      // Isi Tanggal
      _selectedDate = f.scheduledDate;
      _dateController.text = "${f.scheduledDate.year}-${f.scheduledDate.month.toString().padLeft(2,'0')}-${f.scheduledDate.day.toString().padLeft(2,'0')}";

      // Isi Waktu (Format dari Django biasanya HH:MM:SS, kita ambil HH:MM)
      // Contoh "14:30:00" -> ambil "14:30"
      String startRaw = f.startTime.length >= 5 ? f.startTime.substring(0, 5) : f.startTime;
      String endRaw = f.endTime.length >= 5 ? f.endTime.substring(0, 5) : f.endTime;

      _startTimeController.text = startRaw;
      _endTimeController.text = endRaw;

      // Convert String ke TimeOfDay untuk validasi
      int startH = int.parse(startRaw.split(":")[0]);
      int startM = int.parse(startRaw.split(":")[1]);
      _startTime = TimeOfDay(hour: startH, minute: startM);

      int endH = int.parse(endRaw.split(":")[0]);
      int endM = int.parse(endRaw.split(":")[1]);
      _endTime = TimeOfDay(hour: endH, minute: endM);
    }
  }

  // ... (Fungsi _selectDate dan _selectTime SAMA SEPERTI SEBELUMNYA, tidak berubah) ...
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        String formattedTime = "${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}";
        if (isStart) {
          _startTime = picked;
          _startTimeController.text = formattedTime;
        } else {
          _endTime = picked;
          _endTimeController.text = formattedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.event != null; // Cek mode Edit

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Event' : 'Create New Event', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: _primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Event Title"),
              TextFormField(
                controller: _titleController, // Pakai controller
                decoration: _inputDecoration("Ex: Latihan Badminton Ceria"),
                onChanged: (String? value) => setState(() => _title = value!),
                validator: (value) => value == null || value.isEmpty ? "Title cannot be empty!" : null,
              ),
              const SizedBox(height: 24),

              _buildLabel("Description"),
              TextFormField(
                controller: _descController, // Pakai controller
                decoration: _inputDecoration("Describe details..."),
                maxLines: 5,
                onChanged: (String? value) => setState(() => _description = value!),
                validator: (value) => value == null || value.isEmpty ? "Description cannot be empty!" : null,
              ),
              const SizedBox(height: 24),

              _buildLabel("Scheduled Date"),
              TextFormField(
                controller: _dateController,
                decoration: _inputDecoration("YYYY-MM-DD").copyWith(suffixIcon: Icon(Icons.calendar_today, color: _primaryGreen)),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildLabel("Start Time"),
                      TextFormField(
                        controller: _startTimeController,
                        decoration: _inputDecoration("HH:MM").copyWith(suffixIcon: Icon(Icons.access_time, color: _primaryGreen)),
                        readOnly: true,
                        onTap: () => _selectTime(context, true),
                        validator: (value) => value == null || value.isEmpty ? "Required" : null,
                      ),
                    ])),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildLabel("End Time"),
                      TextFormField(
                        controller: _endTimeController,
                        decoration: _inputDecoration("HH:MM").copyWith(suffixIcon: Icon(Icons.access_time, color: _primaryGreen)),
                        readOnly: true,
                        onTap: () => _selectTime(context, false),
                        validator: (value) => value == null || value.isEmpty ? "Required" : null,
                      ),
                    ])),
                ],
              ),
              const SizedBox(height: 24),

              _buildLabel("Location"),
              TextFormField(
                controller: _locController, // Pakai controller
                decoration: _inputDecoration("Ex: GOR Sudirman"),
                onChanged: (String? value) => setState(() => _location = value!),
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),

              _buildLabel("Event Type"),
              Row(children: [
                Expanded(child: _buildRadioButton("Public", "public")),
                const SizedBox(width: 10),
                Expanded(child: _buildRadioButton("Private", "private")),
              ]),
              const SizedBox(height: 24),

              _buildLabel("Sport Type"),
              DropdownButtonFormField<String>(
                value: _sportType,
                decoration: _inputDecoration("Select Sport"),
                items: _sportOptions.entries.map((entry) {
                  return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                }).toList(),
                onChanged: (String? val) => setState(() => _sportType = val),
                validator: (value) => value == null ? "Required" : null,
              ),
              
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                        final request = Provider.of<CookieRequest>(context, listen: false);

                        // Tentukan URL dan Endpoint
                        // Jika Edit -> edit-flutter/<id>
                        // Jika Create -> create-flutter/
                        String url = isEdit 
                            ? "https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/event_list/edit-flutter/${widget.event!.pk}/"
                            : "https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/event_list/create-flutter/";

                        try {
                          final response = await request.postJson(
                            url, 
                            jsonEncode(<String, String>{
                                'title': _titleController.text, // Ambil dari controller agar data editan terambil
                                'description': _descController.text,
                                'scheduled_date': _dateController.text,
                                'start_time': _startTimeController.text,
                                'end_time': _endTimeController.text,
                                'location': _locController.text,
                                'event_type': _eventType,
                                'sport_type': _sportType!,
                            }),
                          );

                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response['message'] ?? "Event berhasil disimpan!")),
                            );
                            Navigator.pop(context, true); 
                          } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: ${response['message']}")),
                              );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                          );
                        }
                    }
                  },
                  child: Text(
                    isEdit ? "Update Event" : "Save Event",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
               const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Helper widgets _buildLabel, _inputDecoration, _buildRadioButton SAMA SEPERTI SEBELUMNYA) ...
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800])),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Widget _buildRadioButton(String label, String value) {
    bool isSelected = _eventType == value;
    return InkWell(
      onTap: () => setState(() => _eventType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3F6E48).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF3F6E48) : Colors.grey.shade200, width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xFF3F6E48) : Colors.grey, size: 20),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF3F6E48) : Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}