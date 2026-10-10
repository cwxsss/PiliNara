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
import { LinkedList } from '@kit.ArkTS';
import { SensorFrequency, SensorOrientationListener } from './SensorOrientationListener';
import { NativeOrientation } from './NativeOrientation';

export class SensorOrientationReader implements OrientationCallback {
  private context: Context | null = null;
  private callbackList: LinkedList<OrientationCallback> = new LinkedList<OrientationCallback>();

  constructor(context: Context) {
    this.context = context;
  }

  private orientationListener: IOrientationListener | null = null;

  getOrientation(callback: OrientationCallback): void {
    // We can't get the orientation of the device directly. We have to listen to the orientation and immediately return the orientation and cancel this listener.
    // if the OrientationListener isn't null, we are already requesting the getSensorOrientation. Firing it multiple times could cause problems.
    this.callbackList.add(callback);
    if (this.orientationListener != null) {
      return;
    }
    if (this.context) {
      this.orientationListener = new SensorOrientationListener(this.context, this, SensorFrequency.ui);
      this.orientationListener.startOrientationListener();
    }
  }

  receive(orientation: NativeOrientation) {
    if (this.orientationListener) {
      this.orientationListener.stopOrientationListener();
      this.orientationListener = null;
    }
    for (let callbackListElement of this.callbackList) {
      callbackListElement.receive(orientation)
    }
    this.callbackList.clear()
  }
}
