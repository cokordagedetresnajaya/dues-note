import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import '../models/transaction.dart';
import '../models/http_exception.dart';
import '../configs/core.dart';

class Transactions with ChangeNotifier {
  String? authToken;

  Transactions(this.authToken, this._items);

  List<Transaction> _items = [];

  List<Transaction> get items {
    return [..._items];
  }

  Transaction getTransactionById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetTransaction(String organizationId) async {
    final url = Uri.https(
      Core.firebaseBaseUrl,
      '/transactions.json',
      {
        'auth': '$authToken',
        'orderBy': '"organizationId"',
        'equalTo': '"$organizationId"'
      },
    );

    try {
      final response = await http.get(url);
      final transactions = json.decode(response.body);

      if (transactions == null) {
        return;
      }

      final List<Transaction> loadedTransactions = [];

      transactions.forEach((id, transaction) {
        loadedTransactions.add(
          Transaction(
            id: id,
            title: transaction['title'],
            type: transaction['type'],
            amount: transaction['amount'].toInt(),
            date: new DateFormat('M/D/yyyy').parse(transaction['date']),
            paymentType: transaction['paymentType'],
            description: transaction['description'],
            organizationId: transaction['organizationId'],
            duesId: transaction['duesId'],
            memberId: transaction['memberId'],
            createdAt: DateTime.parse(transaction['createdAt']),
          ),
        );
      });
      _items = loadedTransactions;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  int getBalance() {
    var balance = 0;
    _items.forEach((transaction) {
      if (transaction.type == 'expenses') {
        balance -= transaction.amount;
      } else {
        balance += transaction.amount;
      }
    });
    return balance;
  }

  List<Map<String, dynamic>> get7MonthsBeforeCashflowDetail() {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> cashflows = [];

    var temp;
    var tempIncome;
    var tempExpenses;
    for (var i = 0; i < 7; i++) {
      tempIncome = 0;
      tempExpenses = 0;
      var subtractedDateTime = Jiffy(DateTime(now.year, now.month, now.day))
          .subtract(months: i)
          .dateTime;
      temp = _items.where((transaction) {
        return transaction.date.month == subtractedDateTime.month &&
            transaction.date.year == subtractedDateTime.year;
      });

      temp.forEach((element) {
        if (element.type == 'expenses') {
          tempExpenses += element.amount;
        } else {
          tempIncome += element.amount;
        }
      });
      cashflows.add({
        'income': tempIncome,
        'expenses': tempExpenses,
        'month': subtractedDateTime.month
      });
    }
    return cashflows;
  }

  List<Transaction> getLatestTransactions() {
    List<Transaction> latestTransactions = [];
    if (_items.length < 3) {
      latestTransactions = _items.reversed.toList();
      return latestTransactions;
    } else {
      for (var i = _items.length - 1; i > _items.length - 4; i--) {
        latestTransactions.add(_items[i]);
      }
      latestTransactions.sort((a, b) {
        return Comparable.compare(b.createdAt, a.createdAt);
      });
      return latestTransactions;
    }
  }

  Future<String> createTransaction(Transaction transaction) async {
    final url = Uri.https(
      Core.firebaseBaseUrl,
      '/transactions.json',
      {
        'auth': '$authToken',
      },
    );

    final createdAt = DateTime.now();

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': transaction.title,
            'type': transaction.type,
            'amount': transaction.amount,
            'date': DateFormat.yMd().format(transaction.date),
            'paymentType': transaction.paymentType,
            'description': transaction.description,
            'organizationId': transaction.organizationId,
            'duesId': transaction.duesId,
            'memberId': transaction.memberId,
            'createdAt': createdAt.toIso8601String(),
          },
        ),
      );

      print(createdAt);

      final newTransaction = Transaction(
        title: transaction.title,
        amount: transaction.amount,
        date: new DateFormat('M/D/yyyy')
            .parse(DateFormat.yMd().format(transaction.date)),
        description: transaction.description,
        type: transaction.type,
        paymentType: transaction.paymentType,
        organizationId: transaction.organizationId,
        duesId: transaction.duesId,
        memberId: transaction.memberId,
        id: json.decode(response.body)['name'],
        createdAt: createdAt,
      );
      _items.add(newTransaction);
      notifyListeners();
      return json.decode(response.body)['name'];
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final url = Uri.https(
      Core.firebaseBaseUrl,
      '/transactions/${transaction.id}.json',
      {
        'auth': '$authToken',
      },
    );

