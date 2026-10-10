/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
} from '@ohos/flutter_ohos';
import { IsEnabledMessage, ToggleMessage, WakelockApi } from './WakelockApi';
import window from '@ohos.window';
import { Context } from '@ohos.abilityAccessCtrl';
import runningLock from '@ohos.runningLock';

/** WakelockPlugin **/
export default class WakelockPlugin extends WakelockApi implements FlutterPlugin, AbilityAware {
  private context: Context | null = null;
  private lock: runningLock.RunningLock | null = null;

  constructor() {
    super();
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.context = binding.getAbility().context;
  }

  onDetachedFromAbility(): void {
    this.lock?.unhold();
    this.lock = null;
    this.context = null;
  }

  async toggle(msg: ToggleMessage): Promise<void> {

    try {
      if (this.context != null) {
        let windowClass = await window.getLastWindow(this.context);
        await windowClass.setWindowKeepScreenOn(msg.getEnable());
      }
    }
    catch (err) {
      console.error('toggle failed, err: ' + err);
    }
  }

  async isEnabled(): Promise<IsEnabledMessage> {
    let isEnabled = false;
    try {
      if (this.context != null) {
        let windowClass = await window.getLastWindow(this.context);
        isEnabled = isEnabled || await windowClass.getWindowProperties().isKeepScreenOn;
      }
      // isEnabled = isEnabled || (this.lock?.isHolding() ?? false);
    }
    catch (err) {
      console.error('toggle failed, err: ' + err);
    }

    return new IsEnabledMessage(isEnabled);
  }

  getUniqueClassName(): string {
    return "WakelockPlugin";
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    WakelockApi.setup(binding.getBinaryMessenger(), this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    WakelockApi.setup(binding.getBinaryMessenger(), null);
  }
}