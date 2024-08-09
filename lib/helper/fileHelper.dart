import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/utility.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// [Delete file] from firebase storage
Future<void> deleteFile(String url, String baseUrl) async {
  try {
    if (url.contains("default")) return;
    var filePath = url.split(".com/o/")[1];
    filePath = filePath.replaceAll(RegExp(r'%2F'), '/');
    filePath = filePath.replaceAll(RegExp(r'(\?alt).*'), '');
    cprint('[Path]' + filePath);
    var storageReference = FirebaseStorage.instance.ref();
    await storageReference.child(filePath).delete().catchError((val) {
      cprint('[Error]' + val);
    }).then((_) {
      cprint('[Success] Image deleted');
    });
  } catch (error) {
    cprint(error, errorIn: 'deleteFile');
  }
}

Future<DataPart> fileToPart(String mimeType, File file) async {
  return DataPart(mimeType, await file.readAsBytes());
}

Widget buildBase64Image(String dataUri, double width, double height) {
  try {
    final bytes = parseBase64Image(dataUri);
    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  } catch (e) {
    // Handle any errors that might occur
    return Icon(Icons.error, size: 50);
  }
}

Uint8List parseBase64Image(String dataUri) {
  // Ensure the string starts with "data:image"
  if (dataUri.startsWith('data:image')) {
    // Extract the Base64 part by splitting the string
    final base64Data = dataUri.split(',').last;
    // Decode the Base64 data to bytes
    return base64Decode(base64Data);
  }
  throw ArgumentError('Invalid data URI');
}
