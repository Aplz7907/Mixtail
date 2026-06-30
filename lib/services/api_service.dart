import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

class ApiService {
  static const String _baseUrl = 'https://www.thecocktaildb.com/api/json/v1/1';

  // ค้นหาด้วยชื่อวัตถุดิบ (เช่น Gin, Vodka)
  Future<List<Recipe>> searchByIngredient(String ingredient) async {
    final response = await http.get(Uri.parse('$_baseUrl/filter.php?i=$ingredient'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['drinks'] != null) {
        // API filter ให้มาแค่ชื่อกับรูป ต้องวนลูปดึง Detail หรือใช้ข้อมูลเบื้องต้นไปก่อน
        // ในที่นี้จะดึงแบบย่อเพื่อความเร็ว แล้วค่อยไปดึง Detail หน้าถัดไป
        return (data['drinks'] as List)
            .map((json) => Recipe(
                  id: json['idDrink'],
                  name: json['strDrink'],
                  instructions: "Tap to see details...", // API filter ไม่ให้วิธีทำมา
                  imageUrl: json['strDrinkThumb'],
                ))
            .toList();
      }
    }
    return [];
  }

  // ดึงรายละเอียดสูตร (เพื่อเอาวิธีทำ)
  Future<Recipe?> getRecipeDetail(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/lookup.php?i=$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['drinks'] != null) {
        return Recipe.fromJson(data['drinks'][0]);
      }
    }
    return null;
  }
}
