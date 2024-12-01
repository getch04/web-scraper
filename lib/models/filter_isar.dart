import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'filter_isar.g.dart';

@collection
@JsonSerializable()
class FilterIsar {
  Id? id;
  @Index(unique: true)
  final String name;
  final String hakuValue;
  bool isActive;
  final DateTime? createdAt;

  // Constructor for easier creation
  FilterIsar({
    this.id,
    required this.name,
    required this.hakuValue,
    this.isActive = false,
    this.createdAt,
  });

  factory FilterIsar.fromJson(Map<String, dynamic> json) =>
      _$FilterIsarFromJson(json);

  Map<String, dynamic> toJson() => _$FilterIsarToJson(this);

  //copywith
  FilterIsar copyWith({
    bool? isActive,
    DateTime? createdAt,
    String? name,
    String? hakuValue,
    Id? id,
  }) =>
      FilterIsar(
        name: name ?? this.name,
        hakuValue: hakuValue ?? this.hakuValue,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        id: id ?? this.id,
      );
}
