import 'package:firebase_database/firebase_database.dart';

import 'currency.dart';

class MigrationFirebase {
  Future<bool> migrateUsers() async {
    final database = FirebaseDatabase.instance.ref(constUserId).child("Customers");
    database.keepSynced(true);
    database.orderByKey().get().then((value) {
     for(var element in value.children){
       database.child(element.key.toString()).update({"migrated" : true});
     }
    });
    return true;
  }
}
