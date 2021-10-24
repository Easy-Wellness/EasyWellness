import 'package:flutter/material.dart';

Future<T?> pushNewPage<T extends Object?>(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<T>(builder: (_) => page));
