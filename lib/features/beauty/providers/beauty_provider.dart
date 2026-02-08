import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// API Key loaded from .env file
final String _kGeminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

enum AnalysisStatus { initial, analyzing, done, error }

class BeautyState {
  final List<XFile> challengers;
  final AnalysisStatus status;
  final Map<String, dynamic>? result; // Storing as parsed JSON
  final String? error;

  BeautyState({
    this.challengers = const [],
    this.status = AnalysisStatus.initial,
    this.result,
    this.error,
  });

  BeautyState copyWith({
    List<XFile>? challengers,
    AnalysisStatus? status,
    Map<String, dynamic>? result,
    String? error,
    bool clearResult = false,
  }) {
    return BeautyState(
      challengers: challengers ?? this.challengers,
      status: status ?? this.status,
      result: clearResult ? null : result ?? this.result,
      error: clearResult ? null : error ?? this.error,
    );
  }
}

class BeautyNotifier extends Notifier<BeautyState> {
  @override
  BeautyState build() => BeautyState();

  final ImagePicker _picker = ImagePicker();

  Future<void> addChallenger(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        // Crop the image
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop & Rotate',
              toolbarColor: Colors.black,
              toolbarWidgetColor: const Color(0xFFFFD700),
              lockAspectRatio: false,
              hideBottomControls: false,
            ),
          ],
        );
        
        if (croppedFile != null) {
          state = state.copyWith(
            challengers: [...state.challengers, XFile(croppedFile.path)],
            status: AnalysisStatus.initial,
            clearResult: true,
          );
        }
      }
    } catch (e) {
      // Handle permission errors etc
      state = state.copyWith(error: "Failed to pick image: $e");
    }
  }

  void removeChallenger(int index) {
    if (index >= 0 && index < state.challengers.length) {
      final newImages = [...state.challengers];
      newImages.removeAt(index);
      state = state.copyWith(challengers: newImages, status: AnalysisStatus.initial, clearResult: true);
    }
  }

  void reset() {
    state = BeautyState();
  }

  Future<void> analyzeBeauty() async {
    if (state.challengers.isEmpty) return;
    if (_kGeminiApiKey.isEmpty || _kGeminiApiKey.contains('TODO')) {
       state = state.copyWith(status: AnalysisStatus.error, error: "Missing API Key. Please create a .env file with GEMINI_API_KEY=<KEY>.");
       return;
    }

    state = state.copyWith(status: AnalysisStatus.analyzing, error: null);

    // List of models to try in order of preference
    final modelsToTry = [
       'gemini-2.5-flash',
       'gemini-1.5-flash-latest',
       'gemini-2.0-flash-exp',
    ];

    for (final modelName in modelsToTry) {
      try {
        debugPrint("Attempting analysis with model: $modelName");
        final model = GenerativeModel(
          model: modelName,
          apiKey: _kGeminiApiKey,
          generationConfig: GenerationConfig(
             responseMimeType: 'application/json',
          )
        );

        final prompt = '''
You are a highly sophisticated, funny, and honest AI Beauty Judge.
Compare the beauty of the provided people ("Challengers").

**CRITICAL INSTRUCTIONS**:
1. **RANKING**: You MUST rank them based on beauty. The most beautiful person gets `rank: 1`, the next `rank: 2`, etc.
2. **LANGUAGE**: Use simple, easy-to-understand English. No complex vocabulary. Use cool Gen-Z slang where appropriate.
3. **TERMINOLOGY**: Use the word "**Defects**" for flaws. Be honest but fun.
4. **NICKNAMES**: Give every person a cool, funny, or edgy "nickname" based on their vibe (e.g., "The Slaying Queen", "Mr. Jawline", "Sleepy Panda").
5. **SCORING**: Give a `beauty_score` from 1 to 100 based on their features.
6. **AGE**: Predict their `predicted_age`.
7. **CELEBRITY**: Identify a famous movie actor/actress they resemble (`celeb_name`) from Hollywood or Bollywood.

Return a JSON object with this EXACT structure:
{
  "analyses": [
    {
      "id": 0,
      "nickname": "string",
      "beauty_highlights": "markdown string",
      "defects": "markdown string",
      "cure": "markdown string",
      "vibe_gender": "string",
      "beauty_score": 85, 
      "rank": 1,
      "predicted_age": 25,
      "celeb_name": "string (Actor Name)"
    }
  ],
  "winner_id": 0,
  "winner_title": "string",
  "winner_reason": "markdown string..."
}

Rules:
1. `id` corresponds to the order of images provided (0-indexed).
2. If only one person, they are Rank 1.
''';

        final List<Part> parts = [TextPart(prompt)];
        
        // Load challengers
        for (var img in state.challengers) {
          final bytes = await img.readAsBytes();
          parts.add(DataPart('image/jpeg', bytes));
        }

        final content = [Content.multi(parts)];
        final response = await model.generateContent(content);

        if (response.text == null) {
          throw Exception("AI returned empty response.");
        }
        
        // Clean up JSON if necessary
        String cleanJson = response.text!;
        if (cleanJson.startsWith('```json')) {
          cleanJson = cleanJson.replaceAll('```json', '').replaceAll('```', '');
        }

        final Map<String, dynamic> jsonResult = jsonDecode(cleanJson);

        state = state.copyWith(
          status: AnalysisStatus.done,
          result: jsonResult,
        );
        
        // If successful, return immediately
        return;

      } catch (e) {
        debugPrint("Model $modelName failed: $e");
        // Continue to next model
      }
    }
    
    // If loop finishes without returning, all models failed
    state = state.copyWith(status: AnalysisStatus.error, error: "Analysis failed. Please check your API key and quota.");
  }
}

final beautyProvider = NotifierProvider<BeautyNotifier, BeautyState>(BeautyNotifier.new);
