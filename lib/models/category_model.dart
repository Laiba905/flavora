class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;

  CategoryModel({required this.id, required this.name, required this.imageUrl});

  // to create dart obj from supabase (postgre sql)
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Uncategorized',
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }


  // to convert dart obj to json format
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'image_url': imageUrl};
  }

}
