import 'package:flutter/material.dart';
import 'package:users/widgets/custom_bottom_nav_bar.dart';

class ChatRoomListScreen extends StatelessWidget {
  static const String routeName = '/chat_list';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your chats')),
      body: Body(),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
