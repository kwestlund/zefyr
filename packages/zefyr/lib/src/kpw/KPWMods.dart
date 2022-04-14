import 'package:flutter/foundation.dart';
import 'package:zefyr/zefyr.dart';

import 'roman_numerals/RomanNumerals.dart';

String getBulletChar(Node node) {
  if (kIsWeb) return _getWebBulletChar(node);
  int charSet = _getIndent(node) % 6;
  switch (charSet) {
    case 1:
      return '\u2043';
    case 2:
      return '\u2023';
    case 3:
      return '\u25E6';
    case 4:
      return '\u29BF';
    case 5:
      return '\u25D8';
    default:
      return '\u2022';
  }
}

String getOrderedChar(Node node, bool withDot) {
  int index = _getIndex(node);
  int charSet = _getIndent(node) % 3;
  late String ch;
  switch (charSet) {
    case 1:
      ch = String.fromCharCode('a'.codeUnitAt(0) + ((index - 1) % 26));
      break;
    case 2:
      ch = RomanNumerals.toRoman(index).toLowerCase();
      break;
    default:
      ch = '$index';
  }
  return withDot ? '$ch.' : ch;
}

/// The web currently has a bug that won't render the above unicode chars
String _getWebBulletChar(Node node) {
  int charSet = _getIndent(node) % 6;
  switch (charSet) {
    case 1:
      return '-';
    case 2:
      return '*';
    case 3:
      return '~';
    case 4:
      return '^';
    case 5:
      return '=';
    default:
      return '\u2022';
  }
}

int _getIndent(Node node) {
  if (node is LineNode) {
    return node.style
        .get(NotusAttribute.indent)
        ?.value ?? 0;
  }
  return 0;
}

int _getIndex(Node node) {
  ContainerNode? parent = node.parent;
  if (parent != null) {
    Map<int, int> indentIndexMap = {};
    int prevIndent = 0;
    for (Node child in parent.children) {
      if (child is LineNode) {
        int indent = _getIndent(child);
        if (indent > prevIndent) {
          indentIndexMap[indent] = 1;
        } else {
          indentIndexMap[indent] = (indentIndexMap[indent] ?? 0) + 1;
        }
        if (child == node) {
          return indentIndexMap[indent] ?? 0;
        }
        prevIndent = indent;
      }
    }
  }
  return 0;
}
