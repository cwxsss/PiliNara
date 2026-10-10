/*
 * Copyright (C) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import {
  EventChannel,
  EventSink,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
  StreamHandler,
} from '@ohos/flutter_ohos';
import batteryInfo from '@ohos.batteryInfo';
import power from '@ohos.power';
import hilog from '@ohos.hilog';

/** Interval, in milliseconds, at which the charging status is polled. */
const UPDATE_INTERVAL = 200;

/** Domain used for hilog entries emitted by this plugin. */
const HILOG_DOMAIN = 0x000B;

/** Tag used for hilog entries emitted by this plugin. */
const HILOG_TAG = 'BatteryPlusPlugin';

/**
 * Error code reported to the Flutter side when battery information cannot be
 * obtained. Mirrors the `"UNAVAILABLE"` code used by the Android and iOS
 * implementations so that the Dart layer can treat failures uniformly.
 */
const ERROR_CODE_UNAVAILABLE = 'UNAVAILABLE';

/**
 * OHOS implementation of the `battery_plus` Flutter plugin.
 *
 * Surfaces battery level, charging state, and power-save mode over a
 * [MethodChannel], and streams charging-state changes over an [EventChannel].
 *
 * Note: the OHOS `@ohos.batteryInfo` API does not expose a
 * "connected-but-not-charging" state, so this implementation never emits the
 * `"connected_not_charging"` value (that state is documented as available on
 * Android, MacOS and Linux only).
 */
export default class BatteryPlusPlugin implements FlutterPlugin, MethodCallHandler, StreamHandler {
  private METHOD_CHANNEL: string = 'dev.fluttercommunity.plus/battery';
  private EVENT_CHANNEL: string = 'dev.fluttercommunity.plus/charging';
  private methodChannel: MethodChannel | null = null;
  private eventChannel: EventChannel | null = null;
  /** Handle returned by `setInterval`, or `-1` when no timer is active. */
  private timerId: number = -1;
  /** Last charging status pushed through the sink, used to deduplicate events. */
  private lastChargingStatus: string = '';
  /** Active [EventSink] for the charging-state stream, or `null` when idle. */
  private batteryEvents: EventSink | null = null;
  /** Polling callback that pushes charging-state changes to the sink. */
  chargeModeCallback: () => void = (): void => {
    if (this.batteryEvents == null) {
      return;
    }
    try {
      const batteryChargeState: string = this.getChargingStatus();
      if (batteryChargeState != this.lastChargingStatus && this.batteryEvents) {
        this.lastChargingStatus = batteryChargeState;
        this.batteryEvents.success(this.lastChargingStatus);
      }
    } catch (e) {
      const reason: string = e instanceof Error ? (e.message ?? '') : String(e);
      hilog.error(HILOG_DOMAIN, HILOG_TAG, `chargeModeCallback failed: ${reason}`);
      this.batteryEvents?.error(ERROR_CODE_UNAVAILABLE, 'Charging status unavailable', null);
      this.disposeStream();
    }
  };

  constructor() {
  }

  /** Returns a stable name used by the Flutter engine for plugin bookkeeping. */
  getUniqueClassName(): string {
    return 'BatteryPlusPlugin';
  }

