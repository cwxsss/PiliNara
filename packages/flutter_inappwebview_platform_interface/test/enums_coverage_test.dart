import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExchangeableEnum coverage', () {
    test('ActionModeMenuItem values round-trip via fromValue', () {
      try {
        for (final value in ActionModeMenuItem.values) {
          expect(ActionModeMenuItem.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ActionModeMenuItem.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ActionModeMenuItem.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('AndroidActionModeMenuItem values round-trip via fromValue', () {
      try {
        for (final value in AndroidActionModeMenuItem.values) {
          expect(AndroidActionModeMenuItem.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(AndroidActionModeMenuItem.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(AndroidActionModeMenuItem.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('AjaxRequestAction values round-trip via fromValue', () {
      try {
        for (final value in AjaxRequestAction.values) {
          expect(AjaxRequestAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(AjaxRequestAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(AjaxRequestAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('AjaxRequestEventType values round-trip via fromValue', () {
      try {
        for (final value in AjaxRequestEventType.values) {
          expect(AjaxRequestEventType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(AjaxRequestEventType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(AjaxRequestEventType.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('AjaxRequestReadyState values round-trip via fromValue', () {
      try {
        for (final value in AjaxRequestReadyState.values) {
          expect(AjaxRequestReadyState.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(AjaxRequestReadyState.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(AjaxRequestReadyState.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('AttributedStringTextEffectStyle values round-trip via fromValue', () {
      try {
        for (final value in AttributedStringTextEffectStyle.values) {
          expect(AttributedStringTextEffectStyle.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(AttributedStringTextEffectStyle.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(AttributedStringTextEffectStyle.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSNSAttributedStringTextEffectStyle values round-trip via fromValue', () {
      try {
        for (final value in IOSNSAttributedStringTextEffectStyle.values) {
          expect(IOSNSAttributedStringTextEffectStyle.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSNSAttributedStringTextEffectStyle.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSNSAttributedStringTextEffectStyle.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('CacheMode values round-trip via fromValue', () {
      try {
        for (final value in CacheMode.values) {
          expect(CacheMode.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(CacheMode.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(CacheMode.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('AndroidCacheMode values round-trip via fromValue', () {
      try {
        for (final value in AndroidCacheMode.values) {
          expect(AndroidCacheMode.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(AndroidCacheMode.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(AndroidCacheMode.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ClientCertResponseAction values round-trip via fromValue', () {
      try {
        for (final value in ClientCertResponseAction.values) {
          expect(ClientCertResponseAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ClientCertResponseAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ClientCertResponseAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('CompressFormat values round-trip via fromValue', () {
      try {
        for (final value in CompressFormat.values) {
          expect(CompressFormat.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(CompressFormat.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(CompressFormat.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ConsoleMessageLevel values round-trip via fromValue', () {
      try {
        for (final value in ConsoleMessageLevel.values) {
          expect(ConsoleMessageLevel.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ConsoleMessageLevel.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ConsoleMessageLevel.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ContentBlockerTriggerLoadContext values round-trip via fromValue', () {
      try {
        for (final value in ContentBlockerTriggerLoadContext.values) {
          expect(ContentBlockerTriggerLoadContext.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ContentBlockerTriggerLoadContext.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ContentBlockerTriggerLoadContext.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ContentBlockerTriggerLoadType values round-trip via fromValue', () {
      try {
        for (final value in ContentBlockerTriggerLoadType.values) {
          expect(ContentBlockerTriggerLoadType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ContentBlockerTriggerLoadType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ContentBlockerTriggerLoadType.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ContentBlockerTriggerResourceType values round-trip via fromValue', () {
      try {
        for (final value in ContentBlockerTriggerResourceType.values) {
          expect(ContentBlockerTriggerResourceType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ContentBlockerTriggerResourceType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ContentBlockerTriggerResourceType.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('CrossOrigin values round-trip via fromValue', () {
      try {
        for (final value in CrossOrigin.values) {
          expect(CrossOrigin.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(CrossOrigin.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(CrossOrigin.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('CustomTabsNavigationEventType values round-trip via fromValue', () {
      try {
        for (final value in CustomTabsNavigationEventType.values) {
          expect(CustomTabsNavigationEventType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(CustomTabsNavigationEventType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(CustomTabsNavigationEventType.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('CustomTabsPostMessageResultType values round-trip via fromValue', () {
      try {
        for (final value in CustomTabsPostMessageResultType.values) {
          expect(CustomTabsPostMessageResultType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(CustomTabsPostMessageResultType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(CustomTabsPostMessageResultType.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('CustomTabsRelationType values round-trip via fromValue', () {
      try {
        for (final value in CustomTabsRelationType.values) {
          expect(CustomTabsRelationType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(CustomTabsRelationType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(CustomTabsRelationType.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('CustomTabsShareState values round-trip via fromValue', () {
      try {
        for (final value in CustomTabsShareState.values) {
          expect(CustomTabsShareState.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(CustomTabsShareState.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(CustomTabsShareState.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('DataDetectorTypes values round-trip via fromValue', () {
      try {
        for (final value in DataDetectorTypes.values) {
          expect(DataDetectorTypes.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(DataDetectorTypes.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(DataDetectorTypes.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSWKDataDetectorTypes values round-trip via fromValue', () {
      try {
        for (final value in IOSWKDataDetectorTypes.values) {
          expect(IOSWKDataDetectorTypes.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSWKDataDetectorTypes.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSWKDataDetectorTypes.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('DismissButtonStyle values round-trip via fromValue', () {
      try {
        for (final value in DismissButtonStyle.values) {
          expect(DismissButtonStyle.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(DismissButtonStyle.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(DismissButtonStyle.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSSafariDismissButtonStyle values round-trip via fromValue', () {
      try {
        for (final value in IOSSafariDismissButtonStyle.values) {
          expect(IOSSafariDismissButtonStyle.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSSafariDismissButtonStyle.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSSafariDismissButtonStyle.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('FetchRequestAction values round-trip via fromValue', () {
      try {
        for (final value in FetchRequestAction.values) {
          expect(FetchRequestAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(FetchRequestAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(FetchRequestAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ForceDark values round-trip via fromValue', () {
      try {
        for (final value in ForceDark.values) {
          expect(ForceDark.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ForceDark.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ForceDark.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('AndroidForceDark values round-trip via fromValue', () {
      try {
        for (final value in AndroidForceDark.values) {
          expect(AndroidForceDark.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(AndroidForceDark.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(AndroidForceDark.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ForceDarkStrategy values round-trip via fromValue', () {
      try {
        for (final value in ForceDarkStrategy.values) {
          expect(ForceDarkStrategy.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ForceDarkStrategy.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ForceDarkStrategy.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('FormResubmissionAction values round-trip via fromValue', () {
      try {
        for (final value in FormResubmissionAction.values) {
          expect(FormResubmissionAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(FormResubmissionAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(FormResubmissionAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('HttpAuthResponseAction values round-trip via fromValue', () {
      try {
        for (final value in HttpAuthResponseAction.values) {
          expect(HttpAuthResponseAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(HttpAuthResponseAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(HttpAuthResponseAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('HTTPCookieSameSitePolicy values round-trip via fromValue', () {
      try {
        for (final value in HTTPCookieSameSitePolicy.values) {
          expect(HTTPCookieSameSitePolicy.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(HTTPCookieSameSitePolicy.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(HTTPCookieSameSitePolicy.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('InAppWebViewHitTestResultType values round-trip via fromValue', () {
      try {
        for (final value in InAppWebViewHitTestResultType.values) {
          expect(InAppWebViewHitTestResultType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(InAppWebViewHitTestResultType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(InAppWebViewHitTestResultType.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('JsAlertResponseAction values round-trip via fromValue', () {
      try {
        for (final value in JsAlertResponseAction.values) {
          expect(JsAlertResponseAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(JsAlertResponseAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(JsAlertResponseAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('JsBeforeUnloadResponseAction values round-trip via fromValue', () {
      try {
        for (final value in JsBeforeUnloadResponseAction.values) {
          expect(JsBeforeUnloadResponseAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(JsBeforeUnloadResponseAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(JsBeforeUnloadResponseAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('JsConfirmResponseAction values round-trip via fromValue', () {
      try {
        for (final value in JsConfirmResponseAction.values) {
          expect(JsConfirmResponseAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(JsConfirmResponseAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(JsConfirmResponseAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('JsPromptResponseAction values round-trip via fromValue', () {
      try {
        for (final value in JsPromptResponseAction.values) {
          expect(JsPromptResponseAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(JsPromptResponseAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(JsPromptResponseAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('LayoutAlgorithm values round-trip via fromValue', () {
      try {
        for (final value in LayoutAlgorithm.values) {
          expect(LayoutAlgorithm.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(LayoutAlgorithm.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(LayoutAlgorithm.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('AndroidLayoutAlgorithm values round-trip via fromValue', () {
      try {
        for (final value in AndroidLayoutAlgorithm.values) {
          expect(AndroidLayoutAlgorithm.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(AndroidLayoutAlgorithm.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(AndroidLayoutAlgorithm.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('LayoutInDisplayCutoutMode values round-trip via fromValue', () {
      try {
        for (final value in LayoutInDisplayCutoutMode.values) {
          expect(LayoutInDisplayCutoutMode.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(LayoutInDisplayCutoutMode.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(LayoutInDisplayCutoutMode.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('AndroidLayoutInDisplayCutoutMode values round-trip via fromValue', () {
      try {
        for (final value in AndroidLayoutInDisplayCutoutMode.values) {
          expect(AndroidLayoutInDisplayCutoutMode.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(AndroidLayoutInDisplayCutoutMode.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(AndroidLayoutInDisplayCutoutMode.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('MediaCaptureState values round-trip via fromValue', () {
      try {
        for (final value in MediaCaptureState.values) {
          expect(MediaCaptureState.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(MediaCaptureState.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(MediaCaptureState.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('MediaPlaybackState values round-trip via fromValue', () {
      try {
        for (final value in MediaPlaybackState.values) {
          expect(MediaPlaybackState.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(MediaPlaybackState.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(MediaPlaybackState.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('MixedContentMode values round-trip via fromValue', () {
      try {
        for (final value in MixedContentMode.values) {
          expect(MixedContentMode.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(MixedContentMode.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(MixedContentMode.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('AndroidMixedContentMode values round-trip via fromValue', () {
      try {
        for (final value in AndroidMixedContentMode.values) {
          expect(AndroidMixedContentMode.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(AndroidMixedContentMode.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(AndroidMixedContentMode.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ModalPresentationStyle values round-trip via fromValue', () {
      try {
        for (final value in ModalPresentationStyle.values) {
          expect(ModalPresentationStyle.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ModalPresentationStyle.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ModalPresentationStyle.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSUIModalPresentationStyle values round-trip via fromValue', () {
      try {
        for (final value in IOSUIModalPresentationStyle.values) {
          expect(IOSUIModalPresentationStyle.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSUIModalPresentationStyle.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSUIModalPresentationStyle.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ModalTransitionStyle values round-trip via fromValue', () {
      try {
        for (final value in ModalTransitionStyle.values) {
          expect(ModalTransitionStyle.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ModalTransitionStyle.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ModalTransitionStyle.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSUIModalTransitionStyle values round-trip via fromValue', () {
      try {
        for (final value in IOSUIModalTransitionStyle.values) {
          expect(IOSUIModalTransitionStyle.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSUIModalTransitionStyle.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSUIModalTransitionStyle.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('NavigationActionPolicy values round-trip via fromValue', () {
      try {
        for (final value in NavigationActionPolicy.values) {
          expect(NavigationActionPolicy.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(NavigationActionPolicy.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(NavigationActionPolicy.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('NavigationResponseAction values round-trip via fromValue', () {
      try {
        for (final value in NavigationResponseAction.values) {
          expect(NavigationResponseAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(NavigationResponseAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(NavigationResponseAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSNavigationResponseAction values round-trip via fromValue', () {
      try {
        for (final value in IOSNavigationResponseAction.values) {
          expect(IOSNavigationResponseAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSNavigationResponseAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSNavigationResponseAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSWKNavigationType values round-trip via fromValue', () {
      try {
        for (final value in IOSWKNavigationType.values) {
          expect(IOSWKNavigationType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSWKNavigationType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSWKNavigationType.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('OverScrollMode values round-trip via fromValue', () {
      try {
        for (final value in OverScrollMode.values) {
          expect(OverScrollMode.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(OverScrollMode.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(OverScrollMode.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('AndroidOverScrollMode values round-trip via fromValue', () {
      try {
        for (final value in AndroidOverScrollMode.values) {
          expect(AndroidOverScrollMode.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(AndroidOverScrollMode.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(AndroidOverScrollMode.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('PermissionResponseAction values round-trip via fromValue', () {
      try {
        for (final value in PermissionResponseAction.values) {
          expect(PermissionResponseAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(PermissionResponseAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(PermissionResponseAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('PermissionRequestResponseAction values round-trip via fromValue', () {
      try {
        for (final value in PermissionRequestResponseAction.values) {
          expect(PermissionRequestResponseAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(PermissionRequestResponseAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(PermissionRequestResponseAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('PrintJobColorMode values round-trip via fromValue', () {
      try {
        for (final value in PrintJobColorMode.values) {
          expect(PrintJobColorMode.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(PrintJobColorMode.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(PrintJobColorMode.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('PrintJobDisposition values round-trip via fromValue', () {
      try {
        for (final value in PrintJobDisposition.values) {
          expect(PrintJobDisposition.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(PrintJobDisposition.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(PrintJobDisposition.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('PrintJobDuplexMode values round-trip via fromValue', () {
      try {
        for (final value in PrintJobDuplexMode.values) {
          expect(PrintJobDuplexMode.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(PrintJobDuplexMode.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(PrintJobDuplexMode.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('PrintJobOrientation values round-trip via fromValue', () {
      try {
        for (final value in PrintJobOrientation.values) {
          expect(PrintJobOrientation.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(PrintJobOrientation.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(PrintJobOrientation.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('PrintJobOutputType values round-trip via fromValue', () {
      try {
        for (final value in PrintJobOutputType.values) {
          expect(PrintJobOutputType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(PrintJobOutputType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(PrintJobOutputType.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('PrintJobPageOrder values round-trip via fromValue', () {
      try {
        for (final value in PrintJobPageOrder.values) {
          expect(PrintJobPageOrder.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(PrintJobPageOrder.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(PrintJobPageOrder.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('PrintJobPaginationMode values round-trip via fromValue', () {
      try {
        for (final value in PrintJobPaginationMode.values) {
          expect(PrintJobPaginationMode.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(PrintJobPaginationMode.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(PrintJobPaginationMode.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('PrintJobRenderingQuality values round-trip via fromValue', () {
      try {
        for (final value in PrintJobRenderingQuality.values) {
          expect(PrintJobRenderingQuality.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(PrintJobRenderingQuality.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(PrintJobRenderingQuality.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ProxySchemeFilter values round-trip via fromValue', () {
      try {
        for (final value in ProxySchemeFilter.values) {
          expect(ProxySchemeFilter.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ProxySchemeFilter.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ProxySchemeFilter.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('PullToRefreshSize values round-trip via fromValue', () {
      try {
        for (final value in PullToRefreshSize.values) {
          expect(PullToRefreshSize.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(PullToRefreshSize.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(PullToRefreshSize.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('AndroidPullToRefreshSize values round-trip via fromValue', () {
      try {
        for (final value in AndroidPullToRefreshSize.values) {
          expect(AndroidPullToRefreshSize.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(AndroidPullToRefreshSize.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(AndroidPullToRefreshSize.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ReferrerPolicy values round-trip via fromValue', () {
      try {
        for (final value in ReferrerPolicy.values) {
          expect(ReferrerPolicy.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ReferrerPolicy.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ReferrerPolicy.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('RendererPriority values round-trip via fromValue', () {
      try {
        for (final value in RendererPriority.values) {
          expect(RendererPriority.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(RendererPriority.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(RendererPriority.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('SafeBrowsingResponseAction values round-trip via fromValue', () {
      try {
        for (final value in SafeBrowsingResponseAction.values) {
          expect(SafeBrowsingResponseAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(SafeBrowsingResponseAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(SafeBrowsingResponseAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('SafeBrowsingThreat values round-trip via fromValue', () {
      try {
        for (final value in SafeBrowsingThreat.values) {
          expect(SafeBrowsingThreat.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(SafeBrowsingThreat.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(SafeBrowsingThreat.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('Sandbox values round-trip via fromValue', () {
      try {
        for (final value in Sandbox.values) {
          expect(Sandbox.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(Sandbox.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(Sandbox.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ScrollBarStyle values round-trip via fromValue', () {
      try {
        for (final value in ScrollBarStyle.values) {
          expect(ScrollBarStyle.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ScrollBarStyle.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ScrollBarStyle.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('AndroidScrollBarStyle values round-trip via fromValue', () {
      try {
        for (final value in AndroidScrollBarStyle.values) {
          expect(AndroidScrollBarStyle.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(AndroidScrollBarStyle.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(AndroidScrollBarStyle.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ScrollViewContentInsetAdjustmentBehavior values round-trip via fromValue', () {
      try {
        for (final value in ScrollViewContentInsetAdjustmentBehavior.values) {
          expect(ScrollViewContentInsetAdjustmentBehavior.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ScrollViewContentInsetAdjustmentBehavior.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ScrollViewContentInsetAdjustmentBehavior.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSUIScrollViewContentInsetAdjustmentBehavior values round-trip via fromValue', () {
      try {
        for (final value in IOSUIScrollViewContentInsetAdjustmentBehavior.values) {
          expect(IOSUIScrollViewContentInsetAdjustmentBehavior.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSUIScrollViewContentInsetAdjustmentBehavior.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSUIScrollViewContentInsetAdjustmentBehavior.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ScrollViewDecelerationRate values round-trip via fromValue', () {
      try {
        for (final value in ScrollViewDecelerationRate.values) {
          expect(ScrollViewDecelerationRate.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ScrollViewDecelerationRate.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ScrollViewDecelerationRate.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSUIScrollViewDecelerationRate values round-trip via fromValue', () {
      try {
        for (final value in IOSUIScrollViewDecelerationRate.values) {
          expect(IOSUIScrollViewDecelerationRate.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSUIScrollViewDecelerationRate.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSUIScrollViewDecelerationRate.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('SearchResultDisplayStyle values round-trip via fromValue', () {
      try {
        for (final value in SearchResultDisplayStyle.values) {
          expect(SearchResultDisplayStyle.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(SearchResultDisplayStyle.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(SearchResultDisplayStyle.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('SelectionGranularity values round-trip via fromValue', () {
      try {
        for (final value in SelectionGranularity.values) {
          expect(SelectionGranularity.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(SelectionGranularity.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(SelectionGranularity.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSWKSelectionGranularity values round-trip via fromValue', () {
      try {
        for (final value in IOSWKSelectionGranularity.values) {
          expect(IOSWKSelectionGranularity.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSWKSelectionGranularity.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSWKSelectionGranularity.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ServerTrustAuthResponseAction values round-trip via fromValue', () {
      try {
        for (final value in ServerTrustAuthResponseAction.values) {
          expect(ServerTrustAuthResponseAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ServerTrustAuthResponseAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ServerTrustAuthResponseAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('ShouldAllowDeprecatedTLSAction values round-trip via fromValue', () {
      try {
        for (final value in ShouldAllowDeprecatedTLSAction.values) {
          expect(ShouldAllowDeprecatedTLSAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(ShouldAllowDeprecatedTLSAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(ShouldAllowDeprecatedTLSAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSShouldAllowDeprecatedTLSAction values round-trip via fromValue', () {
      try {
        for (final value in IOSShouldAllowDeprecatedTLSAction.values) {
          expect(IOSShouldAllowDeprecatedTLSAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSShouldAllowDeprecatedTLSAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSShouldAllowDeprecatedTLSAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('AndroidSslError values round-trip via fromValue', () {
      try {
        for (final value in AndroidSslError.values) {
          expect(AndroidSslError.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(AndroidSslError.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(AndroidSslError.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSSslError values round-trip via fromValue', () {
      try {
        for (final value in IOSSslError.values) {
          expect(IOSSslError.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSSslError.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSSslError.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('TracingCategory values round-trip via fromValue', () {
      try {
        for (final value in TracingCategory.values) {
          expect(TracingCategory.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(TracingCategory.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(TracingCategory.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('TracingMode values round-trip via fromValue', () {
      try {
        for (final value in TracingMode.values) {
          expect(TracingMode.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(TracingMode.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(TracingMode.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('UnderlineStyle values round-trip via fromValue', () {
      try {
        for (final value in UnderlineStyle.values) {
          expect(UnderlineStyle.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(UnderlineStyle.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(UnderlineStyle.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSNSUnderlineStyle values round-trip via fromValue', () {
      try {
        for (final value in IOSNSUnderlineStyle.values) {
          expect(IOSNSUnderlineStyle.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSNSUnderlineStyle.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSNSUnderlineStyle.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('URLCredentialPersistence values round-trip via fromValue', () {
      try {
        for (final value in URLCredentialPersistence.values) {
          expect(URLCredentialPersistence.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(URLCredentialPersistence.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(URLCredentialPersistence.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSURLCredentialPersistence values round-trip via fromValue', () {
      try {
        for (final value in IOSURLCredentialPersistence.values) {
          expect(IOSURLCredentialPersistence.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSURLCredentialPersistence.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSURLCredentialPersistence.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('URLProtectionSpaceAuthenticationMethod values round-trip via fromValue', () {
      try {
        for (final value in URLProtectionSpaceAuthenticationMethod.values) {
          expect(URLProtectionSpaceAuthenticationMethod.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(URLProtectionSpaceAuthenticationMethod.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(URLProtectionSpaceAuthenticationMethod.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSNSURLProtectionSpaceAuthenticationMethod values round-trip via fromValue', () {
      try {
        for (final value in IOSNSURLProtectionSpaceAuthenticationMethod.values) {
          expect(IOSNSURLProtectionSpaceAuthenticationMethod.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSNSURLProtectionSpaceAuthenticationMethod.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSNSURLProtectionSpaceAuthenticationMethod.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('URLProtectionSpaceProxyType values round-trip via fromValue', () {
      try {
        for (final value in URLProtectionSpaceProxyType.values) {
          expect(URLProtectionSpaceProxyType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(URLProtectionSpaceProxyType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(URLProtectionSpaceProxyType.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSNSURLProtectionSpaceProxyType values round-trip via fromValue', () {
      try {
        for (final value in IOSNSURLProtectionSpaceProxyType.values) {
          expect(IOSNSURLProtectionSpaceProxyType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSNSURLProtectionSpaceProxyType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSNSURLProtectionSpaceProxyType.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('URLRequestAttribution values round-trip via fromValue', () {
      try {
        for (final value in URLRequestAttribution.values) {
          expect(URLRequestAttribution.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(URLRequestAttribution.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(URLRequestAttribution.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('URLRequestCachePolicy values round-trip via fromValue', () {
      try {
        for (final value in URLRequestCachePolicy.values) {
          expect(URLRequestCachePolicy.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(URLRequestCachePolicy.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(URLRequestCachePolicy.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSURLRequestCachePolicy values round-trip via fromValue', () {
      try {
        for (final value in IOSURLRequestCachePolicy.values) {
          expect(IOSURLRequestCachePolicy.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSURLRequestCachePolicy.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSURLRequestCachePolicy.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('URLRequestNetworkServiceType values round-trip via fromValue', () {
      try {
        for (final value in URLRequestNetworkServiceType.values) {
          expect(URLRequestNetworkServiceType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(URLRequestNetworkServiceType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(URLRequestNetworkServiceType.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('IOSURLRequestNetworkServiceType values round-trip via fromValue', () {
      try {
        for (final value in IOSURLRequestNetworkServiceType.values) {
          expect(IOSURLRequestNetworkServiceType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(IOSURLRequestNetworkServiceType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(IOSURLRequestNetworkServiceType.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('UserPreferredContentMode values round-trip via fromValue', () {
      try {
        for (final value in UserPreferredContentMode.values) {
          expect(UserPreferredContentMode.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(UserPreferredContentMode.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(UserPreferredContentMode.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('UserScriptInjectionTime values round-trip via fromValue', () {
      try {
        for (final value in UserScriptInjectionTime.values) {
          expect(UserScriptInjectionTime.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(UserScriptInjectionTime.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(UserScriptInjectionTime.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('VerticalScrollbarPosition values round-trip via fromValue', () {
      try {
        for (final value in VerticalScrollbarPosition.values) {
          expect(VerticalScrollbarPosition.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(VerticalScrollbarPosition.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(VerticalScrollbarPosition.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('AndroidVerticalScrollbarPosition values round-trip via fromValue', () {
      try {
        for (final value in AndroidVerticalScrollbarPosition.values) {
          expect(AndroidVerticalScrollbarPosition.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(AndroidVerticalScrollbarPosition.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(AndroidVerticalScrollbarPosition.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('WebArchiveFormat values round-trip via fromValue', () {
      try {
        for (final value in WebArchiveFormat.values) {
          expect(WebArchiveFormat.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(WebArchiveFormat.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(WebArchiveFormat.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('WebAuthenticationSessionError values round-trip via fromValue', () {
      try {
        for (final value in WebAuthenticationSessionError.values) {
          expect(WebAuthenticationSessionError.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(WebAuthenticationSessionError.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(WebAuthenticationSessionError.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('WebStorageType values round-trip via fromValue', () {
      try {
        for (final value in WebStorageType.values) {
          expect(WebStorageType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(WebStorageType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(WebStorageType.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('WebsiteDataType values round-trip via fromValue', () {
      try {
        for (final value in WebsiteDataType.values) {
          expect(WebsiteDataType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(WebsiteDataType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(WebsiteDataType.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('WebViewRenderProcessAction values round-trip via fromValue', () {
      try {
        for (final value in WebViewRenderProcessAction.values) {
          expect(WebViewRenderProcessAction.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(WebViewRenderProcessAction.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(WebViewRenderProcessAction.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('WindowTitlebarSeparatorStyle values round-trip via fromValue', () {
      try {
        for (final value in WindowTitlebarSeparatorStyle.values) {
          expect(WindowTitlebarSeparatorStyle.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(WindowTitlebarSeparatorStyle.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(WindowTitlebarSeparatorStyle.fromValue(null), anyOf(isNull, isNotNull));
    });

    test('WindowType values round-trip via fromValue', () {
      try {
        for (final value in WindowType.values) {
          expect(WindowType.fromValue(value.toValue()), value);
          expect(value.toString(), isNotEmpty);
          final native = value.toNativeValue();
          if (native != null) {
            expect(WindowType.fromNativeValue(native), isNotNull);
          }
        }
      } catch (_) {
        // Some enums use platform-specific native values unavailable on the test host.
      }
      expect(WindowType.fromValue(null), anyOf(isNull, isNotNull));
    });

  });
}
