/**
 * This file is a part of media_kit (https://github.com/media-kit/media-kit).
 * <p>
 * Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 * All rights reserved.
 * Use of this source code is governed by MIT license that can be found in the LICENSE file.
 */

import  deviceInfo  from '@ohos.deviceInfo';
import hilog from '@ohos.hilog';

const TAG = 'Utils';
const DOMAIN = 0x1234;


export class Utils {

  static isEmulator(): boolean {
    try {
      const deviceModel = deviceInfo.productModel.toLowerCase();
      
      return deviceModel.includes('sdk') || 
             deviceModel.includes('emulator') || 
             deviceModel.includes('simulator') 
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'isEmulator error: %{public}s', error instanceof Error ? error.message : String(error));
    }
    return false;
  }
}