import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';
import 'detail_screen.dart';
import 'add_cocktail_screen.dart';

class MyMixtailScreen extends StatefulWidget {
  const MyMixtailScreen({super.key});

  @override
  State<MyMixtailScreen> createState() => _MyMixtailScreenState();
}

class _MyMixtailScreenState extends State<MyMixtailScreen> {
  List<Recipe> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavorites();
  }

  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList('my_mixtail') ?? [];

    if (mounted) {
      setState(() {
        _favorites = savedList.map((item) {
          return Recipe.fromJson(jsonDecode(item));
        }).toList();
      });
    }
  }

  void _deleteItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList('my_mixtail') ?? [];

    savedList.removeWhere((item) {
      final Map<String, dynamic> data = jsonDecode(item);
      String itemId = data['id'] ?? data['idDrink'] ?? '';
      return itemId == id;
    });

    await prefs.setStringList('my_mixtail', savedList);
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        title: const Text('MY MIXTAIL 📖', style: TextStyle(fontFamily: 'PixelFont')),
        backgroundColor: Colors.orange,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCocktailScreen()));
          _loadFavorites();
        },
        backgroundColor: Colors.orange,
        shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.menu_book, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("NO RECIPES YET...", style: TextStyle(fontFamily: 'PixelFont', color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final recipe = _favorites[index];

                ImageProvider imageProvider;
                if (recipe.imageUrl.startsWith('http')) {
                  imageProvider = NetworkImage(recipe.imageUrl);
                } else if (recipe.imageUrl.isNotEmpty) {
                  imageProvider = FileImage(File(recipe.imageUrl));
                } else {
                  imageProvider = const AssetImage('assets/images/placeholder.png');
                }

                return Dismissible(
                  key: Key(recipe.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (direction) {
                    _deleteItem(recipe.id);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted "${recipe.name}"')));
                  },
                  child: Card(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.orange, width: 2), borderRadius: BorderRadius.circular(0)),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.orange, width: 2),
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover, onError: (_, __) => const Icon(Icons.broken_image, color: Colors.orange))),
                      ),
                      title: Text(recipe.name, style: const TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 14)),

                      // ✅✅✅ แก้ไขตรงนี้ครับ ✅✅✅
                      subtitle: recipe.isCustom
                          ? const Text(
                              "CUSTOM RECIPE ✨", // สูตรทำเอง
                              style: TextStyle(color: Colors.greenAccent, fontFamily: 'PixelFont', fontSize: 10),
                            )
                          : (recipe.sourceMood != null && recipe.sourceMood!.isNotEmpty)
                              ? Row(
                                  // ถ้ามี Mood (มาจาก Mood Bartender) ให้โชว์ Vibe
                                  children: [
                                    const Text("VIBE: ", style: TextStyle(color: Colors.grey, fontFamily: 'PixelFont', fontSize: 10)),
                                    Text(
                                      recipe.sourceMood!,
                                      style: TextStyle(
                                        color: _getMoodColor(recipe.sourceMood),
                                        fontFamily: 'PixelFont',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  // ถ้าไม่มี Mood (มาจาก Search/Home) ให้โชว์คำนี้แทน
                                  "CLASSIC COCKTAIL 🍸",
                                  style: TextStyle(color: Colors.grey, fontFamily: 'PixelFont', fontSize: 10),
                                ),

                      onTap: () {
                        // ปิดปุ่ม Save เพราะอยู่ใน My Mixtail แล้ว
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              recipe: recipe,
                              allowSave: false,
                            ),
                          ),
                        );
                      },
                      trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _deleteItem(recipe.id)),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getMoodColor(String? mood) {
    if (mood == null) return Colors.grey;
    if (mood.contains("PARTY")) return Colors.orangeAccent;
    if (mood.contains("SAD")) return Colors.blueGrey;
    if (mood.contains("CHILL")) return Colors.tealAccent;
    if (mood.contains("LOVE")) return Colors.pinkAccent;
    return Colors.white;
  }
}
