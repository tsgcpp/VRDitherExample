// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

namespace VRDitherExample
{
    public readonly struct DitherInfo
    {
        public string Name { get; }
        public string Keyword { get; }

        public DitherInfo(
            string name,
            string keyword)
        {
            Name = name;
            Keyword = keyword;
        }
    }
}
