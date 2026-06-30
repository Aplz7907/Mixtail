import 'package:flutter/material.dart';
import '../services/music_service.dart';
import '../services/api_service.dart';
import '../models/recipe_model.dart';
import 'detail_screen.dart';
import 'my_mixtail.dart';
import '../widgets/pixel_button.dart';
// 👇 1. เปลี่ยน Import ตรงนี้ให้เป็นชื่อไฟล์ใหม่ที่คุณเพิ่งสร้าง
import 'mood_bartender_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();

  // ระบบเพลง
  final MusicService _musicService = MusicService();
  bool _isMusicPlaying = false;

  List<Recipe> _recipes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isMusicPlaying = _musicService.isPlaying;
    _startAutoMusic();
  }

  void _startAutoMusic() async {
    await _musicService.startMusic();
    if (mounted) {
      setState(() {
        _isMusicPlaying = _musicService.isPlaying;
      });
    }
  }

  void _toggleMusic() async {
    bool playing = await _musicService.toggleMusic();
    if (mounted) {
      setState(() => _isMusicPlaying = playing);
    }
  }

  void _search() async {
    if (_controller.text.isEmpty) return;
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final recipes = await _apiService.searchByIngredient(_controller.text);
      setState(() => _recipes = recipes);

      if (recipes.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cocktails found. Try "Vodka" or "Gin".')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        title: const Text('MIXTAIL BAR', style: TextStyle(fontFamily: 'PixelFont')),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(_isMusicPlaying ? Icons.volume_up : Icons.volume_off),
            color: Colors.black,
            onPressed: _toggleMusic,
          ),
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyMixtailScreen())),
          )
        ],
      ),
      body: Column(
        children: [
          // ---------------------------------------------------
          // HEADER
          // ---------------------------------------------------
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/barmix.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
              border: const Border(
                bottom: BorderSide(color: Colors.orange, width: 4),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "WHAT WOULD YOU LIKE\nTO DRINK TONIGHT?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                    shadows: [
                      Shadow(offset: Offset(2, 2), color: Colors.black, blurRadius: 0),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Search Box
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [
                      BoxShadow(color: Colors.grey, offset: Offset(4, 4), blurRadius: 0),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(fontFamily: 'PixelFont', color: Colors.black, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'e.g. Gin, Vodka, Lemon',
                            hintStyle: TextStyle(color: Colors.grey, fontFamily: 'PixelFont', fontSize: 12),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _search(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---------------------------------------------------
          // BUTTONS ZONE
          // ---------------------------------------------------
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // ปุ่มค้นหาเดิม
                PixelButton(text: "FIND COCKTAILS", onPressed: _search),

                const SizedBox(height: 15),
                const Text("- OR -", style: TextStyle(color: Colors.grey, fontFamily: 'PixelFont')),
                const SizedBox(height: 15),

                // 👇 2. ปุ่มใหม่! เข้าหน้าเลือกอารมณ์
                PixelButton(
                    text: "MOOD BARTENDER 🎭",
                    color: Colors.purpleAccent, // สีม่วงให้เด่น
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodBartenderScreen()));
                    }),
              ],
            ),
          ),

          // ---------------------------------------------------
          // LIST VIEW
          // ---------------------------------------------------
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _recipes[index];
                      return Card(
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
                            ),
                            child: ClipOval(
                              child: Image.network(
                                recipe.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.orange),
                              ),
                            ),
                          ),
                          title: Text(
                            recipe.name,
                            style: const TextStyle(color: Colors.white, fontFamily: 'PixelFont', fontSize: 12),
                          ),
                          onTap: () async {
                            final fullRecipe = await _apiService.getRecipeDetail(recipe.id);
                            if (fullRecipe != null && mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => DetailScreen(recipe: fullRecipe)),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
