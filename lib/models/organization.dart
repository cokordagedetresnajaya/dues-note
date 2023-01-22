class Organization {
  final String id;
  final String name;
  final String category;
  final String userId;
  final String? description;
  int numberOfMembers = 0;

  Organization({
    required this.id,
    required this.name,
    required this.category,
    required this.userId,
    this.description,
  });
}
