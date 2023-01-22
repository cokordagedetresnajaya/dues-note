class Member {
  final String id;
  final String organizationFeeId;
  final String name;
  double organizationFeeAmount;
  bool isPaid;
  String transactionId = '';
  DateTime? payDate;

  Member(
    this.id,
    this.organizationFeeId,
    this.name,
    this.organizationFeeAmount,
    this.isPaid,
  );
}
