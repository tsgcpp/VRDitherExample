// ref: https://developer.oculus.com/blog/tech-note-shader-snippets-for-efficient-2d-dithering/

inline float sqr(float x)
{
	return x * x;
}

// https://gist.github.com/keijiro/ee7bc388272548396870
float Constant(float2 pos, uint frameIndexMod4)
{
	return 0.1234f;
}

/*
// texture mapping without mip maps (slower)
float SingleTextureMips0(float2 pos, uint frameIndexMod4)
{
	float2 UV = pos * c_TextureScale + In.PassIndex * 0.1f;

//	return g_TextureCacheNoMips_Rv.Sample(g_LinearSampler, UV).r;
	return 0;
}

// texture mapping with mip maps (faster)
float SingleTextureMips1(float2 pos, uint frameIndexMod4)
{
	float2 UV = pos * c_TextureScale + In.PassIndex * 0.1f;

//	return g_TextureCacheMips_Rv.Sample(g_LinearSampler, UV).r;
	return 0;
}
 */

// https://gist.github.com/keijiro/ee7bc388272548396870
float PseudoRandom(float2 pos, uint frameIndexMod4)
{
	pos *= 0.001f;
	pos += frameIndexMod4 * uint2(1, 0);

	return frac(sin(dot(pos, float2(12.9898, 78.233))) * 43758.5453);
}

float GradientNoise(float2 pos, uint frameIndexMod4)
{
	// could be improved further
	pos += frameIndexMod4 * 0.7f;

	// Interleaved Gradient Noise from "NEXT GENERATION POST PROCESSING IN CALL OF DUTY: ADVANCED WARFARE" http://advances.realtimerendering.com/s2014/index.html 
	const float3 magic = float3(0.06711056, 0.00583715, 52.9829189);

	return frac(magic.z * frac(dot(pos, magic.xy)));
}

/*
// moved to C++
float2 HaltonRandomXY(uint frameIndex)
{
	uint2 k0 = uint2(2, 3);
	uint p = frameIndex & 0xff;
	uint2 InBits = p * k0;
	// 0..0xff
	uint2 Int = reversebits(InBits) >> (32 - 8);
	// 0..~1
	return Int / 256.0f;
}
 */

// bytes packed in uint fo less cache misses
static const uint ArrayBlueNoiseA16x16[] =
{
	0x3083e0fc, 0x449303da, 0x8010e831, 0x17d6ee5d, // 0
	0x486e593a, 0xa4cf26b5, 0xdca9661a, 0x954fc534, // 1
	0x11ca21ba, 0xf0547de9, 0x2091c188, 0x7c2c9e6f, // 2
	0xa9f48ed4, 0x0b396397, 0xf93d4ce1, 0x0de4b405, // 3
	0x733f5ea1, 0x6dd5bd1c, 0xd17a28b1, 0x69468756, // 4
	0x50de0032, 0x82a0fd2d, 0x9a61ca15, 0xf6c614ea, // 5
	0x89b0c082, 0x334a08cc, 0xbc0aa7f5, 0x25ab7336, // 6
	0x6816e74b, 0x5a9478eb, 0xdd418be5, 0xd7925122, // 7
	0x38589979, 0xc418b7a2, 0x7e6b5324, 0x1a5ffeb3, // 8
	0xd206aaf1, 0x70db4326, 0xed0fd3af, 0x3ccd049c, // 9
	0xfa72c42b, 0x01ef6184, 0x2ec0973b, 0x6ab88a44, // 10
	0x1d8e47df, 0xa89051ba, 0x5d1cf87c, 0xa012e476, // 11
	0x37b20c5a, 0x2fc80ee6, 0xadc7674d, 0x803454d9, // 12
	0x65d098ec, 0x23d89e7a, 0x133e85e2, 0xcb1ff790, // 13
	0xf34e2875, 0xaf6c4019, 0x29f29c08, 0x41bda56e, // 14
	0xc3a407ad, 0xbefb5c8c, 0xb6cf5676, 0x64880246, // 15
};

float BlueNoiseA16x16(float2 pos, uint frameIndexMod4)
{
	// repeats every 4 frames, standing patterns
	pos += sqr(frameIndexMod4) * uint2(5, 3);

	uint stippleOffset = ((uint)pos.y % 16) * 16 + ((uint)pos.x % 16);
	uint entry = stippleOffset / 4;
	uint byteIndex = stippleOffset % 4;
	uint four = ArrayBlueNoiseA16x16[entry];
	uint byte = (four >> (byteIndex * 8)) & 0xff;
	float stippleThreshold = byte / 255.0f;
	return stippleThreshold;
}

