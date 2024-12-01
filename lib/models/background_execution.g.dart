// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_execution.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackgroundExecution _$BackgroundExecutionFromJson(Map<String, dynamic> json) =>
    BackgroundExecution(
      wasSuccessful: json['wasSuccessful'] as bool? ?? true,
      error: json['error'] as String?,
    )
      ..id = (json['id'] as num).toInt()
      ..timestamp = DateTime.parse(json['timestamp'] as String);

Map<String, dynamic> _$BackgroundExecutionToJson(
        BackgroundExecution instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'wasSuccessful': instance.wasSuccessful,
      'error': instance.error,
    };
