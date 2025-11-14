import 'package:flutter/material.dart';

class TextUtils {
  static List<TextSpan> buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    final matches = <TextSpan>[];
    var start = 0;
    final textLower = text.toLowerCase();
    final queryLower = query.toLowerCase();
    
    while (true) {
      final matchIndex = textLower.indexOf(queryLower, start);
      if (matchIndex == -1) {
        if (start < text.length) {
          matches.add(TextSpan(
            text: text.substring(start),
            style: const TextStyle(color: Colors.black87),
          ));
        }
        break;
      }

      if (matchIndex > start) {
        matches.add(TextSpan(
          text: text.substring(start, matchIndex),
          style: const TextStyle(color: Colors.black87),
        ));
      }

      matches.add(
        TextSpan(
          text: text.substring(matchIndex, matchIndex + query.length),
          style: const TextStyle(
            color: Color(0xFF0B8FAC),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = matchIndex + query.length;
    }

    return matches;
  }
}
