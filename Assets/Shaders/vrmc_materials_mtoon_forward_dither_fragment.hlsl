#include "./Dither.hlsl"
#include "Packages/com.vrmc.vrmshaders/VRM10/MToon10/Resources/VRM10/vrmc_materials_mtoon_forward_fragment.hlsl"

float _Alpha;

half4 MToonDitherFragment(const FragmentInput fragmentInput) : SV_Target
{
    float2 pos = fragmentInput.varyings.pos.xy;
    clip(DitherClip(pos, _Alpha));
    return MToonFragment(fragmentInput);
}