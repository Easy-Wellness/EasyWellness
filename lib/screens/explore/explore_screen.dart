import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:users/widgets/custom_bottom_nav_bar.dart';

import 'search_services_form.dart';

class ExploreScreen extends StatelessWidget {
  static const String routeName = '/explore';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text('Explore')),
        body: Body(),
        bottomNavigationBar: CustomBottomNavBar(),
      ),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SearchServicesForm(),
          const SizedBox(height: 40),
          SvgPicture.asset(
            "assets/icons/explore.svg",
            height: size.height * 0.3,
          ),
        ],
      ),
    );
  }
}
