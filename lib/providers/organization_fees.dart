import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../configs/core.dart';
import '../models/organization_fee.dart';
import '../models/http_exception.dart';

class OrganizationFees with ChangeNotifier {
  String? authToken;

  OrganizationFees(
    this.authToken,
    this._items,
  );

  List<OrganizationFee> _items = [];

  List<OrganizationFee> get items {
    return [..._items];
  }

  Future<void> fetchAndSetOrganizationFees(String organizationId) async {
    var url = Uri.https(
      Core.firebaseBaseUrl,
      '/organization_fees.json',
      {
        'auth': '$authToken',
        'orderBy': '"organizationId"',
        'equalTo': '"$organizationId"'
      },
    );

    try {
      var response = await http.get(url);
      final data = json.decode(response.body);
      if (data == null) {
        return;
      }

      final List<OrganizationFee> loadedFees = [];

      data.forEach((id, element) async {
        loadedFees.add(
          OrganizationFee(
            id: id,
            title: element['title'],
            amount: element['amount'],
            startDate: new DateFormat('M/D/yyyy').parse(element['startDate']),
            endDate: new DateFormat('M/D/yyyy').parse(element['endDate']),
            isActive: element['isActive'],
            organizationId: element['organizationId'],
            numberOfPaidMembers: element['numberOfPaidMembers'],
            numberOfMembers: element['numberOfMembers'],
          ),
        );
      });

      _items = loadedFees;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  OrganizationFee getOrganizationFeeById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  OrganizationFee? getActiveOrganizationFee() {
    final organizationFeeIndex =
        _items.indexWhere((element) => element.isActive == true);
    if (organizationFeeIndex == -1) {
      print('not found active fee');
      _items.forEach((element) {
        print(element.title);
      });
      return null;
    } else {
      _items.forEach((element) {
        print(element.title);
      });
      return _items.elementAt(organizationFeeIndex);
    }
  }

  Future<String> createOrganizationFee(OrganizationFee organizationFee) async {
    final url = Uri.https(
      Core.firebaseBaseUrl,
      '/organization_fees.json',
      {
        'auth': '$authToken',
      },
    );

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': organizationFee.title,
            'amount': organizationFee.amount,
            'startDate': DateFormat.yMd().format(organizationFee.startDate),
            'endDate': DateFormat.yMd().format(organizationFee.endDate),
            'organizationId': organizationFee.organizationId,
            'isActive': organizationFee.isActive,
            'numberOfPaidMembers': organizationFee.numberOfPaidMembers,
            'numberOfMembers': organizationFee.numberOfMembers,
          },
        ),
      );

      var organizationFeeId = json.decode(response.body)['name'];

      var newOrganizationFee = OrganizationFee(
        title: organizationFee.title,
        amount: organizationFee.amount,
        isActive: organizationFee.isActive,
        startDate: DateFormat('M/D/yyyy').parse(
          DateFormat.yMd().format(
            organizationFee.startDate,
          ),
        ),
        endDate: DateFormat('M/D/yyyy').parse(
          DateFormat.yMd().format(
            organizationFee.endDate,
          ),
        ),
        organizationId: organizationFee.organizationId,
        id: json.decode(response.body)['name'],
        numberOfPaidMembers: organizationFee.numberOfPaidMembers,
        numberOfMembers: organizationFee.numberOfMembers,
      );

      _items.add(newOrganizationFee);
      notifyListeners();
      return organizationFeeId;
    } catch (error) {
      throw error;
    }
  }

  Future<void> deactivateCurrentActiveOrganizationFee() async {
    var activeOrganizationFeeIndex = _items.indexWhere(
      (element) => element.isActive == true,
    );
    var activeOrganizationFeeId = _items[activeOrganizationFeeIndex].id;

    final url = Uri.https(
      'dues-note-default-rtdb.firebaseio.com',
      '/organization_fees/$activeOrganizationFeeId.json',
      {
        'auth': '$authToken',
      },
    );

    try {
      await http.patch(
        url,
        body: json.encode(
          {
            'isActive': false,
          },
        ),
      );

      _items[activeOrganizationFeeIndex].isActive = false;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateOrganizationFeeStatus(String id, bool value) async {
    final url = Uri.https(
      Core.firebaseBaseUrl,
      '/organization_fees/$id.json',
      {
        'auth': '$authToken',
      },
    );

    try {
      await http.patch(
        url,
        body: json.encode(
          {
            'isActive': value,
          },
        ),
      );

      var organizationFeeIndex =
          _items.indexWhere((element) => element.id == id);
      _items[organizationFeeIndex].isActive = value;
      notifyListeners();
    } catch (e) {
      var organizationFeeIndex =
          _items.indexWhere((element) => element.id == id);
      _items[organizationFeeIndex].isActive = !value;
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateOrganizationFeePaidMember(String id, int count) async {
    final url = Uri.https(
      Core.firebaseBaseUrl,
      '/organization_fees/$id.json',
      {
        'auth': '$authToken',
      },
    );

    var organizationFeeIndex = _items.indexWhere((element) => element.id == id);

    try {
      await http.patch(
        url,
        body: json.encode(
          {
            'numberOfPaidMembers': count,
          },
        ),
      );

      _items[organizationFeeIndex].numberOfPaidMembers = count;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<String> deleteOrganizationFee(String id) async {
    final url = Uri.https(
      Core.firebaseBaseUrl,
      '/organization_fees/$id.json',
      {
        'auth': '$authToken',
      },
    );

    var existingOrganizationFeeIndex;
    OrganizationFee? existingOrganizationFee;

    existingOrganizationFeeIndex =
        _items.indexWhere((organizationFee) => organizationFee.id == id);
    existingOrganizationFee = _items[existingOrganizationFeeIndex];
    _items.removeAt(existingOrganizationFeeIndex);

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingOrganizationFeeIndex, existingOrganizationFee);
      notifyListeners();
      throw HttpException('Could not delete dues');
    }
    String organizationFeeId = existingOrganizationFee.id;
    existingOrganizationFee = null;
    return organizationFeeId;
  }

  Future<void> updateOrganizationFee(OrganizationFee organizationFee) async {
    final url = Uri.https(
      Core.firebaseBaseUrl,
      '/organization_fees/${organizationFee.id}.json',
      {
        'auth': '$authToken',
      },
    );

    try {
      final response = await http.patch(
        url,
        body: json.encode(
          {
            'title': organizationFee.title,
            'amount': organizationFee.amount,
            'startDate': DateFormat.yMd().format(organizationFee.startDate),
            'endDate': DateFormat.yMd().format(organizationFee.endDate),
            'numberOfPaidMembers': organizationFee.numberOfPaidMembers,
          },
        ),
      );

      int itemIndex =
          _items.indexWhere((element) => element.id == organizationFee.id);

      _items[itemIndex] = organizationFee;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateOrganizationFeeMember(
    String organizationFeeId,
    int numberOfMembers,
    int numberOfPaidMembers,
  ) async {
    final url = Uri.https(
      Core.firebaseBaseUrl,
      '/organization_fees/${organizationFeeId}.json',
      {
        'auth': '$authToken',
      },
    );

    try {
      final response = await http.patch(
        url,
        body: json.encode(
          {
            'numberOfMembers': numberOfMembers,
            'numberOfPaidMembers': numberOfPaidMembers,
          },
        ),
      );

      final index =
          _items.indexWhere((element) => element.id == organizationFeeId);
      _items[index].numberOfMembers = numberOfMembers;
      _items[index].numberOfPaidMembers = numberOfPaidMembers;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
