
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'background_execution.g.dart';

@JsonSerializable()
class BackgroundExecution {
  Id id = Isar.autoIncrement;
  DateTime timestamp = DateTime.now();
  bool wasSuccessful;
  String? error;

  BackgroundExecution({
    this.wasSuccessful = true,
    this.error,
  });

  factory BackgroundExecution.fromJson(Map<String, dynamic> json) =>
      _$BackgroundExecutionFromJson(json);

  Map<String, dynamic> toJson() => _$BackgroundExecutionToJson(this);
}
