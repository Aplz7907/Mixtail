import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';
// import '../widgets/pixel_button.dart'; // เปิดถ้ามี Widget ปุ่ม

class AddCocktailScreen extends StatefulWidget {
  const AddCocktailScreen({super.key});

  @override
  State<AddCocktailScreen> createState() => _AddCocktailScreenState();
}

class _AddCocktailScreenState extends State<AddCocktailScreen> {
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _ingredientsController = TextEditingController();
  File? _image;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      // ✅ เพิ่มการตั้งค่าลดขนาดรูป ป้องกันแอปเด้งเพราะรูปใหญ่เกิน (Memory Leak)
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000, // จำกัดความกว้างไม่เกิน 1000px
        imageQuality: 85, // ลดคุณภาพลงนิดหน่อยเพื่อประหยัด RAM
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _saveRecipe() async {
    if (_nameController.text.isEmpty || _instructionsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill name and instructions!')),
      );
      return;
    }

    // 1. สร้างข้อมูล
    final newRecipe = Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      instructions: _instructionsController.text,
      imageUrl: _image?.path ?? '',
      ingredients: _ingredientsController.text,
      isCustom: true,
      sourceMood: "CUSTOM",
    );

    // 2. โหลดรายการเก่ามา
    final prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList('my_mixtail') ?? [];

    // 3. เพิ่มรายการใหม่เข้าไป
    savedList.add(jsonEncode(newRecipe.toJson()));

    // 4. บันทึกกลับลงเครื่อง
    await prefs.setStringList('my_mixtail', savedList);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved your recipe! 🍸')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        title: const Text('ADD NEW RECIPE 📝', style: TextStyle(fontFamily: 'PixelFont')),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: _image != null
                    ? Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        // ✅ ใส่ตัวดัก Error ป้องกันแอปเด้งจอแดง
                        errorBuilder: (context, error, stackTrace) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.broken_image, color: Colors.red, size: 40),
                              SizedBox(height: 5),
                              Text("Error loading image", style: TextStyle(color: Colors.red, fontFamily: 'PixelFont', fontSize: 12)),
                            ],
                          );
                        },
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt, color: Colors.grey, size: 50),
                          Text("TAP TO ADD PHOTO", style: TextStyle(color: Colors.grey, fontFamily: 'PixelFont')),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField("Cocktail Name", _nameController),
            const SizedBox(height: 10),
            _buildTextField("Ingredients", _ingredientsController),
            const SizedBox(height: 10),
            _buildTextField("Instructions", _instructionsController, maxLines: 5),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: const BeveledRectangleBorder()),
                onPressed: _saveRecipe,
                child: const Text("SAVE RECIPE 💾", style: TextStyle(color: Colors.black, fontFamily: 'PixelFont', fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontFamily: 'PixelFont'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.orange, fontFamily: 'PixelFont'),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
        filled: true,
        fillColor: Colors.black,
      ),
    );
  }
}
