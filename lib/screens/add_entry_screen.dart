import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:daku/models/saving_entry.dart';
import 'package:daku/models/saving_goal.dart';
import 'package:hive/hive.dart';

class AddEntryScreen extends StatefulWidget {
  final SavingGoal goal;
  final SavingEntry? entryToEdit;

  const AddEntryScreen({required this.goal, this.entryToEdit});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late Box<SavingEntry> entryBox;
  late Box<SavingGoal> goalBox;
  bool get isEdit => widget.entryToEdit != null;

  @override
  void initState() {
    super.initState();
    entryBox = Hive.box<SavingEntry>('entries');
    goalBox = Hive.box<SavingGoal>('goals');
    if (isEdit) {
      _amountController.text = NumberFormat.decimalPattern(
        'id',
      ).format(widget.entryToEdit!.amount.toInt());
      _noteController.text = widget.entryToEdit!.note ?? '';
      _selectedDate = widget.entryToEdit!.date;
    }
  }

  String _unformatNumber(String value) {
    return value.replaceAll('.', '').replaceAll(',', '');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: Color(0xFF3A8DFF),
                surface: Color(0xFF1E3E62),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;
    final amount =
        double.tryParse(_unformatNumber(_amountController.text.trim())) ?? 0;
    final note = _noteController.text.trim();
    final date = _selectedDate;
    final goal = widget.goal;
    double oldAmount = 0;
    if (isEdit) oldAmount = widget.entryToEdit!.amount;

    if (isEdit) {
      widget.entryToEdit!
        ..amount = amount
        ..note = note
        ..date = date;
      await widget.entryToEdit!.save();
      goal.currentAmount = goal.currentAmount - oldAmount + amount;
      await goal.save();
    } else {
      final newEntry = SavingEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        goalId: goal.id,
        amount: amount,
        note: note,
        date: date,
      );
      await entryBox.add(newEntry);
      goal.currentAmount += amount;
      await goal.save();
    }
    Navigator.pop(context, true);
  }

  Future<void> _deleteEntry() async {
    if (!isEdit) return;
    final confirm = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Color(0xFF1E3E62),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                SizedBox(width: 8),
                Text(
                  "Hapus Catatan?",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              "Yakin mau hapus catatan ini?",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Batal", style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: Text(
                  "Hapus",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
    if (confirm == true) {
      final goal = widget.goal;
      goal.currentAmount -= widget.entryToEdit!.amount;
      await goal.save();
      await widget.entryToEdit!.delete();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF3A8DFF), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF1E3E62)),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white54),
          errorStyle: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
          fillColor: Color(0xFF1E3E62),
          filled: true,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFF3A8DFF),
          selectionColor: Color(0xFF1E3E62),
          selectionHandleColor: Color(0xFF3A8DFF),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: Color(0xFF1E3E62),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Color(0xFF0B192C),
        appBar: AppBar(
          backgroundColor: Color(0xFF0B192C),
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            isEdit ? "Edit Catatan Nabung" : "Tambah Catatan Nabung",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions:
              isEdit
                  ? [
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                      tooltip: 'Hapus Catatan',
                      onPressed: _deleteEntry,
                    ),
                  ]
                  : null,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: "Nominal (Rp)",
                    hintText: "Contoh: 50.000",
                  ),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  validator: (val) {
                    final number = double.tryParse(_unformatNumber(val ?? ''));
                    if (number == null || number <= 0)
                      return "Masukkan nominal yang valid";
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: "Catatan (opsional)",
                    hintText: "Misal: uang saku, THR, dll",
                  ),
                  style: TextStyle(color: Colors.white),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    "Tanggal",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy').format(_selectedDate),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.calendar_today, color: Color(0xFF3A8DFF)),
                    onPressed: _pickDate,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveEntry,
                  child: Text(
                    isEdit ? "Simpan Perubahan" : "Tambah Catatan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('.', '');
    if (text.isEmpty) return newValue.copyWith(text: '');
    final number = int.parse(text);
    final formatted = NumberFormat.decimalPattern('id').format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
