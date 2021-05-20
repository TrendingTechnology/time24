// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeStampHistory _$TimeStampHistoryFromJson(Map<String, dynamic> json) {
  return TimeStampHistory(
    DateTime.parse(json['timestamp'] as String),
    yearHistory: (json['yearHistory'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(
          int.parse(k), AnnualHistory.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$TimeStampHistoryToJson(TimeStampHistory instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'yearHistory':
          instance.yearHistory.map((k, e) => MapEntry(k.toString(), e)),
    };

AnnualHistory _$AnnualHistoryFromJson(Map<String, dynamic> json) {
  return AnnualHistory(
    json['year'] as int,
    weekHistory: (json['weekHistory'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(
          int.parse(k), WeekHistory.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$AnnualHistoryToJson(AnnualHistory instance) =>
    <String, dynamic>{
      'year': instance.year,
      'weekHistory':
          instance.weekHistory.map((k, e) => MapEntry(k.toString(), e)),
    };

WeekHistory _$WeekHistoryFromJson(Map<String, dynamic> json) {
  return WeekHistory(
    json['week'] as int,
    dailyHistory: (json['dailyHistory'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(
          int.parse(k), DailyTimeStamp.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$WeekHistoryToJson(WeekHistory instance) =>
    <String, dynamic>{
      'week': instance.week,
      'dailyHistory':
          instance.dailyHistory.map((k, e) => MapEntry(k.toString(), e)),
    };

DailyTimeStamp _$DailyTimeStampFromJson(Map<String, dynamic> json) {
  return DailyTimeStamp(
    DateTime.parse(json['currentDay'] as String),
    json['notes'] as String,
    TimeStamp.fromJson(json['workTime'] as Map<String, dynamic>),
    breakTime: (json['breakTime'] as List<dynamic>?)
        ?.map((e) => TimeStamp.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$DailyTimeStampToJson(DailyTimeStamp instance) =>
    <String, dynamic>{
      'currentDay': instance.currentDay.toIso8601String(),
      'notes': instance.notes,
      'workTime': instance.workTime,
      'breakTime': instance.breakTime,
    };

TimeStamp _$TimeStampFromJson(Map<String, dynamic> json) {
  return TimeStamp(
    json['begin'] == null ? null : DateTime.parse(json['begin'] as String),
    json['end'] == null ? null : DateTime.parse(json['end'] as String),
  );
}

Map<String, dynamic> _$TimeStampToJson(TimeStamp instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('begin', instance.begin?.toIso8601String());
  writeNotNull('end', instance.end?.toIso8601String());
  return val;
}
