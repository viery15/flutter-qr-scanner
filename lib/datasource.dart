import 'dart:convert';

import 'package:flutter_qr_code_scanner/models/invitation_model.dart';
import 'package:http/http.dart' as http;

Future<Invitation> getInvitation(String id) async {
  var url =
      Uri.https('numeric-elixir-197420.et.r.appspot.com', '/invitations/$id');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return Invitation.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load invitation');
  }
}
