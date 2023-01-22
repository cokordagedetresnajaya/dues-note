import 'package:dues_note/models/http_exception.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configs/core.dart';

import '../models/organization.dart';

class Organizations with ChangeNotifier {
  String? authToken;
  final String? userId;

  Organizations(this.authToken, this.userId, this._items);

  List<Organization> _items = [];

  List<Organization> get items {
    return [..._items];
  }

  void reset() {
    _items = [];
  }

  List<Organization> getItemsByUserId(String userId) {
    return _items.where((item) => item.userId == userId).toList();
  }

  Organization getOrganizationById(String organizationId) {
    return _items.firstWhere((element) => element.id == organizationId);
  }

  Future<void> fetchAndSetOrganization() async {
    final url = Uri.https(
      Core.firebaseBaseUrl,
      '/organizations.json',
      {
        'auth': '$authToken',
        'orderBy': '"userId"',
        'equalTo': '"$userId"',
      },
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (data == null) {
        return;
      }

      final List<Organization> loadedOrganization = [];
      Organization tempOrganization;

      data.forEach((key, value) {
        tempOrganization = Organization(
          id: key,
          name: value['name'],
          category: value['category'],
          userId: value['userId'],
        );
        tempOrganization.numberOfMembers = value['numberOfMembers'];
        loadedOrganization.add(tempOrganization);
      });
      _items = loadedOrganization;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> createOrganizations(Organization organization) async {
    final url = Uri.https(
      Core.firebaseBaseUrl,
      '/organizations.json',
      {
        'auth': '$authToken',
      },
    );

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'name': organization.name,
            'category': organization.category,
            'description': organization.description,
            'userId': userId,
            'numberOfMembers': 0,
          },
        ),
      );

      final newOrganization = Organization(
        id: json.decode(response.body)['name'],
        name: organization.name,
        category: organization.category,
        userId: userId!,
        description: organization.description,
      );

      newOrganization.numberOfMembers = 0;

      _items.add(newOrganization);
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> updateTotalOrganizationMember(
      String id, int numberOfmembers) async {
    final url = Uri.https(
      Core.firebaseBaseUrl,
      '/organizations/${id}.json',
      {
        'auth': '$authToken',
      },
    );

    try {
      final response = await http.patch(
        url,
        body: json.encode(
          {
            'numberOfMembers': numberOfmembers,
          },
        ),
      );

      if (response.statusCode >= 400) {
        throw HttpException('Update Organization Total Members Failed');
      } else {
        var memberIndex = _items.indexWhere((element) => element.id == id);
        _items[memberIndex].numberOfMembers = numberOfmembers;
        notifyListeners();
      }
    } catch (e) {}
  }
}
