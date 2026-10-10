/*
* Copyright (c) 2024 SwanLink (Jiangsu) Technology Development Co., LTD.
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
  FlutterPlugin,
  FlutterPluginBinding,
  Log,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult
} from '@ohos/flutter_ohos'
import { common } from '@kit.AbilityKit';
import { EventSink, StreamHandler } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';
import { OrientationReader } from './OrientationReader';
import { SensorOrientationReader } from './SensorOrientationReader';
import { IOrientationListener, OrientationCallback } from './IOrientationListener';
import { NativeOrientation, NativeOrientationName } from './NativeOrientation';
import { SensorOrientationListener } from './SensorOrientationListener';
import { OrientationListener } from './OrientationListener';

const TAG: string = "NativeDeviceOrientationPlugin";
const METHOD_CHANEL: string = "native_device_orientation";
const EVENT_CHANNEL: string = "native_device_orientation_events";

let listener: IOrientationListener | null = null

export default class NativeDeviceOrientationPlugin implements FlutterPlugin, MethodCallHandler {
  private eventChannel: EventChannel | null = null
  private streamHandler: StreamHandler | null = null
  private sensorReader: SensorOrientationReader | null = null
  private reader: OrientationReader | null = null
  private context: common.Context | null = null
  private channel: MethodChannel | null = null

  getUniqueClassName(): string {
    return TAG;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.context = binding.getApplicationContext();
    this.sensorReader = new SensorOrientationReader(this.context);
    this.reader = new OrientationReader(this.context);
    this.streamHandler = new StreamHandlerImpl(this.context);
    this.channel = new MethodChannel(binding.getBinaryMessenger(), METHOD_CHANEL);
    this.channel.setMethodCallHandler(this);
    this.eventChannel = new EventChannel(binding.getBinaryMessenger(), EVENT_CHANNEL);
    this.eventChannel.setStreamHandler(this.streamHandler);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.eventChannel?.setStreamHandler(null);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "getOrientation":
        let useSensor: Boolean = call.argument("useSensor");
        if (useSensor) {
          // we can't immediately retrieve a orientation from the sensor. We have to start listening
          // and return the first orientation retrieved.
          this.sensorReader?.getOrientation(new OrientationCallbackImpl(result))
        } else {
          result.success(NativeOrientation[this.reader?.getOrientation() || NativeOrientation.Unknown]);
        }
        break;
      case "pause":
      // if a listener is currently active, stop listening. The app is going to the background
        if (listener != null) {
          listener.stopOrientationListener();
        }
        result.success(null);
        break;
      case "resume":
      // start listening for orientation changes again. The app is in the foreground.
        if (listener != null) {
          listener.startOrientationListener();
        }
        result.success(null);
        break;
      default:
        result.notImplemented();
    }
  }
}

class OrientationCallbackImpl implements OrientationCallback {
  private result: MethodResult | EventSink | null = null

  constructor(result: MethodResult | EventSink) {
    this.result = result;
  }

  receive(orientation: NativeOrientation) {
    this.result?.success(this.getOrientationName(orientation));
  }

  getOrientationName(orientation: NativeOrientation): string {
    switch (orientation) {
      case NativeOrientation.PortraitUp:
        return NativeOrientationName.PortraitUp
      case NativeOrientation.PortraitDown:
        return NativeOrientationName.PortraitDown
      case NativeOrientation.LandscapeLeft:
        return NativeOrientationName.LandscapeLeft
      case NativeOrientation.LandscapeRight:
        return NativeOrientationName.LandscapeRight
      default:
        return NativeOrientationName.Unknown
    }
  }
}

class StreamHandlerImpl implements StreamHandler {
  private context: common.Context | null = null
  private reader: OrientationReader | null = null

  constructor(context: Context) {
    this.context = context;
    this.reader = new OrientationReader(context);
  }

  onListen(args: Object, events: EventSink): void {
    let useSensor: Boolean = false
    // used hashMap to send parameters to this method. This makes it easier in the future to add new parameters if needed.
    if (args instanceof Map) {
      //noinspection unchecked
      let params: Map<String, Object> = args as Map<String, Object>
      if (params.has("useSensor")) {
        let useSensorNullable: boolean = params.get("useSensor") as boolean
        useSensor = useSensorNullable != null && useSensorNullable;
      }
    }
    // initialize the callback. It is the same for both listeners.
    let callback: OrientationCallback = new OrientationCallbackImpl(events);
    if (useSensor) {
      Log.i("NDOP", "listening using sensor listener");
      if (this.context) {
        listener = new SensorOrientationListener(this.context, callback);
      }
    } else {
      Log.i("NDOP", "listening using window listener");
      if (this.reader && this.context) {
        listener = new OrientationListener(this.reader, this.context, callback);
      }
    }
    listener?.startOrientationListener();
  }

  onCancel(args: Object): void {
    if (listener) {
      listener.stopOrientationListener();
      listener = null;
    }
  }
}