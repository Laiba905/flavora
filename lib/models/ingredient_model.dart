class IngredientModel{
  final String id;
  final String name;
  final double baseQuantity; // quantity according to 1 serving
  final String unit; // grams, tbbsp, cups

  IngredientModel({
    required this.id,
    required this.name,
    required this.baseQuantity,
    required this.unit,
  });

  // dynamic portion scaling helper function
  double getScaledQuantity(int servings){
    return baseQuantity*servings;
  }

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      baseQuantity: (json['base_amount'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'name': name,
      'base_amount': baseQuantity,
      'unit': unit,
    };
  }

}











