// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metric_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetricDefinition _$MetricDefinitionFromJson(Map<String, dynamic> json) =>
    MetricDefinition(
      key: json['key'] as String,
      kind: $enumDecode(_$MetricKindEnumMap, json['kind']),
      unit: json['unit'] as String?,
      min: json['min'] as num?,
      max: json['max'] as num?,
      choices:
          (json['choices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MetricDefinitionToJson(MetricDefinition instance) =>
    <String, dynamic>{
      'key': instance.key,
      'kind': _$MetricKindEnumMap[instance.kind]!,
      'unit': ?instance.unit,
      'min': ?instance.min,
      'max': ?instance.max,
      'choices': ?MetricDefinition._choicesToJson(instance.choices),
    };

const _$MetricKindEnumMap = {
  MetricKind.number: 'number',
  MetricKind.scale: 'scale',
  MetricKind.choice: 'choice',
  MetricKind.boolean: 'boolean',
};
