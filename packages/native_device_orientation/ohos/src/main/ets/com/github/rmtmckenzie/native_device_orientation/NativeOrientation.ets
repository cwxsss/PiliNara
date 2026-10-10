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


export enum NativeOrientation {
  PortraitUp,
  PortraitDown,
  LandscapeLeft,
  LandscapeRight,
  Unknown
}

export interface NativeOrientationNameInterface {
  PortraitUp: string,
  PortraitDown: string,
  LandscapeLeft: string,
  LandscapeRight: string,
  Unknown: string
}

export const NativeOrientationName: NativeOrientationNameInterface = {
  PortraitUp: "PortraitUp",
  PortraitDown: "PortraitDown",
  LandscapeLeft: "LandscapeLeft",
  LandscapeRight: "LandscapeRight",
  Unknown: "Unknown"
}
