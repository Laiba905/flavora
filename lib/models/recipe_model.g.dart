// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeModelAdapter extends TypeAdapter<RecipeModel> {
  @override
  final int typeId = 0;

  @override
  RecipeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      categoryId: fields[3] as String,
      imageUrl: fields[4] as String,
      cookingTimeMinutes: fields[5] as int,
      calories: fields[6] as double,
      proteinGrams: fields[7] as double,
      carbsGrams: fields[8] as double,
      fatsGrams: fields[9] as double,
      youtubeVideoUrl: fields[10] as String?,
      instructions: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.cookingTimeMinutes)
      ..writeByte(6)
      ..write(obj.calories)
      ..writeByte(7)
      ..write(obj.proteinGrams)
      ..writeByte(8)
      ..write(obj.carbsGrams)
      ..writeByte(9)
      ..write(obj.fatsGrams)
      ..writeByte(10)
      ..write(obj.youtubeVideoUrl)
      ..writeByte(11)
      ..write(obj.instructions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
