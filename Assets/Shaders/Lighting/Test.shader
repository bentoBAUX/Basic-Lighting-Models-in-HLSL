Shader "Lighting/Test"
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
                float3 normals: NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normals: NORMAL;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normals = normalize(o.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            sampler2D _CameraGBufferTexture2;

            float _OutlineThickness;
            float _OutlineDepthMultiplier;
            float _OutlineDepthBias;
            float _OutlineNormalMultiplier;
            float _OutlineNormalBias;

            float4 _OutlineColor;

            float4 SobelDepth (float2 uv, float3 offset)
            {
                float4 centerPixel = tex2D(_CameraGBufferTexture2, uv);
                float4 leftPixel = tex2D(_CameraGBufferTexture2, uv - offset.xz);
                float4 rightPixel = tex2D(_CameraGBufferTexture2, uv + offset.xz);
                float4 upPixel = tex2D(_CameraGBufferTexture2, uv + offset.xy);
                float4 downPixel = tex2D(_CameraGBufferTexture2, uv - offset.xy);

                return abs(leftPixel - centerPixel)  +
                       abs(rightPixel - centerPixel) +
                       abs(upPixel - centerPixel)    +
                       abs(downPixel - centerPixel);
            }

            float SobelSampleDepth (float2 uv, float3 offset)
            {
                float centerPixel = LinearEyeDepth(tex2D(_CameraDepthTexture, uv).r);
                float leftPixel = LinearEyeDepth(tex2D(_CameraDepthTexture, uv - offset.xz).r);
                float rightPixel = LinearEyeDepth(tex2D(_CameraDepthTexture, uv + offset.xz).r);
                float upPixel = LinearEyeDepth(tex2D(_CameraDepthTexture, uv + offset.xy).r);
                float downPixel = LinearEyeDepth(tex2D(_CameraDepthTexture, uv - offset.xy).r);

                return abs(leftPixel - centerPixel)  +
                       abs(rightPixel - centerPixel) +
                       abs(upPixel - centerPixel)    +
                       abs(downPixel - centerPixel);
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 sceneColor = tex2D(_MainTex, i.uv);
                float4 depth = tex2D(_CameraDepthTexture, i.uv);
                float4 gBuffer = tex2D(_CameraGBufferTexture2, i.uv);

                float3 offset = float3((1.0 / _ScreenParams.x), (1.0 / _ScreenParams.y), 0.0) * _OutlineThickness;

                float sobelDepth = SobelSampleDepth(i.uv, offset);
                sobelDepth = pow(saturate(sobelDepth) * _OutlineDepthMultiplier, _OutlineDepthBias);

                float3 sobelNormalVec = SobelDepth(i.uv, offset).rgb;
                float sobelNormal = sobelNormalVec.x + sobelNormalVec.y + sobelNormalVec.z;
                sobelNormal = pow(sobelNormal * _OutlineNormalMultiplier, _OutlineNormalBias);

                float sobelOutline = saturate(max(sobelDepth, sobelNormal));

                // Modulate the outline color based on it's transparency
                float3 outlineColor = lerp(sceneColor, _OutlineColor.rgb, _OutlineColor.a);
                // Calculate the final scene color
                float3 color = lerp(sceneColor, outlineColor, sobelOutline);

                return float4(color.xyz, 1.0);
            }
            ENDCG
        }
    }
}