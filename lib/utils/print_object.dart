import 'dart:convert';

import 'package:flutter/material.dart';

void printObject(Object object) {
  // Encode your object and then decode your object to Map variable
  Map jsonMapped = json.decode(json.encode(object));

  // Using JsonEncoder for spacing
  JsonEncoder encoder = new JsonEncoder.withIndent('  ');

  // encode it to string
  String prettyPrint = encoder.convert(jsonMapped);

  // print or debugPrint your object
  debugPrint(prettyPrint);
}
