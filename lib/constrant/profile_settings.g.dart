// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileSettings _$ProfileSettingsFromJson(Map<String, dynamic> json) {
  return ProfileSettings(
    json['required-hours-per-week'] as num? ?? 0,
    json['currency'] as String? ?? 'EUR',
    json['loan-per-hour'] as num? ?? 0,
    json['receives-paid-overtime'] as bool? ?? false,
  );
}

Map<String, dynamic> _$ProfileSettingsToJson(ProfileSettings instance) =>
    <String, dynamic>{
      'required-hours-per-week': instance.requiredHoursPerWeek,
      'currency': instance.currency,
      'loan-per-hour': instance.loanPerHour,
      'receives-paid-overtime': instance.receivesPaidOvertime,
    };
