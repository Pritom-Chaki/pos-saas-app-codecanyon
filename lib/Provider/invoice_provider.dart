


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/repository/invoice_repo.dart';

import '../model/invoice_model.dart';


final invoiceSettingsProvider = FutureProvider.autoDispose<InvoiceModel>((ref) => InvoiceRepo.getInvoiceSettings());