    try {
      final response = await http.patch(
        url,
        body: json.encode(
          {
            'title': transaction.title,
            'type': transaction.type,
            'amount': transaction.amount,
            'date': DateFormat.yMd().format(transaction.date),
            'paymentType': transaction.paymentType,
            'description': transaction.description,
            'organizationId': transaction.organizationId,
            'createdAt': transaction.createdAt.toIso8601String(),
          },
        ),
      );

      int itemIndex =
          _items.indexWhere((element) => element.id == transaction.id);

      _items[itemIndex] = transaction;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<Map<String, dynamic>> deleteTransactions(String id) async {
    var url = Uri.https(
      Core.firebaseBaseUrl,
      '/transactions/$id.json',
      {
        'auth': '$authToken',
      },
    );

    final index = _items.indexWhere((transaction) => transaction.id == id);

    Transaction? transaction = _items[index];
    _items.removeAt(index);
    notifyListeners();

    final response = await http.delete(url);

    Map<String, dynamic> responseData = {
      'memberId': transaction.memberId,
      'duesId': transaction.duesId,
      'isDuesType': transaction.type == 'dues' ? true : false,
      'isDelete': true,
    };

    if (response.statusCode >= 400) {
      _items.insert(index, transaction);
      notifyListeners();
      throw HttpException('Could not deleted transaction');
    }
    transaction = null;
    return responseData;
  }

  Future<void> generateExcel(DateTime _startDate, DateTime _endDate) async {
    final _transactions = _items
        .where((element) =>
            (element.date.isAtSameMomentAs(_startDate) ||
                element.date.isAfter(_startDate)) &&
            (element.date.isBefore(_endDate) ||
                element.date.isAtSameMomentAs(_endDate)))
        .toList();

    _transactions.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    final Workbook workbook = new Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    Style globalStyle = workbook.styles.add('style');
    globalStyle.hAlign = HAlignType.center;

    sheet.getRangeByName('A1').setText('Date');
    sheet.getRangeByName('A1').cellStyle = globalStyle;
    sheet.getRangeByName('B1').setText('Title');
    sheet.getRangeByName('B1').cellStyle = globalStyle;
    sheet.getRangeByName('C1').setText('Type');
    sheet.getRangeByName('C1').cellStyle = globalStyle;
    sheet.getRangeByName('D1').setText('Amount');
    sheet.getRangeByName('D1').cellStyle = globalStyle;
    sheet.getRangeByName('E1').setText('Payment Type');
    sheet.getRangeByName('E1').cellStyle = globalStyle;
    sheet.getRangeByName('F1').setText('Description');
    sheet.getRangeByName('F1').cellStyle = globalStyle;

    var type;
    var totalExpenses = 0;
    var totalIncome = 0;

    for (var i = 0; i < _transactions.length; i++) {
      type = _transactions[i].type;
      if (type == 'income' || type == 'dues') {
        type = 'Income';
        totalIncome += _transactions[i].amount;
      } else {
        type = 'Expenses';
        totalExpenses += _transactions[i].amount;
      }

      sheet.getRangeByName('A${i + 2}').setDateTime(_transactions[i].date);
      sheet.getRangeByName('B${i + 2}').setText(_transactions[i].title);
      sheet.getRangeByName('C${i + 2}').setText(type);
      sheet
          .getRangeByName('D${i + 2}')
          .setNumber(_transactions[i].amount.toDouble());
      sheet.getRangeByName('E${i + 2}').setText(_transactions[i].paymentType);
      sheet.getRangeByName('F${i + 2}').setText(_transactions[i].description);
    }

    sheet
        .getRangeByName('A${_transactions.length + 3}')
        .setText('Total Income');
    sheet
        .getRangeByName('B${_transactions.length + 3}')
        .setNumber(totalIncome.toDouble());
    sheet
        .getRangeByName('A${_transactions.length + 4}')
        .setText('Total Expenses');
    sheet
        .getRangeByName('B${_transactions.length + 4}')
        .setNumber(totalExpenses.toDouble());
    sheet.getRangeByName('A${_transactions.length + 5}').setText('Total');
    sheet
        .getRangeByName('B${_transactions.length + 5}')
        .setNumber((totalIncome - totalExpenses).toDouble());

    sheet.autoFitColumn(1);
    sheet.autoFitColumn(2);
    sheet.autoFitColumn(3);
    sheet.autoFitColumn(4);
    sheet.autoFitColumn(5);
    sheet.autoFitColumn(6);

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/output.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open(fileName);
  }
}
