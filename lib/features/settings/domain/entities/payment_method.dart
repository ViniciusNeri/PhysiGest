import 'package:equatable/equatable.dart';

class PaymentMethod extends Equatable {
  final String id;
  final String name;
  final bool isActive;

  const PaymentMethod({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  PaymentMethod copyWith({
    String? id,
    String? name,
    bool? isActive,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, isActive];
}
