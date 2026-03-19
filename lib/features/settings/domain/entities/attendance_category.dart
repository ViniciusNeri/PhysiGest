import 'package:equatable/equatable.dart';

class AttendanceCategory extends Equatable {
  final String id;
  final String name;
  final bool isActive;

  const AttendanceCategory({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  AttendanceCategory copyWith({
    String? id,
    String? name,
    bool? isActive,
  }) {
    return AttendanceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, isActive];
}