// byte in uint table for testing
static const uint ArrayBlueNoiseB16x16[] =
{
	0x30,0x83,0xe0,0xfc, 0x44,0x93,0x03,0xda, 0x80,0x10,0xe8,0x31, 0x17,0xd6,0xee,0x5d, // 0
	0x48,0x6e,0x59,0x3a, 0xa4,0xcf,0x26,0xb5, 0xdc,0xa9,0x66,0x1a, 0x95,0x4f,0xc5,0x34, // 1
	0x11,0xca,0x21,0xba, 0xf0,0x54,0x7d,0xe9, 0x20,0x91,0xc1,0x88, 0x7c,0x2c,0x9e,0x6f, // 2
	0xa9,0xf4,0x8e,0xd4, 0x0b,0x39,0x63,0x97, 0xf9,0x3d,0x4c,0xe1, 0x0d,0xe4,0xb4,0x05, // 3
	0x73,0x3f,0x5e,0xa1, 0x6d,0xd5,0xbd,0x1c, 0xd1,0x7a,0x28,0xb1, 0x69,0x46,0x87,0x56, // 4
	0x50,0xde,0x00,0x32, 0x82,0xa0,0xfd,0x2d, 0x9a,0x61,0xca,0x15, 0xf6,0xc6,0x14,0xea, // 5
	0x89,0xb0,0xc0,0x82, 0x33,0x4a,0x08,0xcc, 0xbc,0x0a,0xa7,0xf5, 0x25,0xab,0x73,0x36, // 6
	0x68,0x16,0xe7,0x4b, 0x5a,0x94,0x78,0xeb, 0xdd,0x41,0x8b,0xe5, 0xd7,0x92,0x51,0x22, // 7
	0x38,0x58,0x99,0x79, 0xc4,0x18,0xb7,0xa2, 0x7e,0x6b,0x53,0x24, 0x1a,0x5f,0xfe,0xb3, // 8
	0xd2,0x06,0xaa,0xf1, 0x70,0xdb,0x43,0x26, 0xed,0x0f,0xd3,0xaf, 0x3c,0xcd,0x04,0x9c, // 9
	0xfa,0x72,0xc4,0x2b, 0x01,0xef,0x61,0x84, 0x2e,0xc0,0x97,0x3b, 0x6a,0xb8,0x8a,0x44, // 10
	0x1d,0x8e,0x47,0xdf, 0xa8,0x90,0x51,0xba, 0x5d,0x1c,0xf8,0x7c, 0xa0,0x12,0xe4,0x76, // 11
	0x37,0xb2,0x0c,0x5a, 0x2f,0xc8,0x0e,0xe6, 0xad,0xc7,0x67,0x4d, 0x80,0x34,0x54,0xd9, // 12
	0x65,0xd0,0x98,0xec, 0x23,0xd8,0x9e,0x7a, 0x13,0x3e,0x85,0xe2, 0xcb,0x1f,0xf7,0x90, // 13
	0xf3,0x4e,0x28,0x75, 0xaf,0x6c,0x40,0x19, 0x29,0xf2,0x9c,0x08, 0x41,0xbd,0xa5,0x6e, // 14
	0xc3,0xa4,0x07,0xad, 0xbe,0xfb,0x5c,0x8c, 0xb6,0xcf,0x56,0x76, 0x64,0x88,0x02,0x46, // 15
};

float BlueNoiseB16x16(float2 pos, uint frameIndexMod4)
{
	// repeats every 4 frames, standing patterns
	pos += sqr(frameIndexMod4) * uint2(5, 3);

	// 0..255
	uint stippleOffset = ((uint)pos.y % 16) * 16 + ((uint)pos.x % 16);
	// 0..64
	uint entry = stippleOffset / 4;
	uint byteIndex = stippleOffset % 4;
	// table reordering we could save some ALU
	uint byte = ArrayBlueNoiseB16x16[entry * 4 + 3 - byteIndex];
	float stippleThreshold = byte / 255.0f;
	return stippleThreshold;
}

// array/table version from http://www.anisopteragames.com/how-to-fix-color-banding-with-dithering/
static const uint ArrayDitherArray8x8[] =
{
	0, 32,  8, 40,  2, 34, 10, 42,   /* 8x8 Bayer ordered dithering  */
	48, 16, 56, 24, 50, 18, 58, 26,  /* pattern.  Each input pixel   */
	12, 44,  4, 36, 14, 46,  6, 38,  /* is scaled to the 0..63 range */
	60, 28, 52, 20, 62, 30, 54, 22,  /* before looking in this table */
	3, 35, 11, 43,  1, 33,  9, 41,   /* to determine the action.     */
	51, 19, 59, 27, 49, 17, 57, 25,
	15, 47,  7, 39, 13, 45,  5, 37,
	63, 31, 55, 23, 61, 29, 53, 21
};

