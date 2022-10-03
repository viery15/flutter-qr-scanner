import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_qr_code_scanner/models/invitation_model.dart';
import 'package:http/http.dart' as http;

Future<Invitation> getInvitation(String id) async {
  // return Invitation(fullname: 'Viery Darmawan', city: 'Surabaya');
  var url = Uri.http('34.101.212.89', '/invitations/$id');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return Invitation.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load invitation');
  }
}

Future<void> uploadPhoto(Uint8List file) async {
  try {
    print('masuk uploadPhoto');
    var url = Uri.http('34.101.212.89', '/invitations/upload');

    final request = http.MultipartRequest('POST', url)
      ..headers['accept'] = 'application/json'
      ..headers['Content-Type'] = 'multipart/form-data';

    request.fields['id'] = '625357038c6a3e15d2dcb99b';
    request.files.add(http.MultipartFile.fromBytes('attachedFile', file,
        filename: '625357038c6a3e15d2dcb99b'));

    print(request);

    await request.send();
  } catch (err) {
    print(err);
  }
}
