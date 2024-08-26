import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Provider/profile_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../Home/home.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  _CurrencyScreenState createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String? selectedCountry = '\$ (US Dollar)';
  String currency = "\$";

  final List<String> countryList = [
    '\$ (US Dollar)',
    '₹ (Rupee)',
    '€ (Euro)',
    '₽ (Ruble)',
    '£ (UK Pound)',
    '৳ (Taka)',
    'R (Rial)',
    '؋ (Afghani)',
    'Lek (Lek)',
    'د.ج (Algerian Dinar)',
    'Kz (Kwanza)',
    'EC\$ (East Caribbean Dollar)',
    '\$ (Argentine Peso)',
    '֏ (Armenian Dram)',
    'A\$ (Australian Dollar)',
    '₼ (Azerbaijani Manat)',
    'B\$ (Bahamian Dollar)',
    '.د.ب (Bahraini Dinar)',
    'Bds\$ (Barbadian Dollar)',
    'Br (Belarusian Ruble)',
    'BZ\$ (Belize Dollar)',
    'CFA (West African CFA franc)',
    'FCFA (West African CFA franc)',
    'Nu. (Bhutanese Ngultrum)',
    'Bs. (Bolivian Boliviano)',
    'KM (Bosnia and Herzegovina Convertible Mark)',
    'P (Botswana Pula)',
    'R\$ (Brazilian Real)',
    'B\$ (Brunei Dollar)',
    'лв (Bulgarian Lev)',
    'FBu (Burundian Franc)',
    'Esc (Cape Verdean Escudo)',
    '៛ (Cambodian Riel)',
    'CFA (Central African CFA franc)',
    'CA\$ (Canadian Dollar)',
    '\$ (Chilean Peso)',
    '¥ (Chinese Yuan)',
    '\$ (Colombian Peso)',
    'CF (Comorian Franc)',
    'FC (Congolese Franc)',
    '₡ (Costa Rican Colón)',
    'kn (Croatian Kuna)',
    'CUP (Cuban Peso)',
    'Kč (Czech Koruna)',
    'kr (Danish Krone)',
    'Fdj (Djiboutian Franc)',
    'RD\$ (Dominican Peso)',
    'US\$ (United States Dollar)',
    '\$ (United States Dollar)',
    'E£ (Egyptian Pound)',
    'Nfk (Eritrean Nakfa)',
    'E (Swazi Lilangeni)',
    'Br (Ethiopian Birr)',
    'FJ\$ (Fijian Dollar)',
    'D (Gambian Dalasi)',
    '₾ (Georgian Lari)',
    'GH₵ (Ghanaian Cedi)',
    'Q (Guatemalan Quetzal)',
    'GNF (Guinean Franc)',
    'GY\$ (Guyanese Dollar)',
    'G (Haitian Gourde)',
    'L (Honduran Lempira)',
    'Ft (Hungarian Forint)',
    'kr (Icelandic Króna)',
    'Rp (Indonesian Rupiah)',
    '﷼ (Iranian Rial)',
    'ع.د (Iraqi Dinar)',
    '₪ (Israeli New Shekel)',
    'J\$ (Jamaican Dollar)',
    '¥ (Japanese Yen)',
    'د.ا (Jordanian Dinar)',
    '₸ (Kazakhstani Tenge)',
    'KSh (Kenyan Shilling)',
    'AU\$ (Australian Dollar)',
    'د.ك (Kuwaiti Dinar)',
    'som (Kyrgyzstani Som)',
    '₭ (Laotian Kip)',
    'ل.ل (Lebanese Pound)',
    'L (Lesotho Loti)',
    'L\$ (Liberian Dollar)',
    'ل.د (Libyan Dinar)',
    'CHF (Swiss Franc)',
    'Ar (Malagasy Ariary)',
    'MK (Malawian Kwacha)',
    'RM (Malaysian Ringgit)',
    'Rf (Maldivian Rufiyaa)',
    'Ouguiya (Mauritanian Ouguiya)',
    'Rs (Mauritian Rupee)',
    'Mex\$ (Mexican Peso)',
    'lei (Moldovan Leu)',
    '₮ (Mongolian Tugrik)',
    'د.م. (Moroccan Dirham)',
    'MT (Mozambican Metical)',
    'K (Myanmar Kyat)',
    'N\$ (Namibian Dollar)',
    'रू (Nepalese Rupee)',
    'NZ\$ (New Zealand Dollar)',
    'C\$ (Nicaraguan Córdoba)',
    '₦ (Nigerian Naira)',
    'kr (Norwegian Krone)',
    '﷼ (Omani Rial)',
    'PKR (Pakistani Rupee)',
    '₱ (Philippine Peso)',
    'zł (Polish Złoty)',
    '﷼ (Qatari Riyal)',
    'lei (Romanian Leu)',
    'руб (Russian Ruble)',
    'RF (Rwandan Franc)',
    '₣ (Swiss Franc)',
    '₲ (Paraguayan Guarani)',
    'SR (Saudi Riyal)',
    'د.س (Sudanese Pound)',
    '\$ (Singapore Dollar)',
    'S (Solomon Islands Dollar)',
    'Sh (Somali Shilling)',
    'R (South African Rand)',
    '₩ (South Korean Won)',
    '£ (British Pound)',
    '\$ (Sri Lankan Rupee)',
    'L (Saint Helenian Pound)',
    '\$ (East Caribbean Dollar)',
    'kr (Swedish Krona)',
    'TJS (Tajikistani Somoni)',
    'TSh (Tanzanian Shilling)',
    '฿ (Thai Baht)',
    'T (Tongan Paʻanga)',
    'TTD (Trinidad and Tobago Dollar)',
    'XAf (XAf Central Africa)',
    // Add more currencies as needed
  ];

  final Map<String, String> currencySymbols = {
    '\$ (US Dollar)': '\$',
    '₹ (Rupee)': '₹',
    '€ (Euro)': '€',
    '₽ (Ruble)': '₽',
    '£ (UK Pound)': '£',
    '৳ (Taka)': '৳',
    'R (Rial)': 'R',
    '؋ (Afghani)': '؋',
    'Lek (Lek)': 'Lek',
    'د.ج (Algerian Dinar)': 'د.ج',
    'Kz (Kwanza)': 'Kz',
    'EC\$ (East Caribbean Dollar)': 'EC\$',
    '\$ (Argentine Peso)': '\$',
    '֏ (Armenian Dram)': '֏',
    'A\$ (Australian Dollar)': 'A\$',
    '₼ (Azerbaijani Manat)': '₼',
    'B\$ (Bahamian Dollar)': 'B\$',
    '.د.ب (Bahraini Dinar)': '.د.ب',
    'Bds\$ (Barbadian Dollar)': 'Bds\$',
    'Br (Belarusian Ruble)': 'Br',
    'BZ\$ (Belize Dollar)': 'BZ\$',
    'CFA (West African CFA franc)': 'CFA',
    'FCFA (West African CFA franc)': 'FCFA',
    'Nu. (Bhutanese Ngultrum)': 'Nu.',
    'Bs. (Bolivian Boliviano)': 'Bs.',
    'KM (Bosnia and Herzegovina Convertible Mark)': 'KM',
    'P (Botswana Pula)': 'P',
    'R\$ (Brazilian Real)': 'R\$',
    'B\$ (Brunei Dollar)': 'B\$',
    'лв (Bulgarian Lev)': 'лв',
    'FBu (Burundian Franc)': 'FBu',
    'Esc (Cape Verdean Escudo)': 'Esc',
    '៛ (Cambodian Riel)': '៛',
    'CFA (Central African CFA franc)': 'CFA',
    'CA\$ (Canadian Dollar)': 'CA\$',
    '\$ (Chilean Peso)': '\$',
    '¥ (Chinese Yuan)': '¥',
    '\$ (Colombian Peso)': '\$',
    'CF (Comorian Franc)': 'CF',
    'FC (Congolese Franc)': 'FC',
    '₡ (Costa Rican Colón)': '₡',
    'kn (Croatian Kuna)': 'kn',
    'CUP (Cuban Peso)': 'CUP',
    'Kč (Czech Koruna)': 'Kč',
    'kr (Danish Krone)': 'kr',
    'Fdj (Djiboutian Franc)': 'Fdj',
    'RD\$ (Dominican Peso)': 'RD\$',
    'US\$ (United States Dollar)': 'US\$',
    '\$ (United States Dollar)': '\$',
    'E£ (Egyptian Pound)': 'E£',
    'Nfk (Eritrean Nakfa)': 'Nfk',
    'E (Swazi Lilangeni)': 'E',
    'Br (Ethiopian Birr)': 'Br',
    'FJ\$ (Fijian Dollar)': 'FJ\$',
    'D (Gambian Dalasi)': 'D',
    '₾ (Georgian Lari)': '₾',
    'GH₵ (Ghanaian Cedi)': 'GH₵',
    'Q (Guatemalan Quetzal)': 'Q',
    'GNF (Guinean Franc)': 'GNF',
    'GY\$ (Guyanese Dollar)': 'GY\$',
    'G (Haitian Gourde)': 'G',
    'L (Honduran Lempira)': 'L',
    'Ft (Hungarian Forint)': 'Ft',
    'kr (Icelandic Króna)': 'kr',
    'Rp (Indonesian Rupiah)': 'Rp',
    '﷼ (Iranian Rial)': '﷼',
    'ع.د (Iraqi Dinar)': 'ع.د',
    '₪ (Israeli New Shekel)': '₪',
    'J\$ (Jamaican Dollar)': 'J\$',
    '¥ (Japanese Yen)': '¥',
    'د.ا (Jordanian Dinar)': 'د.ا',
    '₸ (Kazakhstani Tenge)': '₸',
    'KSh (Kenyan Shilling)': 'KSh',
    'AU\$ (Australian Dollar)': 'AU\$',
    'د.ك (Kuwaiti Dinar)': 'د.ك',
    'som (Kyrgyzstani Som)': 'som',
    '₭ (Laotian Kip)': '₭',
    'ل.ل (Lebanese Pound)': 'ل.ل',
    'L (Lesotho Loti)': 'L',
    'L\$ (Liberian Dollar)': 'L\$',
    'ل.د (Libyan Dinar)': 'ل.د',
    'CHF (Swiss Franc)': 'CHF',
    'Ar (Malagasy Ariary)': 'Ar',
    'MK (Malawian Kwacha)': 'MK',
    'RM (Malaysian Ringgit)': 'RM',
    'Rf (Maldivian Rufiyaa)': 'Rf',
    'Ouguiya (Mauritanian Ouguiya)': 'Ouguiya',
    'Rs (Mauritian Rupee)': 'Rs',
    'Mex\$ (Mexican Peso)': 'Mex\$',
    'lei (Moldovan Leu)': 'lei',
    '₮ (Mongolian Tugrik)': '₮',
    'د.م. (Moroccan Dirham)': 'د.م.',
    'MT (Mozambican Metical)': 'MT',
    'K (Myanmar Kyat)': 'K',
    'N\$ (Namibian Dollar)': 'N\$',
    'रू (Nepalese Rupee)': 'रू',
    'NZ\$ (New Zealand Dollar)': 'NZ\$',
    'C\$ (Nicaraguan Córdoba)': 'C\$',
    '₦ (Nigerian Naira)': '₦',
    'kr (Norwegian Krone)': 'kr',
    '﷼ (Omani Rial)': '﷼',
    'PKR (Pakistani Rupee)': 'PKR',
    '₱ (Philippine Peso)': '₱',
    'zł (Polish Złoty)': 'zł',
    '﷼ (Qatari Riyal)': '﷼',
    'lei (Romanian Leu)': 'lei',
    'руб (Russian Ruble)': 'руб',
    'RF (Rwandan Franc)': 'RF',
    '₣ (Swiss Franc)': '₣',
    '₲ (Paraguayan Guarani)': '₲',
    'SR (Saudi Riyal)': 'SR',
    'د.س (Sudanese Pound)': 'د.س',
    '\$ (Singapore Dollar)': '\$',
    'S (Solomon Islands Dollar)': 'S',
    'Sh (Somali Shilling)': 'Sh',
    'R (South African Rand)': 'R',
    '₩ (South Korean Won)': '₩',
    '£ (British Pound)': '£',
    '\$ (Sri Lankan Rupee)': '\$',
    'L (Saint Helenian Pound)': 'L',
    '\$ (East Caribbean Dollar)': '\$',
    'kr (Swedish Krona)': 'kr',
    'TJS (Tajikistani Somoni)': 'TJS',
    'TSh (Tanzanian Shilling)': 'TSh',
    '฿ (Thai Baht)': '฿',
    'T (Tongan Paʻanga)': 'T',
    'TTD (Trinidad and Tobago Dollar)': 'TTD',
    'XAf (XAf Central Africa)': 'XAF',
    // Add more currencies as needed
  };

  @override
  void initState() {
    super.initState();
    print('-----selected $selectedCountry-----');
    getCurrency();
  }

  Future<void> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('currency');
    print('-------------get currency $data----------');
    if (!data.isEmptyOrNull) {
      for (var element in items) {
        if (element.substring(0, 2).contains(data!) || element.substring(0, 5).contains(data)) {
          setState(() {
            selectedCountry = element;
          });
          break;
        }
      }
    } else {
      setState(() {
        selectedCountry = items[0];
      });
    }
  }

  Future<void> _updateCurrency(String newCurrency) async {
    final prefs = await SharedPreferences.getInstance();
    final DatabaseReference personalInformationRef = FirebaseDatabase.instance.ref().child(await getUserID()).child('Personal Information');
    personalInformationRef.keepSynced(true);
    if (currencySymbols.containsKey(newCurrency)) {
      currency = currencySymbols[newCurrency]!;
      personalInformationRef.update({'currency': currency});
      await prefs.setString('currency', currency);
    } else {
      currency = "\$";
      await prefs.setString('currency', currency);
    }
    setState(() {
      currency;
      selectedCountry = newCurrency;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      return Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: kWhite),
          title: Text(
            'Currency',
            style: kTextStyle.copyWith(color: kWhite),
          ),
          backgroundColor: Colors.transparent,
        ),
        bottomNavigationBar: Container(
          height: 95,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(top: 25, left: 20, right: 20, bottom: 15),
            child: InkWell(
              onTap: () async {
                await _updateCurrency(selectedCountry ?? '');
                ref.refresh(profileDetailsProvider);
                // final prefs = await SharedPreferences.getInstance();
                // String? data = prefs.getString('currency');
                // if (!data.isEmptyOrNull) {
                //   currency = data!;
                // }
                // Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
              },
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: kMainColor),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ListView.builder(
              itemCount: currencySymbols.length,
              itemBuilder: (_, index) {
                String country = currencySymbols.keys.elementAt(index);
                // String country = currencySymbols[index]??'';
                return Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 0.7),
                    ),
                    child: ListTile(
                      horizontalTitleGap: 5,
                      onTap: () async {
                        setState(() {
                          selectedCountry = country;
                        });

                        // await _updateCurrency(country);
                        // ref.refresh(profileDetailsProvider);

                        // ref.refresh(profileDetailsProvider);
                      },
                      title: Text(country),
                      trailing: selectedCountry == country ? const Icon(Icons.radio_button_checked, color: Colors.blue) : const Icon(Icons.radio_button_off, color: Color(0xff9F9F9F)),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }
}
