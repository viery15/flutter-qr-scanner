import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_qr_code_scanner/models/invitation_model.dart';
import 'package:http/http.dart' as http;

Future<Invitation> getInvitation(String id) async {
  try {
    var url = Uri.https('api.nia-viery.life', '/invitations/$id/attend');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      return Invitation.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  } catch (err) {
    print(err);
    return null;
  }
}

Future<void> uploadPhoto(Uint8List file, String id) async {
  try {
    print('masuk uploadPhoto');
    var url = Uri.https('api.nia-viery.life', '/invitations/upload');

    final request = http.MultipartRequest('POST', url)
      ..headers['accept'] = 'application/json'
      ..headers['Content-Type'] = 'multipart/form-data';

    request.fields['id'] = id;
    request.files
        .add(http.MultipartFile.fromBytes('attachedFile', file, filename: id));

    await request.send();
  } catch (err) {
    print(err);
  }
}
