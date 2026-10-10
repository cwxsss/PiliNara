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
import { NativeOrientation } from './NativeOrientation';
import { OrientationReader } from './OrientationReader';
import { display } from '@kit.ArkUI';
import { Callback } from '@kit.BasicServicesKit';
import { Log } from '@ohos/flutter_ohos';

const TAG: string = "OrientationListener";

export class OrientationListener implements IOrientationListener {
  private reader: OrientationReader | null = null;
  private context: Context | null = null;
  private callback: OrientationCallback | null = null;
  private displayCallback: Callback<display.Orientation> | null = null;
  private lastOrientation: NativeOrientation | null = null;

  constructor(reader: OrientationReader, context: Context, callback: OrientationCallback) {
    this.reader = reader;
    this.context = context;
    this.callback = callback;
  }

  public startOrientationListener(): void {
    if (this.displayCallback != null) {
      return;
    }
    this.displayCallback = (data: display.Orientation) => {
      this.lastOrientation = this.reader?.getOrientation() ?? NativeOrientation.Unknown;
      this.callback?.receive(this.lastOrientation);
    }
    try {
      display.on('change', this.displayCallback);
    } catch (exception) {
      Log.e(TAG, 'Failed to register callback. Code: ' + JSON.stringify(exception));
      this.displayCallback = null
    }
    if (this.reader) {
      this.lastOrientation = this.reader.getOrientation();
    }
    // send initial orientation.
    if (this.lastOrientation) {
      this.callback?.receive(this.lastOrientation);
    }
  }

  public stopOrientationListener(): void {
    if (this.displayCallback == null) {
      return;
    }
    try {
      display.off('change', this.displayCallback);
    } catch (exception) {
      Log.e(TAG, 'Failed to unregister callback. Code: ' + JSON.stringify(exception));
    }
    this.displayCallback = null;
  }
}
