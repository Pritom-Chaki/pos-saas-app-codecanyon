class PaypalInfoModel {
  PaypalInfoModel({
    required this.paypalClientId,
    required this.paypalClientSecret,
    required this.isLive,
  });

  String paypalClientId, paypalClientSecret;
  bool isLive;

  PaypalInfoModel.fromJson(Map<dynamic, dynamic> json)
      : paypalClientId = json['paypalClientId'],
        paypalClientSecret = json['paypalClientSecret'],
        isLive = json['isLive'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'paypalClientId': paypalClientId,
        'paypalClientSecret': paypalClientSecret,
        'isLive': isLive,
      };
}


class StripeInfoModel {
  StripeInfoModel({
    required this.stripePublishableKey,
    required this.stripeSecretKey,
    required this.stripeCurrency,
    required this.isLive,
  });

  String stripePublishableKey, stripeSecretKey,stripeCurrency;
  bool isLive;

  StripeInfoModel.fromJson(Map<dynamic, dynamic> json)
      : stripePublishableKey = json['stripePublishableKey'],
        stripeSecretKey = json['stripeSecretKey'],
        stripeCurrency = json['stripeCurrency'],
        isLive = json['isLive'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'stripePublishableKey': stripePublishableKey,
    'stripeSecretKey': stripeSecretKey,
    'stripeCurrency': stripeCurrency,
    'isLive': isLive,
  };
}

class SSLInfoModel {
  SSLInfoModel({
    required this.sslStoreId,
    required this.sslStoreSecret,
    required this.isLive,
  });

  String sslStoreId, sslStoreSecret;
  bool isLive;

  SSLInfoModel.fromJson(Map<dynamic, dynamic> json)
      : sslStoreId = json['sslStoreId'],
        sslStoreSecret = json['sslStoreSecret'],
        isLive = json['isLive'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'sslStoreId': sslStoreId,
    'sslStoreSecret': sslStoreSecret,
    'isLive': isLive,
  };
}

class FlutterWaveInfoModel {
  FlutterWaveInfoModel({
    required this.flutterWavePublicKey,
    required this.flutterWaveSecretKey,
    required this.flutterWaveEncKey,
    required this.flutterWaveCurrency,
    required this.isLive,
  });

  String flutterWavePublicKey, flutterWaveSecretKey, flutterWaveEncKey, flutterWaveCurrency;
  bool isLive;

  FlutterWaveInfoModel.fromJson(Map<dynamic, dynamic> json)
      : flutterWavePublicKey = json['flutterWavePublicKey'],
        flutterWaveSecretKey = json['flutterWaveSecretKey'],
        flutterWaveEncKey = json['flutterWaveEncKey'],
        flutterWaveCurrency = json['flutterWaveCurrency'],
        isLive = json['isLive'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'flutterWavePublicKey': flutterWavePublicKey,
    'flutterWaveSecretKey': flutterWaveSecretKey,
    'flutterWaveEncKey': flutterWaveEncKey,
    'flutterWaveCurrency': flutterWaveCurrency,
    'isLive': isLive,
  };
}

class RazorpayInfoModel {
  RazorpayInfoModel({
    required this.razorpayId,
    required this.razorpayCurrency,
    required this.isLive,
  });

  String razorpayId, razorpayCurrency;
  bool isLive;

  RazorpayInfoModel.fromJson(Map<dynamic, dynamic> json)
      : razorpayId = json['razorpayId'],
        razorpayCurrency = json['razorpayCurrency'],
        isLive = json['isLive'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'razorpayId': razorpayId,
    'razorpayCurrency': razorpayCurrency,
    'isLive': isLive,
  };
}

class TapInfoModel {
  TapInfoModel({
    required this.tapId,
    required this.isLive,
  });

  String tapId;
  bool isLive;

  TapInfoModel.fromJson(Map<dynamic, dynamic> json)
      : tapId = json['tapId'],
        isLive = json['isLive'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'tapId': tapId,
    'isLive': isLive,
  };
}

class KkiPayInfoModel {
  KkiPayInfoModel({
    required this.kkiPayApiKey,
    required this.isLive,
  });

  String kkiPayApiKey;
  bool isLive;

  KkiPayInfoModel.fromJson(Map<dynamic, dynamic> json)
      : kkiPayApiKey = json['kkiPayApiKey'],
        isLive = json['isLive'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'kkiPayApiKey': kkiPayApiKey,
    'isLive': isLive,
  };
}

class PayStackInfoModel {
  PayStackInfoModel({
    required this.payStackPublicKey,
    required this.isLive,
  });

  String payStackPublicKey;
  bool isLive;

  PayStackInfoModel.fromJson(Map<dynamic, dynamic> json)
      : payStackPublicKey = json['payStackPublicKey'],
        isLive = json['isLive'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'payStackPublicKey': payStackPublicKey,
    'isLive': isLive,
  };
}


class CashFreeInfoModel {
  CashFreeInfoModel({
    required this.cashFreeClientId,
    required this.cashFreeClientSecret,
    required this.cashFreeApiVersion,
    required this.cashFreeRequestId,
    required this.isLive,
  });

  String cashFreeClientId, cashFreeClientSecret, cashFreeApiVersion, cashFreeRequestId;
  bool isLive;

  CashFreeInfoModel.fromJson(Map<dynamic, dynamic> json)
      : cashFreeClientId = json['cashFreeClientId'],
        cashFreeClientSecret = json['cashFreeClientSecret'],
        cashFreeApiVersion = json['cashFreeApiVersion'],
        cashFreeRequestId = json['cashFreeRequestId'],
        isLive = json['isLive'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'cashFreeClientId': cashFreeClientId,
    'cashFreeClientSecret': cashFreeClientSecret,
    'cashFreeApiVersion': cashFreeApiVersion,
    'cashFreeRequestId': cashFreeRequestId,
    'isLive': isLive,
  };
}

class BillPlzInfoModel {
  BillPlzInfoModel({
    required this.billPlzSecretKey,
    required this.isLive,
  });

  String billPlzSecretKey;
  bool isLive;

  BillPlzInfoModel.fromJson(Map<dynamic, dynamic> json)
      : billPlzSecretKey = json['billPlzSecretKey'],
        isLive = json['isLive'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'billPlzSecretKey': billPlzSecretKey,
    'isLive': isLive,
  };
}

class IyzicoInfoModel {
  IyzicoInfoModel({
    required this.iyzicoPublicKey,
    required this.iyzicoSecretKey,
    required this.isLive,
  });

  String iyzicoPublicKey,iyzicoSecretKey;
  bool isLive;

  IyzicoInfoModel.fromJson(Map<dynamic, dynamic> json)
      : iyzicoPublicKey = json['iyzicoPublicKey'],
      iyzicoSecretKey = json['iyzicoSecretKey'],
        isLive = json['isLive'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'iyzicoPublicKey': iyzicoPublicKey,
    'iyzicoSecretKey': iyzicoSecretKey,
    'isLive': isLive,
  };
}