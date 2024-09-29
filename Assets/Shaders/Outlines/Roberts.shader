Shader "Outlines/Roberts"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            uniform fixed4 _OutlineColour;
            uniform float _EdgeMultiplier;

            float4 RobertsCrossFilter(sampler2D tex, float2 texCoord, float2 texelSize)
            {
                // Filter1
                // 1,  0,
                // 0, -1

                // Filter2
                //  0, 1,
                // -1, 0

                float2 uv0 = texCoord;
                float2 uv1 = texCoord + texelSize;
                float2 uv2 = texCoord + float2(texelSize.x, 0);
                float2 uv3 = texCoord + float2(0, texelSize.y);

                float4 g1 = tex2D(tex, uv0) - tex2D(tex, uv1);
                float4 g2 = tex2D(tex, uv2) - tex2D(tex, uv3);

                return sqrt(dot(g1, g1) + dot(g2, g2));
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 originalColor = tex2D(_MainTex, i.uv);

                float edgeIntensity = _EdgeMultiplier * RobertsCrossFilter(_MainTex, i.uv, _MainTex_TexelSize.xy).r;

                return lerp(originalColor, _OutlineColour, edgeIntensity );
            }
            ENDCG
        }
    }
}