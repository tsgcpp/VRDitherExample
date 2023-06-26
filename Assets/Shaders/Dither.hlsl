#include "./DitherExperimentCustom.hlsl"

#pragma multi_compile_fragment _ _DITHERTYPE_NONE _DITHERTYPE_DITHERMASKLOD _DITHERTYPE_PSEUDORANDOM _DITHERTYPE_GRADIENTNOISE _DITHERTYPE_BLUENOISE16X16 _DITHERTYPE_DITHERARRAY8X8 _DITHERTYPE_DITHERARRAY4X4

#if defined(_DITHERTYPE_DITHERMASKLOD)
sampler3D _DitherMaskLOD;
#endif

float DitherClip(float2 pos, float alpha)
{
    float dither;
#if defined(_DITHERTYPE_DITHERMASKLOD)
    dither = tex3D(_DitherMaskLOD, float3(pos * 0.25, alpha * 0.9375)).a;
#elif defined(_DITHERTYPE_PSEUDORANDOM)
    dither = PseudoRandom(pos, 0);
#elif defined(_DITHERTYPE_GRADIENTNOISE)
    dither = GradientNoise(pos, 0);
#elif defined(_DITHERTYPE_BLUENOISE16X16)
    dither = BlueNoiseA16x16(pos, 0);
#elif defined(_DITHERTYPE_DITHERARRAY8X8)
    dither = DitherArray8x8(pos, 0);
#elif defined(_DITHERTYPE_DITHERARRAY4X4)
    dither = DitherArray4x4(pos, 0);
#else
    dither = 1;
#endif
    return dither - (1 - alpha);
}