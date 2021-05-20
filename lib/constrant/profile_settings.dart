import 'package:json_annotation/json_annotation.dart';

part 'profile_settings.g.dart';

@JsonSerializable()
class ProfileSettings {
  @JsonKey(name: "required-hours-per-week", defaultValue: 0)
  num requiredHoursPerWeek;

  @JsonKey(defaultValue: "EUR")
  String currency;

  @JsonKey(name: "loan-per-hour", defaultValue: 0)
  num loanPerHour;

  @JsonKey(name: "receives-paid-overtime", defaultValue: false)
  bool receivesPaidOvertime;

  ProfileSettings(
    this.requiredHoursPerWeek,
    this.currency,
    this.loanPerHour,
    this.receivesPaidOvertime,
  );

  factory ProfileSettings.fromJson(Map<String, dynamic> json) =>
      _$ProfileSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileSettingsToJson(this);
}
