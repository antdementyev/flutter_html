import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:flutter_html/html_parser.dart';

class Context<T> {
  T data;

  Context(this.data);
}

// This class is a workaround so that both an image
// and a link can detect taps at the same time.
class MultipleTapGestureRecognizer extends TapGestureRecognizer {
  bool _ready = false;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (state == GestureRecognizerState.ready) {
      _ready = true;
    }
    super.addAllowedPointer(event);
  }

  @override
  void handlePrimaryPointer(PointerEvent event) {
    if (event is PointerCancelEvent) {
      _ready = false;
    }
    super.handlePrimaryPointer(event);
  }

  @override
  void resolve(GestureDisposition disposition) {
    if (_ready && disposition == GestureDisposition.rejected) {
      _ready = false;
    }
    super.resolve(disposition);
  }

  @override
  void rejectGesture(int pointer) {
    if (_ready) {
      acceptGesture(pointer);
      _ready = false;
    }
  }
}

/// This class allows the cursor to change when a link is hovered on web
/// by extending [WidgetSpan] and returning the actual [InlineSpan] of the link
/// within [Text.rich].
class MouseRegionSpan extends WidgetSpan {
  MouseRegionSpan({
    required MouseCursor mouseCursor,
    required InlineSpan inlineSpan,
    required TextStyle childStyle,
    required RenderContext context,
  }) : super(
    child: MouseRegion(
      cursor: mouseCursor,
      child: Text.rich(
        inlineSpan,
        style: context.style.generateTextStyle().merge(
            inlineSpan.style == null
                ? childStyle
                : childStyle.merge(inlineSpan.style))
      ),
    ),
  );
}

/// Gets a string of random length, for use when creating an [IFrameElement] for
/// Flutter Web
String getRandString(int len) {
  var random = Random.secure();
  var values = List<int>.generate(len, (i) =>  random.nextInt(255));
  return base64UrlEncode(values);
}