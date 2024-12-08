import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../data/repositories/vocabulary_repository.dart';

class VocabularyService {
  final picker = ImagePicker();
  final Map<String, String> vocabularyMap = {};
  String? geminiResult;
  final VocabularyRepository vocabularyRepository;

  VocabularyService({required this.vocabularyRepository});

  Future<void> processImage({ImageSource source = ImageSource.gallery}) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 100,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    if (image == null) return;

    final result = await sendImageToGemini(image.path);
    if (result != null) {
      print('Gemini Result: $result');
      
      // Parse new words from Gemini
      final Map<String, String> newWords = {};
      final jsonResponse = json.decode(result);
      if (jsonResponse['candidates'] != null && 
          jsonResponse['candidates'].isNotEmpty) {
        final content = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        final jsonString = content.replaceAll('```json\n', '').replaceAll('\n```', '');
        final wordsData = json.decode(jsonString);
        
        if (wordsData['words'] != null) {
          final List<dynamic> words = wordsData['words'];
          for (var word in words) {
            newWords[word['japanese']] = word['meaning'];
          }
        }
      }

      // Merge with existing words
      vocabularyMap.addAll(newWords);
    }
  }

  Future<String?> sendImageToGemini(String imagePath) async {
    final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyADYmcC6kD-J-Sd32eKV-K_NS4ef0fIM8Y');

    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);

    final requestBody = json.encode({
      "contents": [
        {
          "parts": [
            {
              "text": """Analyze the image and extract ALL Japanese vocabulary that appears in it.

For each word:
1. Look for Japanese words written in hiragana (ひらがな) or katakana (カタカナ)
2. Extract their Vietnamese meanings
3. Skip any words containing kanji characters

Return the results in this JSON format:
{
  "words": [
    {
      "japanese": "ひらがな word",
      "meaning": "Vietnamese meaning"
    }
  ]
}

Requirements:
- Process ALL hiragana/katakana words in the image
- Include their exact Vietnamese meanings as shown
- Do not translate to other languages
- Do not add any explanatory text
- Do not skip any valid words"""
            },
            {
              "inline_data": {"mime_type": "image/jpeg", "data": base64Image}
            }
          ]
        }
      ]
    });

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      print('Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  }

  Future<void> saveVocabularies(int folderId) async {
    if (vocabularyMap.isEmpty) return;
    
    // Get existing vocabularies
    final existingVocabs = await getVocabulariesByFolder(folderId);
    
    // Count new words added
    int newWordsCount = 0;
    
    // Only save new words that don't exist in database
    for (var entry in vocabularyMap.entries) {
      if (!existingVocabs.containsKey(entry.key)) {
        await vocabularyRepository.insertVocabulary(
          folderId: folderId,
          japanese: entry.key,
          meaning: entry.value,
        );
        newWordsCount++;
      }
    }
    
    print('New words added: $newWordsCount');
    
    // Update folder word count if new words were added
    if (newWordsCount > 0) {
      await vocabularyRepository.updateFolderWordCount(
        folderId: folderId,
        increment: newWordsCount,
      );
    }
  }

  Future<Map<String, String>> getVocabulariesByFolder(int folderId) async {
    final vocabularies = await vocabularyRepository.getVocabulariesByFolder(folderId);
    
    Map<String, String> result = {};
    for (var vocab in vocabularies) {
      result[vocab['japanese']] = vocab['meaning'];
    }
    return result;
  }
}