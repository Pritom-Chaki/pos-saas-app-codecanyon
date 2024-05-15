class DueTransactionModel {
  late String customerName, customerPhone, customerAddress, customerType, invoiceNumber, purchaseDate;
  double? totalDue;
  double? dueAmountAfterPay;
  double? payDueAmount;
  bool? isPaid;
  String? paymentType;

  DueTransactionModel({
    required this.customerName,
    required this.customerType,
    required this.customerPhone,
    required this.customerAddress,
    required this.invoiceNumber,
    required this.purchaseDate,
    this.dueAmountAfterPay,
    this.totalDue,
    this.payDueAmount,
    this.isPaid,
    this.paymentType,
  });

  DueTransactionModel.fromJson(Map<dynamic, dynamic> json) {
    customerName = json['customerName'] as String;
    customerPhone = json['customerPhone'].toString();
    customerAddress = json['customerAddress'] ?? '';
    invoiceNumber = json['invoiceNumber'].toString();
    customerType = json['customerType'].toString();
    purchaseDate = json['purchaseDate'].toString();
    totalDue = double.parse(json['totalDue'].toString());
    dueAmountAfterPay = double.parse(json['dueAmountAfterPay'].toString());
    payDueAmount = double.parse(json['payDueAmount'].toString());
    isPaid = json['isPaid'];
    paymentType = json['paymentType'].toString();
  }

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerAddress': customerAddress,
        'customerType': customerType,
        'invoiceNumber': invoiceNumber,
        'purchaseDate': purchaseDate,
        'totalDue': totalDue,
        'dueAmountAfterPay': dueAmountAfterPay,
        'payDueAmount': payDueAmount,
        'isPaid': isPaid,
        'paymentType': paymentType,
      };
}
