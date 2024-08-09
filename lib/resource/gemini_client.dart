import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiClient {
  static final GeminiClient _instance = GeminiClient._internal();
  late final GenerativeModel model;

  factory GeminiClient() {
    return _instance;
  }

  GeminiClient._internal();

  Future<void> initialize() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

    try {
      await remoteConfig.fetchAndActivate();
      final data = remoteConfig.getString('GeminiApiKey');
      final apiKey = jsonDecode(data)["key"];

      // Initialize the model with the server token
      model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
    } catch (e) {
      print("Failed to fetch remote config or initialize model: $e");
    }
  }

  Future generateContent({
    required String prompt,
    dynamic input,
    bool toStream = false,
    DataPart? data,
  }) async {
    List<Content> contentList = [
      Content.text(prompt),
    ];
    if (input != null) {
      contentList.add(Content.text(input));
    } else if (data != null) {
      contentList.add(Content.multi([TextPart(prompt), data]));
    }

    if (toStream) {
      final responses = model.generateContentStream(contentList);
      await for (final response in responses) {
        return response.text;
      }
    }
    final response = await model.generateContent(contentList);
    return response.text;
  }
}
