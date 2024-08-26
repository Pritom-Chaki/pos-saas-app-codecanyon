class CustomerModel {
  late String customerName, phoneNumber, type, profilePicture, emailAddress, customerAddress, dueAmount, openingBalance, remainedBalance, gst,note;

  CustomerModel(
      this.customerName, this.phoneNumber, this.type, this.profilePicture, this.emailAddress, this.customerAddress, this.dueAmount, this.openingBalance, this.remainedBalance,this.note,
      {required this.gst,});

  CustomerModel.fromJson(Map<dynamic, dynamic> json)
      : customerName = json['customerName'] ?? 'Test',
        phoneNumber = json['phoneNumber'] as String,
        type = json['type'] as String,
        profilePicture = json['profilePicture'] as String,
        emailAddress = json['emailAddress'] as String,
        customerAddress = json['customerAddress'] as String,
        dueAmount = json['due'] as String,
        openingBalance = json['openingBalance'] as String,
        remainedBalance = json['remainedBalance'] as String,
        note = json['note'] ?? 'N/A',
        gst = json['gst'] ?? '';

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'customerName': customerName,
        'phoneNumber': phoneNumber,
        'type': type,
        'profilePicture': profilePicture,
        'emailAddress': emailAddress,
        'customerAddress': customerAddress,
        'due': dueAmount,
        'openingBalance': openingBalance,
        'remainedBalance': remainedBalance,
        'note': note,
        'gst': gst,
      };
}
