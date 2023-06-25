Shader "VRDitherExample/DitherSample"
{
    Properties
    {
        _Alpha ("Alpha", Range(0.0, 1.0)) = 1.0
        _Color ("Color", Color) = (1, 1, 1, 1) // Unity specified name
        [KeywordEnum(None, DitherMaskLOD, PseudoRandom, GradientNoise, BlueNoise16x16, DitherArray8x8, DitherArray4x4)] _DitherType ("Dither Type", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "./Dither.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Alpha;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                clip(DitherClip(i.vertex.xy, _Alpha));
                return _Color;
            }
            ENDCG
        }
    }
}
