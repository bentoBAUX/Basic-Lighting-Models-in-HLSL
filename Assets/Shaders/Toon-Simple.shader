/*
    References:
        https://roystan.net/articles/toon-shader/
        https://en.wikipedia.org/wiki/Blinn–Phong_reflection_model
*/
Shader "Lighting/Toon-Simple"
{
    Properties
    {
        [Header(Colours)][Space(10)]
        _DiffuseColour("Diffuse Colour", Color) = (1,1,1,1)

        [Header(Blinn Phong)][Space(10)]
        [Toggle(SPECULAR)] _Specular("Specular Highlight", float) = 1

        _k ("Coefficients (Ambient, Diffuse, Specular)", Vector) = (0.5,0.5,0.8)
        _SpecularExponent("Specular Exponent", Float) = 80

        [Header(Rim)][Space(10)]
        [Toggle(RIM)] _Rim("Rim", float) = 1
        _FresnelPower("Fresnel Power", Range(0.01, 1)) = 0.5
        _RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
    }
    SubShader
    {
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
        Pass
        {
            Name "ForwardBase"
            Tags
            {
                "LightMode"="ForwardBase"
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma shader_feature RIM
            #pragma shader_feature SPECULAR


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
                float3 worldNormal : TEXCOORD0;
                float3 worldPos: TEXCOORD1;
            };

            v2f vert(appdata vx)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(vx.vertex);
                o.worldPos = mul(unity_ObjectToWorld, vx.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(vx.normal);

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 c = _DiffuseColour;

                half3 n = normalize(i.worldNormal);
                half3 l = normalize(_WorldSpaceLightPos0.xyz);
                half3 v = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 h = normalize(l + v);

                fixed NdotL = saturate(dot(n, l));

                float lightIntensity = NdotL / 0.01;
                lightIntensity = saturate(lightIntensity);

                // Blinn-Phong
                fixed Ia = _k.x;
                fixed Id = _k.y * lightIntensity;

                #ifdef SPECULAR
                float Is = _k.z * pow(saturate(dot(h, n)), _SpecularExponent * _SpecularExponent);
                Is = smoothstep(0.005, 0.01, Is);
                #else
                float Is = 0.0;  // Disable specular if checkbox is unchecked
                #endif

                half3 ambient = Ia * _DiffuseColour.rgb * ShadeSH9(float4(n, 1)); // Use spherical harmonics (SH) to approximate indirect ambient lighting from the environment.
                half3 diffuse = Id * c * _LightColor0.rgb;
                half3 specular = Is * _LightColor0.rgb;

                // Fresnel Rim-Lighting
                half4 fresnel;
                #ifdef RIM
                fixed rimDot = 1 - dot(v, n);
                float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
                rimIntensity = smoothstep(_FresnelPower - 0.01, _FresnelPower + 0.01, rimIntensity);
                fresnel = rimIntensity * _LightColor0;
                #else
                fresnel = 0;
                #endif

                half3 finalColor = ambient + diffuse + specular + fresnel;

                return half4(finalColor, 1.0);
            }
            ENDHLSL

        }
    }


}