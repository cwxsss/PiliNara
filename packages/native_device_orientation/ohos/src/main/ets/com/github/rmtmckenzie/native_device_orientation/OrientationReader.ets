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


import { NativeOrientation } from './NativeOrientation';
import { display } from '@kit.ArkUI';
import { Log } from '@ohos/flutter_ohos';

export class OrientationReader {
  private context: Context | null = null;

  constructor(context: Context) {
    this.context = context;
  }

  getOrientation(): NativeOrientation {
    let orientation: display.Orientation | null
    try {
      orientation = display.getDefaultDisplaySync().orientation
    } catch (exception) {
      Log.e("OrientationReader", 'Failed to obtain the default display object. Code: ' + JSON.stringify(exception));
      orientation = null
    }
    let returnOrientation: NativeOrientation
    switch (orientation) {
      case display.Orientation.PORTRAIT:
        returnOrientation = NativeOrientation.PortraitUp;
        break;
      case display.Orientation.LANDSCAPE:
        returnOrientation = NativeOrientation.LandscapeRight;
        break;
      case display.Orientation.PORTRAIT_INVERTED:
        returnOrientation = NativeOrientation.PortraitDown;
        break;
      case display.Orientation.LANDSCAPE_INVERTED:
        returnOrientation = NativeOrientation.LandscapeLeft;
        break;
      default:
        returnOrientation = NativeOrientation.Unknown;
        break;
    }
    return returnOrientation;
  }
}
