// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System.Collections.Generic;

namespace VRDitherExample
{
    public static class DitherInfoConstant
    {
        public static IReadOnlyList<DitherInfo> DitherInfoList { get; } = new List<DitherInfo>
        {
            new DitherInfo(name: "None", keyword: "_DITHERTYPE_NONE"),
            new DitherInfo(name: "DitherMaskLOD", keyword: "_DITHERTYPE_DITHERMASKLOD"),
            new DitherInfo(name: "DitherArray4x4", keyword: "_DITHERTYPE_PSEUDORANDOM"),
            new DitherInfo(name: "GradientNoise", keyword: "_DITHERTYPE_GRADIENTNOISE"),
            new DitherInfo(name: "BlueNoise16x16", keyword: "_DITHERTYPE_BLUENOISE16X16"),
            new DitherInfo(name: "DitherArray8x8", keyword: "_DITHERTYPE_DITHERARRAY8X8"),
            new DitherInfo(name: "DitherArray4x4", keyword: "_DITHERTYPE_DITHERARRAY4X4"),
        };
    }
}
