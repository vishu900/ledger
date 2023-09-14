import 'package:animated_button/animated_button.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AccountLedger extends StatefulWidget {
  var code;
  AccountLedger({super.key, required this.code});

  @override
  State<AccountLedger> createState() => _AccountLedgerState();
}

class _AccountLedgerState extends State<AccountLedger> {
  var accCode;

  bool sortAscending = true;

  void toggleSortOrder() {
    setState(() {
      sortAscending = !sortAscending;

      accLADetails.sort((a, b) {
        if (sortAscending) {
          return DateTime.parse(a["DOC_DATE"])
              .compareTo(DateTime.parse(b["DOC_DATE"]));
        } else {
          return DateTime.parse(b["DOC_DATE"])
              .compareTo(DateTime.parse(a["DOC_DATE"]));
        }
      });
    });
  }

  // Last month Function

  void getLastMonthDates() {
    final now = DateTime.now();
    final lastMonthEnd = DateTime(now.year, now.month, 0);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);

    fromDateController.text = DateFormat('dd.MM.yyyy').format(lastMonthStart);
    toDateController.text = DateFormat('dd.MM.yyyy').format(lastMonthEnd);
  }

  // Last 3 months Function

  void getLastThreeMonthsDates() {
    final now = DateTime.now();
    final lastThreeMonthsEnd = DateTime(now.year, now.month, 0);
    final lastThreeMonthsStart = DateTime(now.year, now.month - 3, 1);

    fromDateController.text =
        DateFormat('dd.MM.yyyy').format(lastThreeMonthsStart);
    toDateController.text = DateFormat('dd.MM.yyyy').format(lastThreeMonthsEnd);
  }

  // Last 6 months Function

  void getLastSixMonthsDates() {
    final now = DateTime.now();
    final lastSixMonthsEnd = DateTime(now.year, now.month, 0);
    final lastSixMonthsStart = DateTime(now.year, now.month - 6, 1);

    fromDateController.text =
        DateFormat('dd.MM.yyyy').format(lastSixMonthsStart);
    toDateController.text = DateFormat('dd.MM.yyyy').format(lastSixMonthsEnd);
  }

  // Last 1 Years Function

  void getLastYearDates() {
    final now = DateTime.now();
    final lastYearEnd = DateTime(now.year, now.month, 0);
    final lastYearStart = DateTime(now.year - 1, now.month, 1);

    fromDateController.text = DateFormat('dd.MM.yyyy').format(lastYearStart);
    toDateController.text = DateFormat('dd.MM.yyyy').format(lastYearEnd);
  }

  List<String> radioOptions = [
    'Custom Date',
    'Last Month',
    'Last 6 Months',
    'Last 3 Months',
    'Last 1 Years'
  ];
  String selectedOption = '';
  bool showDateFields = false;
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  TextEditingController docTypeController = TextEditingController();

  List<Map<String, dynamic>> accLA = [];

  List<Map<String, dynamic>> accLAName = [];
  Map<String, dynamic>? itemSelectedLA;

  void showAllData() {
    if (selectedOption == 'Custom Date') {
      getOpeningBalanceList();
      getClosingBalanceList();
      getAccLADetailsList();
    }
  }

  @override
  void initState() {
    super.initState();
    getAccLAList();
    getFinYearDate();
    showAllData();
    selectedOption = "Custom Date";
    // getLastMonthDates();
  }

  Future<void> getAccLAList() async {
    final url = Uri.parse(
        "http://103.204.185.17:24978/webapi/api/Common/LedgerAccMaster");
    final response = await http.get(url);
    final jsonResponseList = json.decode(response.body);
    setState(
      () {
        accLA = List.castFrom(jsonResponseList);

        accLAName.clear();

        for (final accledger in accLA) {
          accLAName.add(accledger);
        }
        if (accLAName.isNotEmpty) {
          itemSelectedLA = accLAName[0];
          accCode = accLAName[0]['ACC_CODE'];
        }
      },
    );
  }

