import 'package:flutter/material.dart';
import 'package:users/components/custom_bottom_nav_bar.dart';

import 'search_services_form.dart';

class ExploreScreen extends StatelessWidget {
  static const String routeName = '/explore';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          title: Text('Explore'),
        ),
        body: Body(),
        bottomNavigationBar: CustomBottomNavBar(),
      ),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SearchServicesForm(),
    );
  }
}
