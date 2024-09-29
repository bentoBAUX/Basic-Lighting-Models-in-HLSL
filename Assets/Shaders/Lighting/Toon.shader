/*
    References:
        https://roystan.net/articles/toon-shader/
        https://en.wikipedia.org/wiki/Blinn–Phong_reflection_model
*/
Shader "Lighting/Toon"
{
    Properties
    {
        [Header(Colours)][Space(10)]
        _DiffuseColour("Diffuse Colour", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [Normal]_Normal("Normal", 2D) = "bump" {}
        _NormalStrength("Normal Strength", Range(0,20)) = 1

        [Header(Blinn Phong)][Space(10)]
        _k ("Coefficients (Ambient, Diffuse, Specular)", Vector) = (0.5,0.5,0.8)
        _SpecularExponent("Specular Exponent", Float) = 80
        _FresnelPower("Fresnel Power", Range(0.01, 1)) = 0.5
        _RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
    }
    SubShader
    {

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            uniform half4 _DiffuseColour;

            uniform sampler2D _MainTex;
            uniform half4 _MainTex_ST;

            uniform half4 _Normal_ST;
            uniform sampler2D _Normal;
            uniform half _NormalStrength;

            uniform half4 _LightColor0;
            uniform half3 _k;

            uniform float _SpecularExponent;
            uniform float _FresnelPower;
            uniform float _RimThreshold;

            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_Normal : TEXCOORD1;
                float3 worldPos: TEXCOORD2;
                float3x3 TBN : TEXCOORD3;
                SHADOW_COORDS(6)
            };

            v2f vert(appdata vx)
            {
                v2f o;
                o.uv_MainTex = vx.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv_Normal = vx.uv * _Normal_ST.xy + _Normal_ST.zw;
                o.pos = UnityObjectToClipPos(vx.vertex);
                o.worldPos = mul(unity_ObjectToWorld, vx.vertex).xyz;

                float3 worldNormal = UnityObjectToWorldNormal(vx.normal);
                float3 worldTangent = mul((float3x3)unity_ObjectToWorld, vx.tangent);

                float3 bitangent = cross(worldNormal, worldTangent);
                float3 worldBitangent = mul((float3x3)unity_ObjectToWorld, bitangent);

                o.TBN = float3x3(worldTangent, worldBitangent, worldNormal);

                TRANSFER_SHADOW(o);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 c = tex2D(_MainTex, i.uv_MainTex) * _DiffuseColour;

                half3 normalMap = UnpackNormal(tex2D(_Normal, i.uv_Normal));
                normalMap.xy *= _NormalStrength;

                half3 n = normalize(mul(transpose(i.TBN), normalMap));
                // Transforming normal map vectors from tangent space to world space. TBN * v_world = v_tangent | TBN-1 * v_tangent = v_world
                half3 l = normalize(_WorldSpaceLightPos0.xyz);
                half3 v = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 h = normalize(l + v);

                fixed NdotL = saturate(dot(n, l));

                fixed shadow = SHADOW_ATTENUATION(i);
                float lightIntensity = NdotL * shadow / 0.01;
                lightIntensity = saturate(lightIntensity);

                // Blinn-Phong
                fixed Ia = _k.x;
                fixed Id = _k.y * lightIntensity;
                float Is = _k.z * pow(saturate(dot(h, n)), _SpecularExponent * _SpecularExponent);
                Is = smoothstep(0.005, 0.01, Is);

                // Fresnel Rim-Lighting
                fixed rimDot = 1 - dot(v, n);
                float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
                rimIntensity = smoothstep(_FresnelPower - 0.01, _FresnelPower + 0.01, rimIntensity);

                half4 fresnel = rimIntensity * _LightColor0;

                half3 skyboxColor = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, float3(0,1,0)).rgb;

                half3 ambient = Ia * (UNITY_LIGHTMODEL_AMBIENT + _LightColor0.rgb + skyboxColor);
                half3 diffuse = Id * _LightColor0.rgb;
                half3 specular = Is * _LightColor0.rgb;

                half3 lighting = diffuse + specular + fresnel;
                half3 finalColor = ambient + lighting * shadow;

                return half4(finalColor * c.rgb, 1.0);
            }
            ENDCG

        }
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}