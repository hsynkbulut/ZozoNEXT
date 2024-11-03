import 'package:json_annotation/json_annotation.dart';

part 'activity_model.g.dart';

@JsonSerializable()
class ActivityModel {
  final String id;
  final String userId;
  final String title;
  final String type;
  final DateTime timestamp;
  final String? route;

  const ActivityModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.timestamp,
    this.route,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityModelToJson(this);
}
