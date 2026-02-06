import 'package:flutter/material.dart';
import 'package:quickride/features/tracking/presentation/pages/map_screen.dart';

class SearchLocationScreen extends StatelessWidget {
  const SearchLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: MapScreen());
  }
}
