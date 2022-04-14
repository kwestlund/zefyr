import 'package:flutter/services.dart';
import 'package:notus/notus.dart';
import 'package:quill_delta/quill_delta.dart';

import 'controller.dart';

/// Global zefyr clipboard
ZefyrClipboard zefyrClipboard = ZefyrClipboard(SystemClipboard());

/// ZefyrClipboard keeps the formatting associated with the latest copied
/// section of a zefyr document and provides a way for that data to be pasted
/// back into a zefyr document, which may or may not be the same document.
class ZefyrClipboard {
  final SystemClipboard _systemClipboard;
  Delta? _dataDelta;
  String? _dataText;

  ZefyrClipboard(SystemClipboard systemClipboard)
      : _systemClipboard = systemClipboard;

  /// Copies the current selection from the given document [controller].
  /// The copied data will be overwritten by the next call of this method.
  /// If [system] is true, then text is also copied to the system clipboard.
  void copySelection(ZefyrController controller, {bool system = false}) {
    var selection = controller.selection;
    if (selection.isCollapsed) return;

    _dataDelta = controller.document
        .toDelta()
        .slice(selection.baseOffset, selection.extentOffset);
    _dataText = controller.document
        .toPlainText()
        .substring(selection.baseOffset, selection.extentOffset);

    if (system) {
      _systemClipboard.setData(ClipboardData(text: _dataText));
    }
  }

  /// Pastes the latest copied data to the given document [controller],
  /// overwriting the current selection.
  /// If [system] is true and [hasData] returns false, then text is pasted
  /// from the system clipboard.
  Future<void> pasteData(ZefyrController controller,
      {bool system = false}) async {
    if (await hasData()) {
      return _pasteData(controller, _dataDelta!);
    }
    if (system) {
      final ClipboardData? data = await _systemClipboard.getData();
      if (data != null && data.text != null) {
        _pasteText(controller, data.text!);
      }
    }
  }

  /// Returns true if the plainText version of the latest copied data is equal
  /// to that of the system clipboard text. This can be used to coordinate
  /// pasting from this clipboard with pasting from the system clipboard.
  Future<bool> hasData() async {
    if (_dataText == null) return false;

    final ClipboardData? data = await _systemClipboard.getData();
    if (data == null) return false;

    return _dataText == data.text;
  }

  void _pasteData(ZefyrController controller, Delta delta) {
    var selection = controller.selection;

    Delta changeDelta = Delta()..retain(selection.baseOffset);
    changeDelta = changeDelta.concat(delta);
    changeDelta.delete(selection.extentOffset - selection.baseOffset);

    controller.compose(changeDelta, source: ChangeSource.local);
  }

  void _pasteText(ZefyrController controller, String text) {
    var selection = controller.selection;

    Delta changeDelta = Delta()
      ..retain(selection.baseOffset)
      ..insert(text)
      ..delete(selection.extentOffset - selection.baseOffset);

    controller.compose(changeDelta, source: ChangeSource.local);
  }
}

/// SystemClipboard, which simply wraps the system Clipboard during normal
/// processing, but which enables mocking of the system clipboard during unit
/// testing.
class SystemClipboard {
  Future<ClipboardData?> getData() async {
    return Clipboard.getData(Clipboard.kTextPlain);
  }

  Future<void> setData(ClipboardData data) async {
    return Clipboard.setData(data);
  }
}
