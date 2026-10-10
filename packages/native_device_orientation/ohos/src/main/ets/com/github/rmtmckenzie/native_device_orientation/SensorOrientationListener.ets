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


import { IOrientationListener, OrientationCallback } from './IOrientationListener';
import sensor from '@ohos.sensor';
import { NativeOrientation } from './NativeOrientation';
import display from '@ohos.display';
import { resourceManager } from '@kit.LocalizationKit';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { Surface, Angle } from './Surface';
import { Log } from '@ohos/flutter_ohos';

export enum SensorFrequency {
  normal = 'normal',
  ui = 'ui',
  game = 'game',
  // 无 fastest 模式，目前使用 game
  fastest = 'game'
}

type Rate = number | sensor.SensorFrequency

const TAG: string = "SensorOrientationListener";

export class SensorOrientationListener implements IOrientationListener {
  private context: Context | null = null;
  private callback: OrientationCallback | null = null;
  private nativeValue: Rate = SensorFrequency.normal;
  private orientationEventListener: boolean = false;
  private lastOrientation: NativeOrientation | null = null;
  private orientationCallback: Callback<sensor.OrientationResponse> | null = null;
  private X: number = 0;
  private Y: number = 0;

  constructor(context: Context, callback: OrientationCallback, rate?: Rate) {
    this.context = context;
    this.callback = callback;
    if (rate) {
      this.nativeValue = rate;
    } else {
      this.nativeValue = SensorFrequency.ui;
    }
  }

  startOrientationListener(): void {
    if (this.orientationEventListener && this.lastOrientation) {
      this.callback?.receive(this.lastOrientation);
      return;
    }
    this.orientationCallback = (data: sensor.OrientationResponse) => {
      let newOrientation: NativeOrientation = this.calculateSensorOrientation(data);
      if (newOrientation != this.lastOrientation) {
        this.lastOrientation = newOrientation;
        this.callback?.receive(newOrientation);
      }
    }
    try {
      sensor.on(sensor.SensorId.ORIENTATION, this.orientationCallback, { interval: this.nativeValue });
      this.orientationEventListener = true;
    } catch (error) {
      Log.e(TAG, 'Failed to register callback. Code: ' + JSON.stringify(error));
      this.orientationEventListener = false;
      this.orientationCallback = null;
    }
  }

  stopOrientationListener(): void {
    if (this.orientationCallback == null) {
      return;
    }
    try {
      sensor.off(sensor.SensorId.ORIENTATION, this.orientationCallback);
    } catch (error) {
      Log.e(TAG, 'Failed to unregister callback. Code: ' + JSON.stringify(error));
    }
    this.orientationEventListener = false;
    this.orientationCallback = null;
  }

  calculateSensorOrientation(data: sensor.OrientationResponse): NativeOrientation {
    if (!data) {
      return NativeOrientation.Unknown;
    }
    this.X = data.beta;
    this.Y = data.gamma;
    if ((this.X > Angle.MINUS_135 && this.X < Angle.ZERO) || (this.X >= Angle.ZERO && this.X < Angle.PLUS_45)) {
      if (this.Y <= Angle.PLUS_45 && this.Y >= Angle.MINUS_45) {
        return NativeOrientation.PortraitUp;
      }
      if ((this.Y > Angle.MINUS_135 && this.Y < Angle.ZERO)) {
        return NativeOrientation.LandscapeRight;
      } else {
        return NativeOrientation.LandscapeLeft;
      }
    } else {
      if (this.Y <= Angle.PLUS_45 && this.Y >= Angle.MINUS_45) {
        return NativeOrientation.PortraitDown;
      }
      if ((this.Y > Angle.MINUS_135 && this.Y < Angle.ZERO)) {
        return NativeOrientation.LandscapeRight;
      } else {
        return NativeOrientation.LandscapeLeft;
      }
    }
  }

  getDeviceDefaultOrientation(): number {
    let config: resourceManager.Configuration
    if (this.context) {
      config = this.context.resourceManager.getConfigurationSync()
    } else {
      config = getContext().resourceManager.getConfigurationSync()
    }
    let rotation: number = display.getDefaultDisplaySync().rotation

    if (((rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_180) &&
      config.direction == ConfigurationConstant.Direction.DIRECTION_HORIZONTAL)
      || ((rotation == Surface.ROTATION_90 || rotation == Surface.ROTATION_270) &&
        config.direction == ConfigurationConstant.Direction.DIRECTION_VERTICAL)) {
      return ConfigurationConstant.Direction.DIRECTION_HORIZONTAL;
    } else {
      return ConfigurationConstant.Direction.DIRECTION_VERTICAL;
    }
  }
}
