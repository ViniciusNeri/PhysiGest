import 'package:equatable/equatable.dart';

class PaymentMethod extends Equatable {
  final String id;
  final String name;
  final bool isActive;
  final String userId;

  const PaymentMethod({
    required this.id,
    required this.name,
    this.isActive = true,
    required this.userId,
  });

  PaymentMethod copyWith({String? id, String? name, bool? isActive, String? userId}) {
    return PaymentMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [id, name, isActive, userId];
}
