import 'package:flutter/cupertino.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

class GridItems {
  final String title, icon,route;

  GridItems({required this.route, required this.title, required this.icon});
}



List<GridItems> getFreeIcons({required BuildContext context}){
  List<GridItems> freeIcons = [
    GridItems(
      title: lang.S.of(context).sales,
      route: 'Sales',
      icon: 'images/sales.svg',
    ),

    GridItems(
      title: lang.S.of(context).parties,
      icon: 'images/parties.svg',
      route: 'Parties',
    ),
    GridItems(
      title: lang.S.of(context).purchase,
      icon: 'images/purchase.svg',
      route: 'Purchase',
    ),
    GridItems(
      title: lang.S.of(context).product,
      icon: 'images/product.svg',
      route: 'Product',
    ),
    GridItems(
      title: lang.S.of(context).dueList,
      icon: 'images/duelist.svg',
      route: 'Due List',
    ),
    GridItems(
      title: lang.S.of(context).stocks,
      icon: 'images/stock.svg',
      route: 'Stock List'
    ),

    GridItems(
      title: lang.S.of(context).reports,
      icon: 'images/report.svg',
      route: 'Reports'
    ),
    GridItems(
      title: lang.S.of(context).salesList,
      icon: 'images/saleslist.svg',
      route: 'Sale List'
    ),
    GridItems(
      title: lang.S.of(context).purchaseList,
      icon: 'images/purchaselist.svg',
      route: 'Purchase List'
    ),
    GridItems(
      title: lang.S.of(context).lossOrProfit,
      icon: 'images/loss.svg',
      route: 'Loss/Profit'
    ),
    GridItems(
      title: lang.S.of(context).ledger,
      icon: 'images/ledger.svg',
      route: 'Ledger'
    ),
    GridItems(
      title: lang.S.of(context).expense,
      icon: 'images/expense.svg',
      route: 'Expense'
    ),
    GridItems(
        title: 'Tax Report',
        icon: 'images/saleslist.svg',
        route: 'taxReport'
    ),
    GridItems(
      title: lang.S.of(context).customPrint,
      icon: 'images/printer.png',
      route: 'CustomPrint',
    ),
  ];
  return freeIcons;
}

List<GridItems> freeIcons=[];


List<GridItems> businessIcons = [
  GridItems(
    title: 'Warehouse',
    icon: 'images/warehouse.png',
    route: 'Warehouse'
  ),
  GridItems(
    title: 'SalesReturn',
    icon: 'images/salesreturn.png',
    route: 'SalesReturn'
  ),
  GridItems(
    title: 'SalesList',
    icon: 'images/salelist.png',
    route: 'SalesList'
  ),
  GridItems(
    title: 'Quotation',
    icon: 'images/quotation.png',
    route: 'Quotation'
  ),
  GridItems(
    title: 'OnlineStore',
    icon: 'images/onlinestore.png',
    route: 'OnlineStore'
  ),
  GridItems(
    title: 'Supplier',
    icon: 'images/supplier.png',
    route: 'Supplier'
  ),
  GridItems(
    title: 'Invoice',
    icon: 'images/invoice.png',
    route: 'Invoice'
  ),
  GridItems(
    title: 'Stock',
    icon: 'images/stock.png',
    route: 'Stock'
  ),
  GridItems(
    title: 'Ledger',
    icon: 'images/ledger.png',
    route: 'Ledger'
  ),
  GridItems(
    title: 'Dashboard',
    icon: 'images/dashboard.png',
    route: 'Dashboard'
  ),
  GridItems(
    title: 'Bank',
    icon: 'images/bank.png',
    route: 'Bank'
  ),
  GridItems(
    title: 'Barcode',
    icon: 'images/barcodescan.png',
    route: 'Barcode'
  )
];

List<GridItems> enterpriseIcons = [
  GridItems(
    title: 'Branch',
    icon: 'images/branch.png',
    route: 'Branch'
  ),
  GridItems(
    title: 'Damage',
    icon: 'images/damage.png',
    route: 'Damage'
  ),
  GridItems(
    title: 'Adjustment',
    icon: 'images/adjustment.png',
    route: 'Adjustment'
  ),
  GridItems(
    title: 'Transaction',
    icon: 'images/transaction.png',
    route: 'Transaction'
  ),
  GridItems(
    title: 'Gift',
    icon: 'images/gift.png',
    route: 'Gift'
  ),
  GridItems(
    title: 'Loss&Profit',
    icon: 'images/lossProfit.png',
    route: 'Loss&Profit'
  ),
  GridItems(
    title: 'Income',
    icon: 'images/income.png',
    route: 'Income'
  ),
  GridItems(
    title: 'OnlineOrder',
    icon: 'images/onlineorder.png',
    route: 'OnlineOrder'
  ),
  GridItems(
    title: 'UserRole',
    icon: 'images/userrole.png',
    route: 'UserRole'
  ),
  GridItems(
    title: 'Backup',
    icon: 'images/backup.png',
    route: 'Backup'
  ),
  GridItems(
    title: 'Return',
    icon: 'images/return.png',
    route: 'Return'
  )
];
