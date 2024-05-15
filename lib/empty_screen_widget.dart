import 'package:flutter/material.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

class EmptyScreenWidget extends StatelessWidget {
  const EmptyScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.width() - 100,
      width: context.width() - 100,
      child: Column(
        children: [
          Image.asset('images/empty_screen.png'),
          const SizedBox(height: 30),
           Text(
             lang.S.of(context).noData,
            style: const TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }
}
