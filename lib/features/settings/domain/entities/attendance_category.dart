import 'package:equatable/equatable.dart';

class AttendanceCategory extends Equatable {
  final String id;
  final String name;
  final int duration; // em minutos
  final bool isActive;
  final String userId;

  const AttendanceCategory({
    required this.id,
    required this.name,
    this.duration = 60,
    this.isActive = true,
    required this.userId,
  });

  AttendanceCategory copyWith({
    String? id,
    String? name,
    int? duration,
    bool? isActive,
    String? userId,
  }) {
    return AttendanceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [id, name, duration, isActive, userId];
}
