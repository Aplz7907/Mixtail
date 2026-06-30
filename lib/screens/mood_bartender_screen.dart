import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/recipe_model.dart';
import '../widgets/pixel_button.dart'; // อย่าลืม import ปุ่มของคุณ

class MoodBartenderScreen extends StatefulWidget {
  const MoodBartenderScreen({super.key});

  @override
  State<MoodBartenderScreen> createState() => _MoodBartenderScreenState();
}

class _MoodBartenderScreenState extends State<MoodBartenderScreen> {
  final ApiService _apiService = ApiService();
  String _result = "";
  Recipe? _selectedRecipe;
  bool _isLoading = false;
  String? _currentMood; // ✅ ตัวแปรจำว่าเลือกอารมณ์อะไรอยู่

  final Map<String, String> _moodQuotes = {
    'PARTY 🔥': "Tonight we are young! Bottoms up! 🍻",
    'SAD 💔': "It's just a bad day, not a bad life. Sip slowly. 🥃",
    'CHILL 🏖️': "Relax. Nothing is under control. Just vibe. 🌊",
    'LOVE 💖': "You taste like magic. Cheers to romance! 🥂",
  };

  final Map<String, List<String>> _moodIngredients = {
    'PARTY 🔥': ['Tequila', 'Sambuca', 'Vodka', 'Amaretto'],
    'SAD 💔': ['Bourbon', 'Scotch', 'Cognac', 'Brandy'],
    'CHILL 🏖️': ['Rum', 'Gin', 'Lime', 'Mint'],
    'LOVE 💖': ['Champagne', 'Strawberry', 'Grenadine', 'Baileys'],
  };

  // 💾 ฟังก์ชันบันทึก
  Future<void> _addToMixtail() async {
    if (_selectedRecipe == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedList = prefs.getStringList('my_mixtail') ?? [];

      // เช็คว่ามีอยู่แล้วไหม
      bool alreadySaved = savedList.any((item) {
        final Map<String, dynamic> data = jsonDecode(item);
        return data['id'] == _selectedRecipe!.id;
      });

      if (alreadySaved) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You already saved this drink! 🍷')),
          );
        }
        return;
      }

      // ✅ สร้าง Recipe ใหม่ที่ยัด sourceMood เข้าไปด้วย
      Recipe recipeToSave = Recipe(
        id: _selectedRecipe!.id,
        name: _selectedRecipe!.name,
        instructions: _selectedRecipe!.instructions,
        imageUrl: _selectedRecipe!.imageUrl,
        ingredients: _selectedRecipe!.ingredients,
        isCustom: false,
        sourceMood: _currentMood, // <--- บันทึกอารมณ์ตรงนี้
      );

      savedList.add(jsonEncode(recipeToSave.toJson()));
      await prefs.setStringList('my_mixtail', savedList);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved with vibe: $_currentMood 💾'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error saving: $e");
    }
  }

  void _selectMood(String mood) async {
    setState(() {
      _isLoading = true;
      _result = "";
      _selectedRecipe = null;
      _currentMood = mood; // ✅ จำค่าอารมณ์ไว้
    });

    try {
      final ingredients = _moodIngredients[mood]!;
      final randomIngredient = ingredients[Random().nextInt(ingredients.length)];
      final recipes = await _apiService.searchByIngredient(randomIngredient);

      if (recipes.isNotEmpty) {
        // ... (Logic กรองคำเหมือนเดิม) ...
        List<Recipe> filteredList = [];
        if (mood == 'PARTY 🔥') {
          filteredList = recipes.where((r) => r.name.contains("Shot") || r.name.contains("Bomb") || r.name.contains("Long")).toList();
        } else if (mood == 'LOVE 💖') {
          filteredList = recipes.where((r) => r.name.contains("Kiss") || r.name.contains("Pink") || r.name.contains("Lady")).toList();
        }
        if (filteredList.isEmpty) filteredList = recipes;

        final randomRecipe = filteredList[Random().nextInt(filteredList.length)];
        final fullDetails = await _apiService.getRecipeDetail(randomRecipe.id);
        final finalRecipe = fullDetails ?? randomRecipe;

        if (mounted) {
          setState(() {
            _selectedRecipe = finalRecipe;
            _result = '''
🍸 **${finalRecipe.name.toUpperCase()}**

💬 **Vibe:**
"${_moodQuotes[mood]}"

🧊 **Base:** $randomIngredient

📝 **Instructions:**
${finalRecipe.instructions}
''';
          });
        }
      } else {
        setState(() => _result = "Oops! No drinks found. Try again!");
      }
    } catch (e) {
      setState(() => _result = "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        title: const Text('REAL MOOD BAR 🎭', style: TextStyle(fontFamily: 'PixelFont')),
        backgroundColor: Colors.indigoAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ... (Header Icon ส่วนเดิม) ...
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white24)),
              child: const Column(children: [
                Icon(Icons.psychology, size: 50, color: Colors.indigoAccent),
                SizedBox(height: 10),
                Text("AI WILL SCAN YOUR VIBE...", style: TextStyle(color: Colors.white, fontFamily: 'PixelFont'))
              ]),
            ),
            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.5,
              children: [
                _buildMoodButton('PARTY 🔥', Colors.orangeAccent),
                _buildMoodButton('SAD 💔', Colors.blueGrey),
                _buildMoodButton('CHILL 🏖️', Colors.tealAccent),
                _buildMoodButton('LOVE 💖', Colors.pinkAccent),
              ],
            ),

            const SizedBox(height: 30),

            if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.indigoAccent)),

            if (_selectedRecipe != null && !_isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    border: Border.all(color: _getBorderColor(), width: 4),
                    color: Colors.black,
                    boxShadow: [BoxShadow(color: _getBorderColor().withOpacity(0.5), blurRadius: 10, spreadRadius: 1)]),
                child: Column(
                  children: [
                    Image.network(_selectedRecipe!.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50, color: Colors.white)),
                    const SizedBox(height: 20),
                    Text(_result, style: const TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 14, height: 1.5)),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white54),
                    const SizedBox(height: 10),

                    // ปุ่ม Save
                    PixelButton(
                      text: "💾 SAVE TO MIXTAIL",
                      color: Colors.green,
                      onPressed: _addToMixtail,
                    ),
                  ],
                ),
              ),

            if (_result.startsWith("Error") || _result.startsWith("Oops"))
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(_result, style: const TextStyle(color: Colors.red, fontFamily: 'PixelFont'), textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (_result.contains("PARTY")) return Colors.orange;
    if (_result.contains("SAD")) return Colors.blueGrey;
    if (_result.contains("CHILL")) return Colors.teal;
    if (_result.contains("LOVE")) return Colors.pink;
    return Colors.white;
  }

  Widget _buildMoodButton(String mood, Color color) {
    return PixelButton(
      text: mood,
      color: _isLoading ? Colors.grey : color,
      onPressed: _isLoading ? () {} : () => _selectMood(mood),
    );
  }
}
