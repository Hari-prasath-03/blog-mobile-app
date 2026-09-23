import 'package:blog_app/core/theme/app_pallet.dart';
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppPallet.gradient2),
    );
  }
}