  /** Registers the method and event channels when the plugin attaches. */
  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), this.METHOD_CHANNEL);
    this.eventChannel = new EventChannel(binding.getBinaryMessenger(), this.EVENT_CHANNEL);
    this.methodChannel.setMethodCallHandler(this);
    this.eventChannel.setStreamHandler(this);
  }

  /**
   * Releases every resource held by the plugin: the method/event channel
   * handlers, the polling timer, and the active [EventSink]. Safe to call even
   * when no stream is currently active.
   */
  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.methodChannel?.setMethodCallHandler(null);
    this.methodChannel = null;
    this.eventChannel?.setStreamHandler(null);
    this.eventChannel = null;
    this.disposeStream();
  }

  /**
   * Dispatches a method-channel call to the matching battery read, reporting
   * `UNAVAILABLE` (and never throwing) when the underlying value cannot be
   * obtained — matching the Android/iOS contract.
   */
  onMethodCall(call: MethodCall, result: MethodResult): void {
    const callMethod: string = call.method;
    try {
      switch (callMethod) {
        case 'getBatteryLevel': {
          const batteryLevel: number = batteryInfo.batterySOC;
          if (batteryLevel < 0) {
            result.error(ERROR_CODE_UNAVAILABLE, 'Battery level not available.', null);
          } else {
            result.success(batteryLevel);
          }
          break;
        }
        case 'getBatteryState': {
          const chargingStatus: string = this.getChargingStatus();
          if (chargingStatus.length === 0) {
            result.error(ERROR_CODE_UNAVAILABLE, 'Charging status not available.', null);
          } else {
            result.success(chargingStatus);
          }
          break;
        }
        case 'isInBatterySaveMode': {
          // Whether the device is currently in a power-save mode.
          this.getBatteryMode(result);
          break;
        }
        default:
          result.notImplemented();
      }
    } catch (e) {
      const reason: string = e instanceof Error ? (e.message ?? '') : String(e);
      hilog.error(HILOG_DOMAIN, HILOG_TAG, `${callMethod} failed: ${reason}`);
      result.error(ERROR_CODE_UNAVAILABLE, `${callMethod} failed: ${reason}`, null);
    }
  }

  /**
   * Maps the OHOS [batteryInfo.BatteryChargeState] to the string the Dart side's
   * `parseBatteryState` expects. The OHOS API cannot represent the
   * `"connected_not_charging"` state, so it is never produced here.
   */
  getChargingStatus(): string {
    const batteryChargeState: batteryInfo.BatteryChargeState = batteryInfo.chargingStatus;
    let chargingStatusRet: string = 'unknown';
    switch (batteryChargeState) {
      case batteryInfo.BatteryChargeState.NONE:
        chargingStatusRet = 'unknown';
        break;
      case batteryInfo.BatteryChargeState.ENABLE:
        chargingStatusRet = 'charging';
        break;
      case batteryInfo.BatteryChargeState.DISABLE:
        chargingStatusRet = 'discharging';
        break;
      case batteryInfo.BatteryChargeState.FULL:
        chargingStatusRet = 'full';
        break;
      default:
        // Fall back to a value the Dart layer can parse instead of an empty
        // string, which `parseBatteryState` would reject with an ArgumentError.
        chargingStatusRet = 'unknown';
        break;
    }
    return chargingStatusRet;
  }

  /** Resolves `result` with `true` when the device is in a power-save mode. */
  getBatteryMode(result: MethodResult): void {
    const powerMode: power.DevicePowerMode = power.getPowerMode();
    if (powerMode === power.DevicePowerMode.MODE_POWER_SAVE ||
      powerMode === power.DevicePowerMode.MODE_EXTREME_POWER_SAVE) {
      result.success(true);
    } else {
      result.success(false);
    }
  }

  /**
   * Called when the Flutter side subscribes to the charging-state stream.
   * Clears any previously active timer (so repeated listens never leak timers),
   * stores the sink, pushes the current state immediately, and starts polling.
   */
  onListen(args: ESObject, events: EventSink): void {
    // Stop any timer left from a prior subscription before starting a new one.
    this.disposeStream();
    this.batteryEvents = events;
    // Emit the current state right away so listeners don't wait for the first tick.
    const currentStatus: string = this.getChargingStatus();
    if (currentStatus.length > 0) {
      this.lastChargingStatus = currentStatus;
      events.success(currentStatus);
    }
    this.timerId = setInterval(this.chargeModeCallback, UPDATE_INTERVAL);
  }

  /**
   * Called when the Flutter side cancels the charging-state stream. Tears down
   * the timer and releases the [EventSink].
   */
  onCancel(args: ESObject): void {
    this.disposeStream();
  }

  /**
   * Shared teardown for the charging-state stream: stops the polling timer,
   * drops the [EventSink] reference, and resets the deduplication state.
   * Used by both [onCancel] and [onDetachedFromEngine].
   */
  private disposeStream(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.batteryEvents = null;
    this.lastChargingStatus = '';
  }
}
