import 'package:hive/hive.dart';

part 'section_time_model.g.dart';

@HiveType(typeId: 2)
class SectionTimeModel {
  @HiveField(0)
  final String day;

  @HiveField(1)
  final String startTime;

  @HiveField(2)
  final String endTime;

  @HiveField(3)
  final String location;

  SectionTimeModel({
    required this.day,
    required this.startTime,
    required this.endTime,
    this.location = '',
  });

  factory SectionTimeModel.fromJson(Map<String, dynamic> json) {
    return SectionTimeModel(
      day: json['day'] ?? '',
      // Handle both API and UI formats
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      location: json['location'] ?? '',
    );
  }

  // For API and Hive storage
  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'location': location,
    };
  }

  // For UI display only
  Map<String, dynamic> toUiMap() {
    return {
      'day': day,
      'start': startTime,
      'end': endTime,
      'room': location,
    };
  }

  // For comparing and copying
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionTimeModel &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          location == other.location;

  @override
  int get hashCode =>
      day.hashCode ^ startTime.hashCode ^ endTime.hashCode ^ location.hashCode;

  @override
  String toString() {
    return 'SectionTime(day: $day, start_time: $startTime, end_time: $endTime, location: $location)';
  }
}
