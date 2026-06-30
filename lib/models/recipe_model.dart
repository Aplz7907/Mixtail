class Recipe {
  final String id;
  final String name;
  final String instructions;
  final String imageUrl;
  final String ingredients;
  final bool isCustom;
  final String? sourceMood; // ✅ เพิ่ม: เก็บชื่ออารมณ์ (Nullable เผื่อเป็นสูตรที่เพิ่มเอง)

  Recipe({
    required this.id,
    required this.name,
    required this.instructions,
    required this.imageUrl,
    this.ingredients = "",
    this.isCustom = false,
    this.sourceMood, // ✅ เพิ่มตรงนี้
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['idDrink'] ?? json['id'] ?? '',
      name: json['strDrink'] ?? json['name'] ?? 'Unknown',
      instructions: json['strInstructions'] ?? json['instructions'] ?? "No instructions",
      imageUrl: json['strDrinkThumb'] ?? json['imageUrl'] ?? '',
      ingredients: json['ingredients'] ?? '',
      isCustom: json['isCustom'] == true || json['isCustom'] == 1,
      sourceMood: json['sourceMood'], // ✅ เพิ่ม: รับค่าอารมณ์จาก JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'isCustom': isCustom,
      'sourceMood': sourceMood, // ✅ เพิ่ม: บันทึกอารมณ์ลง JSON
    };
  }
}
