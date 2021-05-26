import 'package:json_annotation/json_annotation.dart';

part 'time_history.g.dart';

@JsonSerializable()
class TimeStampHistory {
  Map<int, AnnualHistory> yearHistory;

  TimeStampHistory({
    Map<int, AnnualHistory>? yearHistory,
  }) : yearHistory = yearHistory ?? <int, AnnualHistory>{};

  factory TimeStampHistory.fromJson(Map<String, dynamic> json) =>
      _$TimeStampHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$TimeStampHistoryToJson(this);
}

@JsonSerializable()
class AnnualHistory {
  int year;
  Map<int, WeekHistory> weekHistory;

  AnnualHistory(
    this.year, {
    Map<int, WeekHistory>? weekHistory,
  }) : weekHistory = weekHistory ?? <int, WeekHistory>{};

  factory AnnualHistory.fromJson(Map<String, dynamic> json) =>
      _$AnnualHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$AnnualHistoryToJson(this);
}

@JsonSerializable()
class WeekHistory {
  int week;
  Map<int, DailyTimeStamp> dailyHistory;

  WeekHistory(
    this.week, {
    Map<int, DailyTimeStamp>? dailyHistory,
  }) : dailyHistory = dailyHistory ?? <int, DailyTimeStamp>{};

  factory WeekHistory.fromJson(Map<String, dynamic> json) =>
      _$WeekHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$WeekHistoryToJson(this);
}

@JsonSerializable()
class DailyTimeStamp {
  DateTime currentDay;
  String notes;
  TimeStamp workTime;
  List<TimeStamp> breakTime;

  DailyTimeStamp(
    this.currentDay,
    this.notes,
    this.workTime, {
    List<TimeStamp>? breakTime,
  }) : breakTime = breakTime ?? <TimeStamp>[];

  factory DailyTimeStamp.fromJson(Map<String, dynamic> json) =>
      _$DailyTimeStampFromJson(json);

  Map<String, dynamic> toJson() => _$DailyTimeStampToJson(this);
}

@JsonSerializable()
class TimeStamp {
  TimeStamp(this.begin, this.end);

  bool isNotEmpty() => begin != null || end != null;

  @JsonKey(includeIfNull: false)
  DateTime? begin;

  @JsonKey(includeIfNull: false)
  DateTime? end;

  factory TimeStamp.fromJson(Map<String, dynamic> json) =>
      _$TimeStampFromJson(json);

  Map<String, dynamic> toJson() => _$TimeStampToJson(this);
}
