/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'package:media_kit_video/src/video_controller/video_controller.dart';

/// {@template subtitle_view}
/// SubtitleView
/// ------------
///
/// [SubtitleView] widget is used to display the subtitles on top of the [Video].
class SubtitleView extends StatefulWidget {
  /// The [VideoController] reference to control this [SubtitleView] output.
  final VideoController controller;

  /// The configuration to be used for the subtitles.
  final SubtitleViewConfiguration configuration;

  final bool enableDragSubtitle;

  final ValueChanged<EdgeInsets>? onUpdatePadding;

  /// {@macro subtitle_view}
  const SubtitleView({
    super.key,
    required this.controller,
    required this.configuration,
    this.enableDragSubtitle = false,
    this.onUpdatePadding,
  });

  @override
  SubtitleViewState createState() => SubtitleViewState();
}

class SubtitleViewState extends State<SubtitleView> {
  late Subtitle subtitle = widget.controller.player.state.subtitle;
  late EdgeInsets padding = widget.configuration.padding;
  late Duration duration = const Duration(milliseconds: 100);

  // The [StreamSubscription] to listen to the subtitle changes.
  StreamSubscription<Subtitle>? subscription;

  // The reference width for calculating the visible text scale factor.
  static const kTextScaleFactorReferenceWidth = 1920.0;
  // The reference height for calculating the visible text scale factor.
  static const kTextScaleFactorReferenceHeight = 1080.0;

  @override
  void initState() {
    subscription = widget.controller.player.stream.subtitle.listen((value) {
      setState(() {
        subtitle = value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  /// Sets the padding to be used for the subtitles.
  ///
  /// The [duration] argument may be specified to set the duration of the animation.
  void setPadding(
    EdgeInsets padding, {
    Duration duration = const Duration(milliseconds: 100),
  }) {
    if (this.duration != duration) {
      setState(() {
        this.duration = duration;
      });
    }
    setState(() {
      this.padding = padding;
    });
  }

  @override
  void didUpdateWidget(SubtitleView oldWidget) {
    super.didUpdateWidget(oldWidget);
    padding = widget.configuration.padding;
  }

  /// {@macro subtitle_view}
  @override
  Widget build(BuildContext context) {
    Widget text(String data, TextStyle style) => Text(
          data,
          style: style,
          textAlign: widget.configuration.textAlign,
          textScaler: const TextScaler.linear(1),
        );

    Widget line(String data, TextStyle style, TextStyle? strokeStyle) {
      if (strokeStyle != null) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            text(data, strokeStyle),
            text(data, style),
          ],
        );
      }
      return text(data, style);
    }

    Widget subtitleView() {
      final configuration = widget.configuration;
      final first = subtitle.first;
      final second = subtitle.second;
      if (second.isEmpty) {
        return line(first, configuration.style, configuration.strokeStyle);
      }
      final secondaryStyle =
          configuration.secondaryStyle ?? configuration.style;
      // Fall back to the primary stroke style only when no secondary style
      // is configured at all; an explicitly configured secondary style with
      // a null stroke means "no stroke".
      final secondaryStrokeStyle = configuration.secondaryStyle == null
          ? (configuration.secondaryStrokeStyle ?? configuration.strokeStyle)
          : configuration.secondaryStrokeStyle;
      if (first.isEmpty) {
        return line(second, secondaryStyle, secondaryStrokeStyle);
      }
      // The primary & the secondary subtitles are rendered as two separate
      // [Text]s, so that each can have its own style & background.
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          line(first, configuration.style, configuration.strokeStyle),
          SizedBox(height: configuration.spacing),
          line(second, secondaryStyle, secondaryStrokeStyle),
        ],
      );
    }

    return AnimatedContainer(
      margin: padding,
      duration: duration,
      alignment: Alignment.bottomCenter,
      child: widget.enableDragSubtitle
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (details) {
                double bottom =
                    clampDouble(padding.bottom - details.delta.dy, 0, 200);
                padding = padding.copyWith(bottom: bottom);
                setState(() {});
              },
              onVerticalDragEnd: (details) {
                widget.onUpdatePadding?.call(padding);
              },
              child: subtitleView(),
            )
          : subtitleView(),
    );
  }
}

/// {@template subtitle_view_configuration}
/// SubtitleViewConfiguration
/// -------------------------
///
/// Configurable options for customizing the [SubtitleView] behaviour.
/// {@endtemplate}
class SubtitleViewConfiguration {
  /// Whether the subtitles should be visible or not.
  final bool visible;

  /// The text style to be used for the subtitles.
  final TextStyle style;

  final TextStyle? strokeStyle;

  /// The text style to be used for the secondary subtitle.
  /// Defaults to [style] when null.
  final TextStyle? secondaryStyle;

  /// The stroke style to be used for the secondary subtitle.
  /// Defaults to [strokeStyle] when [secondaryStyle] is null.
  final TextStyle? secondaryStrokeStyle;

  /// The vertical gap between the primary & the secondary subtitle.
  final double spacing;

  /// The text alignment to be used for the subtitles.
  final TextAlign textAlign;

  /// The text scale factor to be used for the subtitles.
  final double? textScaleFactor;

  /// The padding to be used for the subtitles.
  final EdgeInsets padding;

  /// {@macro subtitle_view_configuration}
  const SubtitleViewConfiguration({
    this.visible = true,
    this.style = const TextStyle(
      height: 1.4,
      fontSize: 32.0,
      letterSpacing: 0.0,
      wordSpacing: 0.0,
      color: Color(0xffffffff),
      fontWeight: FontWeight.normal,
      backgroundColor: Color(0xaa000000),
    ),
    this.strokeStyle,
    this.secondaryStyle,
    this.secondaryStrokeStyle,
    this.spacing = 4.0,
    this.textAlign = TextAlign.center,
    this.textScaleFactor,
    this.padding = const EdgeInsets.fromLTRB(
      16.0,
      0.0,
      16.0,
      24.0,
    ),
  });

  SubtitleViewConfiguration copyWith({
    bool? visible,
    TextStyle? style,
    TextStyle? strokeStyle,
    TextStyle? secondaryStyle,
    TextStyle? secondaryStrokeStyle,
    double? spacing,
    TextAlign? textAlign,
    double? textScaleFactor,
    EdgeInsets? padding,
  }) {
    return SubtitleViewConfiguration(
      visible: visible ?? this.visible,
      style: style ?? this.style,
      strokeStyle: strokeStyle ?? this.strokeStyle,
      secondaryStyle: secondaryStyle ?? this.secondaryStyle,
      secondaryStrokeStyle: secondaryStrokeStyle ?? this.secondaryStrokeStyle,
      spacing: spacing ?? this.spacing,
      textAlign: textAlign ?? this.textAlign,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SubtitleViewConfiguration &&
        other.visible == visible &&
        other.style == style &&
        other.strokeStyle == strokeStyle &&
        other.secondaryStyle == secondaryStyle &&
        other.secondaryStrokeStyle == secondaryStrokeStyle &&
        other.spacing == spacing &&
        other.textAlign == textAlign &&
        other.textScaleFactor == textScaleFactor &&
        other.padding == padding;
  }

  @override
  int get hashCode => Object.hash(
      visible,
      style,
      strokeStyle,
      secondaryStyle,
      secondaryStrokeStyle,
      spacing,
      textAlign,
      textScaleFactor,
      padding);
}
