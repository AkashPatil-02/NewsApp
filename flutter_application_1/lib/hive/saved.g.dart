// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedAdapter extends TypeAdapter<Saved> {
  @override
  final int typeId = 1;

  @override
  Saved read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Saved(
      saved_news: (fields[0] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, Saved obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.saved_news);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
