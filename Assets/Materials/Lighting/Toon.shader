// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Lighting/Toon"
{
    Properties
    {
        [Header(Colours)][Space(10)]
        _DiffuseColour("Diffuse Colour", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [Normal]_Normal("Normal", 2D) = "bump" {}
        _NormalStrength("Normal Strength", Range(1,20)) = 1

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

            uniform fixed4 _DiffuseColour;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float4 _Normal_ST;
            uniform sampler2D _Normal;
            uniform float _NormalStrength;

            uniform fixed4 _LightColor0;
            uniform float3 _k;
            uniform float _SpecularExponent;
            uniform float _FresnelPower;
            uniform float _RimThreshold;
            uniform float _Tiling;

            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float2 uv: TEXCOORD0;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos: TEXCOORD1;
                float3 worldNormal: TEXCOORD2;
                fixed4 color: COLOR0;
                float3x3 TBN : TEXCOORD4;
                SHADOW_COORDS(3)
            };

            v2f vert(appdata vx)
            {
                v2f o;
                o.uv = vx.uv;
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

            fixed4 frag(v2f i) : SV_Target
            {
                float4 c = tex2D(_MainTex, i.uv * _MainTex_ST.xy + _MainTex_ST.zw) * _DiffuseColour;

                float3 normalMap = UnpackNormal(tex2D(_Normal, i.uv * _Normal_ST + _Normal_ST));
                normalMap.xy *= _NormalStrength;
                half3 n = normalize(mul(transpose(i.TBN), normalMap));

                half3 l = normalize(_WorldSpaceLightPos0.xyz);
                half3 v = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 h = normalize(l + v);

                float NdotL = saturate(dot(n, l));

                float shadow = SHADOW_ATTENUATION(i);
                float lightIntensity = smoothstep(0, 0.01, NdotL * shadow);

                // Blinn-Phong
                float Ia = _k.x;
                float Id = _k.y * lightIntensity;
                float Is = _k.z * pow(saturate(dot(h, n)), _SpecularExponent * _SpecularExponent);

                Is = smoothstep(0.005, 0.01, Is);

                // Fresnel Rim-Lighting
                float rimDot = 1 - dot(v, n);
                float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
                rimIntensity = smoothstep(_FresnelPower - 0.01, _FresnelPower + 0.01, rimIntensity);

                float4 fresnel = rimIntensity * _LightColor0;

                float3 skyboxColor = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, float3(0,1,0)).rgb;

                float3 ambient = Ia * (UNITY_LIGHTMODEL_AMBIENT + _LightColor0.rgb + skyboxColor);
                float3 diffuse = Id * _LightColor0.rgb;
                float3 specular = Is * _LightColor0.rgb;

                float3 finalColor = ambient + (diffuse + specular + fresnel) * shadow;

                i.color = fixed4(finalColor * c.rgb, 1.0);

                return i.color;
            }
            ENDCG

        }
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}