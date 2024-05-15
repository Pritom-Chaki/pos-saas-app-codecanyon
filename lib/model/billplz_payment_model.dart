class BillplzPaymentModel {
  BillplzPaymentModel({
      String? id, 
      String? collectionId, 
      bool? paid, 
      String? state, 
      num? amount, 
      num? paidAmount, 
      String? dueAt, 
      String? email, 
      dynamic mobile, 
      String? name, 
      String? url, 
      String? reference1Label, 
      dynamic reference1, 
      String? reference2Label, 
      dynamic reference2, 
      dynamic redirectUrl, 
      String? callbackUrl, 
      String? description, 
      dynamic paidAt,}){
    _id = id;
    _collectionId = collectionId;
    _paid = paid;
    _state = state;
    _amount = amount;
    _paidAmount = paidAmount;
    _dueAt = dueAt;
    _email = email;
    _mobile = mobile;
    _name = name;
    _url = url;
    _reference1Label = reference1Label;
    _reference1 = reference1;
    _reference2Label = reference2Label;
    _reference2 = reference2;
    _redirectUrl = redirectUrl;
    _callbackUrl = callbackUrl;
    _description = description;
    _paidAt = paidAt;
}

  BillplzPaymentModel.fromJson(dynamic json) {
    _id = json['id'];
    _collectionId = json['collection_id'];
    _paid = json['paid'];
    _state = json['state'];
    _amount = json['amount'];
    _paidAmount = json['paid_amount'];
    _dueAt = json['due_at'];
    _email = json['email'];
    _mobile = json['mobile'];
    _name = json['name'];
    _url = json['url'];
    _reference1Label = json['reference_1_label'];
    _reference1 = json['reference_1'];
    _reference2Label = json['reference_2_label'];
    _reference2 = json['reference_2'];
    _redirectUrl = json['redirect_url'];
    _callbackUrl = json['callback_url'];
    _description = json['description'];
    _paidAt = json['paid_at'];
  }
  String? _id;
  String? _collectionId;
  bool? _paid;
  String? _state;
  num? _amount;
  num? _paidAmount;
  String? _dueAt;
  String? _email;
  dynamic _mobile;
  String? _name;
  String? _url;
  String? _reference1Label;
  dynamic _reference1;
  String? _reference2Label;
  dynamic _reference2;
  dynamic _redirectUrl;
  String? _callbackUrl;
  String? _description;
  dynamic _paidAt;

  String? get id => _id;
  String? get collectionId => _collectionId;
  bool? get paid => _paid;
  String? get state => _state;
  num? get amount => _amount;
  num? get paidAmount => _paidAmount;
  String? get dueAt => _dueAt;
  String? get email => _email;
  dynamic get mobile => _mobile;
  String? get name => _name;
  String? get url => _url;
  String? get reference1Label => _reference1Label;
  dynamic get reference1 => _reference1;
  String? get reference2Label => _reference2Label;
  dynamic get reference2 => _reference2;
  dynamic get redirectUrl => _redirectUrl;
  String? get callbackUrl => _callbackUrl;
  String? get description => _description;
  dynamic get paidAt => _paidAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['collection_id'] = _collectionId;
    map['paid'] = _paid;
    map['state'] = _state;
    map['amount'] = _amount;
    map['paid_amount'] = _paidAmount;
    map['due_at'] = _dueAt;
    map['email'] = _email;
    map['mobile'] = _mobile;
    map['name'] = _name;
    map['url'] = _url;
    map['reference_1_label'] = _reference1Label;
    map['reference_1'] = _reference1;
    map['reference_2_label'] = _reference2Label;
    map['reference_2'] = _reference2;
    map['redirect_url'] = _redirectUrl;
    map['callback_url'] = _callbackUrl;
    map['description'] = _description;
    map['paid_at'] = _paidAt;
    return map;
  }

}