float DitherArray8x8(float2 pos, uint frameIndexMod4)
{
	pos += int2(frameIndexMod4 % 2, frameIndexMod4 / 2) * uint2(5, 5);

	uint stippleOffset = ((uint)pos.y % 8) * 8 + ((uint)pos.x % 8);
	uint byte = ArrayDitherArray8x8[stippleOffset];
	float stippleThreshold = byte / 64.0f;
	return stippleThreshold;
}


// array/table version from https://en.wikipedia.org/wiki/Ordered_dithering
static const uint ArrayDitherArray4x4[] =
{
	0,8,2,10,12,4,14,6,3,11,1,9,15,7,13,5
};

float DitherArray4x4(float2 pos, uint frameIndexMod4)
{
	pos += int2(frameIndexMod4 % 2, frameIndexMod4 / 2) * uint2(2, 2);

	uint stippleOffset = ((uint)pos.y % 4) * 4 + ((uint)pos.x % 4);
	uint byte = ArrayDitherArray4x4[stippleOffset];
	// +0.5f to not dither 1.0f case
	float stippleThreshold = (byte + 0.5f) / 16.0f;
	return stippleThreshold;
}

/*
// @return 0..1
float BlueNoiseTex64x64(float2 pos, uint frameIndexMod4)
{
	// 0..1, computed on C/C++, more efficient
	float2 RandomXY = In.HaltonRandomXY;

	float2 UV = pos / 64.0f + RandomXY;

	// 64x64 texture, R8 to avoid having to use Textur2D<float4> with .a access
	return g_BlueNoise_LDR_LLL1_0_Rv.SampleLevel(g_PointSampler, UV, 0);
}
 */

float Dither64(float2 pos, uint frameIndexMod4)
{
	// 63
//	uint3 k0 = uint3(27, 52, 16);
//	float Ret = dot(float3(pos.xy, frameIndexMod4), k0 / 63.0f);

	// 64
	uint3 k0 = uint3(33, 52, 25);
	float Ret = dot(float3(pos.xy, frameIndexMod4), k0 / 64.0f);

	return frac(Ret);
}

float Dither64int(float2 pos, uint frameIndexMod4)
{
	uint3 k0 = uint3(33, 52, 25);
	uint Ret = dot(int3(pos.xy, frameIndexMod4), k0);

	return (Ret & 0x3f) / 64.0f;
}

float Dither32int(float2 pos, uint frameIndexMod4)
{
	uint3 k0 = uint3(13, 5, 15);
	uint offset = dot(float3(0.5f, 0.5f, 0), k0);
	uint Ret = (offset + dot(int3(pos.xy, frameIndexMod4), k0)) & 0x1f;

	return frac((Ret + 0.5f) / 32.0f);
}

float Dither32(float2 pos, uint frameIndexMod4)
{
	uint3 k0 = uint3(13, 5, 15);

	float Ret = dot(float3(pos.xy, frameIndexMod4 + 0.5f), k0 / 32.0f);

	return frac(Ret);
}

float Dither16(float2 pos, uint frameIndexMod4)
{
	uint3 k0 = uint3(36, 7, 26);
	
	// uncomment one line to experiment with the numbers
//	k0.xy = uint2(c_GeneralPurposeTweakX, c_GeneralPurposeTweakY);
//	k0.z = c_GeneralPurposeTweakX;

	float Ret = dot(float3(pos.xy, frameIndexMod4), k0 / 16.0f);

	return frac(Ret);
}

// to see effect of non power of two value, pattern is less aligned with axis makes it look more pleasing
float Dither17(float2 pos, uint frameIndexMod4)
{
	uint3 k0 = uint3(2, 7, 23);

	float Ret = dot(float3(pos.xy, frameIndexMod4), k0 / 17.0f);

	return frac(Ret);
}

// expensive int math
float Halton16(float2 pos, uint frameIndexMod4)
{
	uint3 k0 = uint3(11, 9, 15);
	
	uint3 p = uint3((uint2)pos.xy, frameIndexMod4);
	uint InBits = dot(p, k0);

	uint Out = reversebits(InBits) >> (32 - 4);

	return frac((Out + 0.5f) / 15.0f);
}

// expensive int math
float Halton64(float2 pos, uint frameIndexMod4)
{
	uint3 k0 = uint3(43, 9, 45);

	uint3 p = uint3((uint2)pos.xy, frameIndexMod4);
	uint InBits = dot(p, k0);

	uint Out = reversebits(InBits) >> (32 - 6);

	return frac((Out + 0.5f) / 63.0f);
}
