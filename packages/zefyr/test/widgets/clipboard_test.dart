// Copyright (c) 2018, the Zefyr project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/src/widgets/clipboard.dart';
import 'package:zefyr/zefyr.dart';

class TestSystemClipboard extends SystemClipboard {
  ClipboardData? data;

  @override
  Future<ClipboardData?> getData() async {
    return data;
  }

  @override
  Future<void> setData(ClipboardData data) async {
    this.data = data;
  }
}

void main() {
  TestSystemClipboard systemClipboard = TestSystemClipboard();

  group('$ZefyrClipboard', () {
    setUp(() {
      zefyrClipboard = ZefyrClipboard(systemClipboard);
    });

    Future<void> copySelection(ZefyrController controller1) async {
      await systemClipboard.setData(ClipboardData(
          text: controller1.selection
              .textInside(controller1.plainTextEditingValue.text)));
      zefyrClipboard.copySelection(controller1);
    }

    test('copy and paste', () async {
      Delta delta = Delta()
        ..insert('Hello ')
        ..insert('World', {'b': true, 'i': true})
        ..insert('!\n');
      var controller1 = ZefyrController(NotusDocument.fromDelta(delta));
      var controller2 = ZefyrController(NotusDocument());

      int len = controller1.document.toPlainText().length;
      var selection = TextSelection(baseOffset: 0, extentOffset: len);
      controller1.updateSelection(selection);

      expect(await zefyrClipboard.hasData(), isFalse);
      await copySelection(controller1);
      expect(await zefyrClipboard.hasData(), isTrue);
      await zefyrClipboard.pasteData(controller2);

      expect(controller1.document.toDelta(),
          equals(controller2.document.toDelta()));
    });

    test('hasData', () async {
      Delta delta = Delta()
        ..insert('Hello ')
        ..insert('World', {'b': true, 'i': true})
        ..insert('!\n');
      var controller1 = ZefyrController(NotusDocument.fromDelta(delta));

      int len = controller1.document.toPlainText().length;
      var selection = TextSelection(baseOffset: 0, extentOffset: len);
      controller1.updateSelection(selection);

      expect(await zefyrClipboard.hasData(), isFalse);
      await copySelection(controller1);
      expect(await zefyrClipboard.hasData(), isTrue);
      await systemClipboard
          .setData(const ClipboardData(text: 'Goodbye World!'));
      expect(await zefyrClipboard.hasData(), isFalse);
    });
  });
}
