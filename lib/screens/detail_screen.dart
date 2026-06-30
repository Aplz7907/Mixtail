import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';
import '../widgets/pixel_button.dart';

class DetailScreen extends StatefulWidget {
  final Recipe recipe;
  final bool allowSave; // ✅ ตัวแปรสั่งปิด/เปิดปุ่ม

  // ตั้งค่าเริ่มต้นเป็น true (ให้โชว์ปุ่ม)
  const DetailScreen({
    super.key,
    required this.recipe,
    this.allowSave = true,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Future<void> _addToMixtail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedList = prefs.getStringList('my_mixtail') ?? [];

      bool alreadySaved = savedList.any((item) {
        final Map<String, dynamic> data = jsonDecode(item);
        return data['id'] == widget.recipe.id;
      });

      if (alreadySaved) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Already saved! 🍷')));
        return;
      }

      savedList.add(jsonEncode(widget.recipe.toJson()));
      await prefs.setStringList('my_mixtail', savedList);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to Mixtail! 💾'), backgroundColor: Colors.green));
      }
    } catch (e) {
      print("Error saving: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;
    if (widget.recipe.imageUrl.startsWith('http')) {
      imageProvider = NetworkImage(widget.recipe.imageUrl);
    } else if (widget.recipe.imageUrl.isNotEmpty) {
      imageProvider = FileImage(File(widget.recipe.imageUrl));
    } else {
      imageProvider = const AssetImage('assets/images/placeholder.png');
    }

    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        title: Text(widget.recipe.name.toUpperCase(), style: const TextStyle(fontFamily: 'PixelFont', fontSize: 16)),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 4),
                  image: DecorationImage(
                      image: imageProvider, fit: BoxFit.cover, onError: (_, __) => const Icon(Icons.broken_image, size: 50, color: Colors.orange))),
            ),
            const SizedBox(height: 20),
            Text(widget.recipe.name, style: const TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 24)),

            if (widget.recipe.sourceMood != null) ...[
              const SizedBox(height: 5),
              Text("VIBE: ${widget.recipe.sourceMood}", style: const TextStyle(color: Colors.grey, fontFamily: 'PixelFont', fontSize: 12)),
            ],

            const Divider(color: Colors.orange, height: 30),

            const Text("INGREDIENTS:", style: TextStyle(color: Colors.orange, fontFamily: 'PixelFont', fontSize: 18)),
            const SizedBox(height: 10),
            Text(widget.recipe.ingredients.isNotEmpty ? widget.recipe.ingredients : "See instructions below.",
                style: const TextStyle(color: Colors.white, fontFamily: 'PixelFont', height: 1.5, fontSize: 14)),

            const SizedBox(height: 20),

            const Text("INSTRUCTIONS:", style: TextStyle(color: Colors.orange, fontFamily: 'PixelFont', fontSize: 18)),
            const SizedBox(height: 10),
            Text(widget.recipe.instructions, style: const TextStyle(color: Colors.white, fontFamily: 'PixelFont', height: 1.5, fontSize: 14)),

            const SizedBox(height: 40),

            // ❌👇 จุดสำคัญ: ถ้า allowSave เป็น false ปุ่มจะหายไป
            if (widget.allowSave)
              SizedBox(
                width: double.infinity,
                child: PixelButton(text: "💾 SAVE THIS RECIPE", color: Colors.green, onPressed: _addToMixtail),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
