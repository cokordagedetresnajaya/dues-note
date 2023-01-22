import 'dart:ffi';

class Transaction {
  final String id;
  final String title;
  final String type;
  final int amount;
  final DateTime date;
  final String paymentType;
  final String description;
  final String organizationId;
  String duesId = '';
  String memberId = '';
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.title,
    required this.type,
    required this.amount,
    required this.date,
    required this.paymentType,
    required this.description,
    required this.organizationId,
    this.duesId = '',
    this.memberId = '',
    required this.createdAt,
  });
}