// Opening Balance

  List<Map<String, dynamic>> openingBalance = [];

  Future<void> getOpeningBalanceList() async {
    final url = Uri.parse(
        "http://103.204.185.17:24978/webapi/api/Common/LedgerOpeningBalance?comp_code=" +
            widget.code +
            "&acc_code=" +
            accCode.toString() +
            "&from_date=" +
            fromDateController.text);
    final response = await http.get(url);
    final jsonResponseList = json.decode(response.body);
    setState(
      () {
        openingBalance = List.castFrom(jsonResponseList);
      },
    );
  }

//  Closing Balance

  List<Map<String, dynamic>> closingBalance = [];

  Future<void> getClosingBalanceList() async {
    final url = Uri.parse(
        "http://103.204.185.17:24978/webapi/api/Common/LedgerClosingBalance?comp_code=" +
            widget.code +
            "&acc_code=" +
            accCode.toString() +
            "&to_date=" +
            toDateController.text);
    final response = await http.get(url);
    final jsonResponseList = json.decode(response.body);
    setState(
      () {
        closingBalance = List.castFrom(jsonResponseList);
      },
    );
  }

  List<Map<String, dynamic>> accLADetails = [];

  Future<void> getAccLADetailsList() async {
    final url = Uri.parse(
        "http://103.204.185.17:24978/webapi/api/Common/GetLedger?COMP_CODE=" +
            widget.code +
            "&ACC_CODE=" +
            accCode.toString() +
            "&START_DATE=" +
            fromDateController.text +
            "&END_DATE=" +
            toDateController.text +
            "&DOC_TYPE=" +
            docTypeController.text);
    final response = await http.get(url);
    final jsonResponseList = json.decode(response.body);

    final sortedList =
        List.castFrom(jsonResponseList).cast<Map<String, dynamic>>().toList();

    sortedList.sort((a, b) =>
        DateTime.parse(b["DOC_DATE"]).compareTo(DateTime.parse(a["DOC_DATE"])));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        accLADetails = sortedList;
      });
    });
  }

  void updateAccountAddress(Map<String, dynamic> selectedAccount) {
    setState(() {
      String address = '';
      if (selectedAccount.containsKey('ADD0')) {
        address += selectedAccount['ADD0'].toString();
      }
      if (selectedAccount.containsKey('ADD1')) {
        address += selectedAccount['ADD1'].toString();
      }
      if (selectedAccount.containsKey('ADD2')) {
        address += selectedAccount['ADD2'].toString();
      }

      accLA[0]['ADD0'] = address;
      accLA[0]['ADD1'] = '';
      accLA[0]['ADD2'] = '';
    });
  }

  List<Map<String, dynamic>> finyeara = [];

  Future<void> getFinYearDate() async {
    int currentYear = DateTime.now().year;
    int nextYear = currentYear + 1;
    String financialYear;

    if (DateTime.now().month >= 4) {
      financialYear = currentYear.toString() + nextYear.toString().substring(0);
    } else {
      financialYear =
          (currentYear - 1).toString() + currentYear.toString().substring(0);
    }

    final url = Uri.parse(
        "http://103.204.185.17:24978/webapi/api/Common/FinYear?COMP_CODE=" +
            widget.code);
    final response = await http.get(url);
    final jsonResponseList = json.decode(response.body);
    setState(
      () {
        finyeara = List.castFrom(jsonResponseList);

        for (var year in finyeara) {
          if (year["FINYEAR"].toString() == financialYear) {
            toDateController.text = DateFormat("dd.MM.yyyy")
                .format(DateTime.parse(year["TO_DATE"].toString()));
            fromDateController.text = DateFormat("dd.MM.yyyy")
                .format(DateTime.parse(year["FROM_DATE"].toString()));
          }
        }
      },
    );
  }

  // Function to format number with commas after each crore, lakh, thousand, hundred, and decimal places
  String formatNumberWithCommas(dynamic value) {
    String stringValue = value.toString();
    if (stringValue.contains('.')) {
      final parts = stringValue.split('.');
      String integerPart = parts[0];
      String decimalPart = parts[1];
      String formattedIntegerPart =
          NumberFormat('#,##,##,##,##0').format(int.parse(integerPart));
      return '$formattedIntegerPart.$decimalPart';
    } else {
      String formattedValue =
          NumberFormat('#,##,##,##,##0.00').format(int.parse(stringValue));
      if (formattedValue == "0") {
        formattedValue =
            NumberFormat('#,##,##,##,##0.00').format(double.parse(stringValue));
      }
      return formattedValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Account Ledger"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text(
                          "Acc Name",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 20.0),
                        SizedBox(
                          width: 250,
                          child: DropdownSearch<Map<String, dynamic>>(
                            itemAsString: (Map<String, dynamic> accLA) =>
                                accLA["NAME"],
                            items: accLA,
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                            ),
                            dropdownButtonProps: const DropdownButtonProps(
                              color: Colors.red,
                            ),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              textAlignVertical: TextAlignVertical.center,
                              dropdownSearchDecoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(left: 10, right: 5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(
                                () {
                                  itemSelectedLA = value!;
                                  updateAccountAddress(itemSelectedLA!);
                                  accCode = value['ACC_CODE'];

                                  getOpeningBalanceList();
                                  getClosingBalanceList();
                                  getAccLADetailsList();
                                },
                              );
                            },
                            selectedItem: itemSelectedLA,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Acc Address",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                        const SizedBox(width: 20.0),
                        Flexible(
                          child: Text(
                            accLA.isEmpty
                                ? ""
                                : accLA[0]["ADD0"].toString() +
                                    accLA[0]["ADD1"].toString() +
                                    accLA[0]["ADD2"].toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Doc Type",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          height: 40,
                          width: 180,
                          child: TextFormField(
                            controller: docTypeController,
                            decoration: InputDecoration(
                              hintText: 'Enter Doc',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  docTypeController.clear();
                                },
                                icon: const Icon(Icons.clear),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5.0),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                    child: Row(
                      children: [
                        for (int i = 0; i < radioOptions.length; i++)
                          if (i == 0)
                            Expanded(
                              child: Row(
                                children: [
                                  Radio(
                                    value: radioOptions[i],
                                    groupValue: selectedOption,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedOption = value!;
                                        getFinYearDate();

                                        showDateFields =
                                            selectedOption == 'Custom Date';
                                        if (selectedOption == 'Last Month') {
                                          getLastMonthDates();
                                          getAccLADetailsList();
                                        }
                                      });
                                    },
                                  ),
                                  Text(radioOptions[i]),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  SizedBox(
                    height: 20,
                    child: Row(
                      children: [
                        for (int i = 1; i < radioOptions.length; i += 2)
                          Expanded(
                            child: Row(
                              children: [
                                Radio(
                                  value: radioOptions[i],
                                  groupValue: selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOption = value!;
                                      showDateFields =
                                          selectedOption == 'Custom Date';
                                    });
                                  },
                                ),
                                Text(radioOptions[i]),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  SizedBox(
                    height: 20,
                    child: Row(
                      children: [
                        for (int i = 2; i < radioOptions.length; i += 2)
                          Expanded(
                            child: Row(
                              children: [
                                Radio(
                                  value: radioOptions[i],
                                  groupValue: selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOption = value!;
                                      showDateFields =
                                          selectedOption == 'Custom Date';
                                    });
                                  },
                                ),
                                Text(radioOptions[i]),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: showDateFields,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "From Date",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                              const SizedBox(height: 5.0),
                              SizedBox(
                                height: 40,
                                width: 150,
                                child: TextFormField(
                                  controller: fromDateController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9.,]')),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter date',
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 8.0),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            fromDateController.clear();
                                          },
                                          child: const Icon(Icons.clear),
                                        ),
                                        const SizedBox(width: 5.0),
                                        InkWell(
                                          onTap: () async {
                                            final DateTime? selectedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime(2200),
                                            );
                                            if (selectedDate != null) {
                                              fromDateController.text =
                                                  DateFormat('dd.MM.yyyy')
                                                      .format(selectedDate);
                                            }
                                          },
                                          child:
                                              const Icon(Icons.calendar_today),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "To Date",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                              const SizedBox(height: 5.0),
                              SizedBox(
                                height: 40,
                                width: 150,
                                child: TextFormField(
                                  controller: toDateController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9.,]')),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter document date',
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 8.0),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            toDateController.clear();
                                          },
                                          child: const Icon(Icons.clear),
                                        ),
                                        const SizedBox(width: 5.0),
                                        InkWell(
                                          onTap: () async {
                                            final DateTime? selectedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime(2200),
                                            );
                                            if (selectedDate != null) {
                                              toDateController.text =
                                                  DateFormat('dd.MM.yyyy')
                                                      .format(selectedDate);
                                            }
                                          },
                                          child:
                                              const Icon(Icons.calendar_today),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (selectedOption == 'Custom Date' &&
                        (fromDateController.text.isEmpty ||
                            toDateController.text.isEmpty)) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Error"),
                            content: const Text(
                                "Please enter both From Date and To Date!"),
                            actions: [
                              AnimatedButton(
                                width: 100,
                                height: 40,
                                color: Colors.red,
                                child: const Text(
                                  "OK",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      setState(() {
                        if (selectedOption == 'Last Month') {
                          getLastMonthDates();
                        } else if (selectedOption == 'Last 3 Months') {
                          getLastThreeMonthsDates();
                        } else if (selectedOption == 'Last 6 Months') {
                          getLastSixMonthsDates();
                        } else if (selectedOption == 'Last 1 Years') {
                          getLastYearDates();
                        }
                      });

                      // Fetch the data and wait for completion before updating state
                      await getAccLADetailsList();
                      await getOpeningBalanceList();
                      await getClosingBalanceList();

                      setState(() {
                        // Update the state after fetching the data
                      });
                    }
                  },
                  child: const Text('Execute/run'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Visibility(
                        visible: openingBalance.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Row(
                            children: [
                              const Text(
                                "Opening Balance",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Text(
                                openingBalance.isEmpty
                                    ? ""
                                    : "${formatNumberWithCommas(openingBalance[0]["OPENING_BALANCE"])} ${openingBalance[0]["OPENING_BALANCE"].toString().contains("-") ? "Cr" : "Dr"}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Visibility(
                        visible: closingBalance.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Row(
                            children: [
                              const Text(
                                "Closing Balance  ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 16.0),
                              ),
                              const SizedBox(width: 10.0),
                              Text(
                                closingBalance.isEmpty
                                    ? ""
                                    : "${formatNumberWithCommas(closingBalance[0]["CLOSING_BALANCE"])} ${closingBalance[0]["CLOSING_BALANCE"].toString().contains("-") ? "Cr" : "Dr"}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: toggleSortOrder,
                    icon: Icon(
                      sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: accLADetails.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(
                        left: 18, right: 18, bottom: 5, top: 5),
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('dd.MM.yy')
                                            .format(DateTime.parse(
                                          accLADetails[index]["DOC_DATE"]
                                              .toString(),
                                        )),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        accLADetails[index]["DOC_TYPE"] +
                                            " - " +
                                            accLADetails[index]["REMARKS"],
                                        style: const TextStyle(),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      if (accLADetails[index]["DR_AMOUNT"] > 0)
                                        Text(
                                          "${formatNumberWithCommas(accLADetails[index]["DR_AMOUNT"])}  Dr",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
                                          ),
                                        )
                                      else
                                        Container(),
                                      if (accLADetails[index]["CR_AMOUNT"] > 0)
                                        Text(
                                          "${formatNumberWithCommas(accLADetails[index]["CR_AMOUNT"])}  Cr",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                          ),
                                        )
                                      else
                                        Container(),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
