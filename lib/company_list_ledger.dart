import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:leager_app/account_ledger.dart';

class LedgerCompanyList extends StatefulWidget {
  // String userId;

  const LedgerCompanyList({
    super.key,

    //  required this.userId,
  });

  @override
  State<LedgerCompanyList> createState() => _LedgerCompanyListState();
}

class _LedgerCompanyListState extends State<LedgerCompanyList> {
  @override
  void initState() {
    super.initState();
    getCompanyList();
  }

  List<Map<String, dynamic>> _displayList = [];

  Future<void> getCompanyList() async {
    final url = Uri.parse(
        "http://103.204.185.17:24977/webapi/api/Common/GetCompanyFromTask?p_Taskid=STOCK_OPENING&p_userid=APPDBA");
    final response = await http.get(url);
    final jsonResponseList = json.decode(response.body);
    setState(
      () {
        _displayList = List.castFrom(jsonResponseList);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffd53233),
        leading: GestureDetector(
            onTap: Navigator.of(context).pop,
            child: const Icon(Icons.arrow_back_ios)),
        title: const Text("Companies"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: ListView.builder(
          itemCount: _displayList.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context, index) => InkWell(
            onTap: () {
              // selectedCompanyCode().code =
              //     _displayList[index]["Code"].toString();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AccountLedger(
                    code: _displayList[index]["Code"].toString(),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                child: ListTile(
                  title: Text(
                    _displayList[index]["name"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
