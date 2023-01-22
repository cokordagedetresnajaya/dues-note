class OrganizationFee {
  final String id;
  final String title;
  bool isActive;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final String organizationId;
  int numberOfPaidMembers;
  int numberOfMembers;

  OrganizationFee({
    required this.id,
    required this.title,
    required this.isActive,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.organizationId,
    this.numberOfPaidMembers = 0,
    this.numberOfMembers = 0,
  });
}
