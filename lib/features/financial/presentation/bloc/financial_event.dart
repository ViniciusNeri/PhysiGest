import 'package:equatable/equatable.dart';

abstract class FinancialEvent extends Equatable {
  const FinancialEvent();

  @override
  List<Object?> get props => [];
}

class LoadFinancialData extends FinancialEvent {
  const LoadFinancialData();
}

class AddTransaction extends FinancialEvent {
  final Map<String, dynamic> transaction;
  const AddTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransaction extends FinancialEvent {
  final String id;
  final String source;
  const DeleteTransaction(this.id, this.source);

  @override
  List<Object?> get props => [id, source];
}

class UpdateDateFilter extends FinancialEvent {
  final int month;
  final int year;
  const UpdateDateFilter(this.month, this.year);

  @override
  List<Object?> get props => [month, year];
}
