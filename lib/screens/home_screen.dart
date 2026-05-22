import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.lightGray,
      child: SizedBox.expand(),
    );
  }
}
