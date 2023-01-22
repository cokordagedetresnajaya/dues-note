import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/organization_fee.dart';
import '../models/member.dart';
import '../models/http_exception.dart';
import '../configs/core.dart';

class Members with ChangeNotifier {
  String? authToken;

  Members(this.authToken, this._items);

  List<Member> _items = [];

  List<Member> get items {
    return [..._items];
  }

  Future<void> fetchAndSetMembers(String organizationFeeId) async {
    final url = Uri.https(
      Core.firebaseBaseUrl,
      '/members/${organizationFeeId}.json',
      {
        'auth': '$authToken',
      },
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (data == null) {
        return;
      }

      final List<Member> loadedMembers = [];
      Member member;

      data.forEach((id, element) {
        member = Member(
          id,
          element['organizationFeeId'],
          element['name'],
          double.parse(
            element['organizationFeeAmount'].toString(),
          ),
          element['isPaid'],
        );

        if (element['transactionId'] != null) {
          member.transactionId = element['transactionId'];
        }
        loadedMembers.add(member);
      });
      _items = loadedMembers;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> createMembers(
    List<Map<String, dynamic>> members,
    String organizationFeeId,
  ) async {
    final url = Uri.https(
      Core.firebaseBaseUrl,
      '/members/${organizationFeeId}.json',
      {
        'auth': '$authToken',
      },
    );

    members.forEach((member) async {
      try {
        final response = await http.post(
          url,
          body: json.encode(
            {
              'organizationFeeId': organizationFeeId,
              'name': member['name'],
              'organizationFeeAmount': 0,
              'isPaid': false,
            },
          ),
        );

        final newMember = Member(
          json.decode(response.body)['name'],
          organizationFeeId,
          member['name'],
          0,
          false,
        );
        _items.add(newMember);
        notifyListeners();
      } catch (error) {
        throw error;
      }
    });
  }

  Future<void> cancelPayment(String organizationFeeId, String memberId) async {
    final url = Uri.https(
      Core.firebaseBaseUrl,
      '/members/${organizationFeeId}/${memberId}.json',
      {
        'auth': '$authToken',
      },
    );

    try {
      await http.patch(
        url,
        body: json.encode(
          {
            'organizationFeeAmount': 0,
            'transactionId': '',
          },
        ),
      );

      var index = _items.indexWhere((element) => element.id == memberId);
      if (index != -1) {
        _items[index].transactionId = '';
        _items[index].organizationFeeAmount = 0;
        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> payDues(
    String memberId,
    String organizationFeeId,
    int amount, [
    String transactionId = '',
  ]) async {
    var url = Uri.https(
      Core.firebaseBaseUrl,
      '/members/${organizationFeeId}/${memberId}.json',
      {
        'auth': '$authToken',
      },
    );

    try {
      final index = _items.indexWhere(
        (element) => element.id == memberId,
      );

      if (transactionId != '') {
        await http.patch(
          url,
          body: json.encode(
            {
              'organizationFeeAmount': amount,
              'transactionId': transactionId,
            },
          ),
        );

        _items[index].transactionId = transactionId;
      } else {
        await http.patch(
          url,
          body: json.encode(
            {
              'organizationFeeAmount': amount,
            },
          ),
        );
      }
      _items[index].organizationFeeAmount = amount.toDouble();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<List<String>> deleteOrganizationFeeMembers(
      String organizationFeeId) async {
    List<String> transactionId = [];
    var url = Uri.https(
      Core.firebaseBaseUrl,
      '/members/${organizationFeeId}.json',
      {
        'auth': '$authToken',
      },
    );

    var response = await http.delete(url);

    if (response.statusCode >= 400) {
      throw HttpException('Could not delete members');
    } else {
      _items.forEach((element) async {
        if (element.transactionId != null && element.transactionId != '') {
          transactionId.add(element.transactionId);
        }
      });
      _items = [];
      notifyListeners();
    }
    return transactionId;
  }

  int getCountPaidMembers(organizationFeeAmount) {
    final count = _items
        .where(
          (element) => element.organizationFeeAmount >= organizationFeeAmount,
        )
        .length;
    return count;
  }

  Future<void> updateMembers(
    List<Map<String, dynamic>> members,
    String organizationFeeId,
    List<Map<String, dynamic>> deletedMembers,
  ) async {
    var index;
    List<Map<String, dynamic>> newMembers = [];
    members.forEach((member) {
      index = _items.indexWhere((item) => item.id == member['id']);
      if (index == -1) {
        newMembers.add(member);
      }
    });

    // Add member
    try {
      await createMembers(newMembers, organizationFeeId);
    } catch (e) {
      throw e;
    }

    // Delete member
    try {
      await deleteMembers(deletedMembers, organizationFeeId);
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteMembers(
    List<Map<String, dynamic>> members,
    String organizationFeeId,
  ) async {
    var url;

    members.forEach((member) async {
      url = Uri.https(
        Core.firebaseBaseUrl,
        '/members/${organizationFeeId}/${member["id"]}.json',
        {
          'auth': '$authToken',
        },
      );

      final memberIndex = _items.indexWhere(
        (element) => element.id == member['id'],
      );

      final transactionId = _items[memberIndex].transactionId;
      final currentMember = _items[memberIndex];
      _items.removeAt(memberIndex);
      notifyListeners();

      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        _items.insert(memberIndex, currentMember);
        notifyListeners();
        throw HttpException('Could not delete member');
      }

      if (transactionId != '') {
        final transaction_url = Uri.https(
          Core.firebaseBaseUrl,
          '/transactions/${transactionId}.json',
          {
            'auth': '$authToken',
          },
        );
        final res = await http.delete(transaction_url);
      }
    });
  }
}
