import 'dart:io';
import 'package:daku/models/saving_goal.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddGoalScreen extends StatefulWidget {
  final SavingGoal? goalToEdit;

  const AddGoalScreen({this.goalToEdit});

  @override
  _AddGoalScreenState createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  File? _selectedImage;
  late Box<SavingGoal> goalBox;

  @override
  void initState() {
    super.initState();
    goalBox = Hive.box<SavingGoal>('goals');

    if (widget.goalToEdit != null) {
      _titleController.text = widget.goalToEdit!.title;
      _targetController.text = NumberFormat.decimalPattern(
        'id',
      ).format(widget.goalToEdit!.targetAmount);
      _selectedImage = File(widget.goalToEdit!.imagePath);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  String _unformatNumber(String value) {
    return value.replaceAll('.', '').replaceAll(',', '');
  }

  void _saveGoal() async {
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      final title = _titleController.text.trim();
      final target =
          double.tryParse(_unformatNumber(_targetController.text.trim())) ?? 0;

      if (widget.goalToEdit != null) {
        // Update data
        widget.goalToEdit!
          ..title = title
          ..targetAmount = target
          ..imagePath = _selectedImage!.path;
        await widget.goalToEdit!.save();
      } else {
        // Buat baru
        final newGoal = SavingGoal(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          targetAmount: target,
          currentAmount: 0,
          imagePath: _selectedImage!.path,
          createdAt: DateTime.now(),
        );
        await goalBox.add(newGoal);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.goalToEdit != null;

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
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0B192C),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Color(0xFF0B192C),
        appBar: AppBar(
          backgroundColor: Color(0xFF0B192C),
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            isEdit ? "Edit Tujuan" : "Tambah Tujuan",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child:
                      _selectedImage != null
                          ? Image.file(
                            _selectedImage!,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                          : Container(
                            height: 150,
                            color: Color(0xFF1E3E62),
                            child: Icon(
                              Icons.add_a_photo,
                              size: 50,
                              color: Colors.white70,
                            ),
                          ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: "Judul Tujuan"),
                  style: TextStyle(color: Colors.white),
                  validator:
                      (val) =>
                          val == null || val.isEmpty ? "Harus diisi" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _targetController,
                  decoration: InputDecoration(labelText: "Target Nominal (Rp)"),
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
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveGoal,
                  child: Text(
                    isEdit ? "Simpan Perubahan" : "Tambah Tujuan",
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
