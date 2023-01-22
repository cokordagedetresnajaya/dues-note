import 'package:flutter/material.dart';
import '../models/organization_category.dart';

class OrganizationCategories with ChangeNotifier {
  final List<OrganizationCategory> _items = [
    OrganizationCategory(
      id: 'c1',
      name: 'Sports',
      color: const Color.fromRGBO(254, 192, 48, 1),
      image: 'assets/images/basketball.png',
    ),
    OrganizationCategory(
      id: 'c2',
      name: 'Art & Creativity',
      color: const Color.fromRGBO(207, 55, 39, 1),
      image: 'assets/images/art.png',
    ),
    OrganizationCategory(
      id: 'c3',
      name: 'Education',
      color: const Color.fromRGBO(39, 136, 207, 1),
      image: 'assets/images/book.png',
    ),
    OrganizationCategory(
      id: 'c4',
      name: 'Information Technology',
      color: const Color.fromRGBO(123, 39, 207, 1),
      image: 'assets/images/monitor.png',
    ),
    OrganizationCategory(
      id: 'c5',
      name: 'Other',
      color: const Color.fromRGBO(39, 207, 147, 1),
      image: 'assets/images/ellipsis.png',
    ),
  ];

  List<OrganizationCategory> get items {
    return [..._items];
  }

  OrganizationCategory findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }
}
