Shader "Lighting/Cook-Torrance"
{
    Properties
    {
        _sigma ("Roughness", Range(0,1)) = 0.8
        _DiffuseColour ("Surface Colour", Color) = (1,1,1,1)
        _Metallic ("Metallic", Range(0, 1)) = 0.5
        _RefractiveIndex ("Refractive Index", Range(1, 5)) = 2.5
    }

    SubShader
    {
        Tags
        {
            "LightMode"="ForwardBase"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float3 worldPos: TEXCOORD0;
                float3 worldNormal: TEXCOORD1;
                fixed4 color: COLOR0;
            };

            uniform float _sigma;
            uniform fixed4 _DiffuseColour;
            uniform fixed4 _LightColor0;
            uniform float _Metallic;
            uniform float _RefractiveIndex;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float phi(float x, float y)
            {
                return atan2(y, x);
            }

            float3 calculateIrradiance(float3 l, float3 n)
            {
                return _LightColor0.rgb * saturate(dot(n, l)); // LightColor multiplied by NdotL
            }

            float4 frag(v2f i) : SV_Target
            {
                half3 n = normalize(i.worldNormal);
                half3 l = normalize(_WorldSpaceLightPos0.xyz);
                half3 v = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 r = 2.0 * dot(l, n) * n - l;
                half3 h = normalize(l + v);

                float3 E0 = calculateIrradiance(l, n);

                float NdotL = saturate(dot(n, l));
                float NdotV = saturate(dot(n, v));

                float theta_i = acos(dot(l, n));
                float theta_r = acos(dot(r, n));

                float3 Lproj = normalize(l - n * NdotL);
                float3 Vproj = normalize(v - n * NdotV + 1);
                float cosPhi = dot(Lproj, Vproj);

                float alpha = max(theta_i, theta_r);
                float beta = min(theta_i, theta_r);
                float sigmaSqr = _sigma * _sigma;

                // Oren-Nayar: https://en.wikipedia.org/wiki/Oren–Nayar_reflectance_model

                float C1 = 1 - 0.5 * (sigmaSqr / (sigmaSqr + 0.33));
                float C2 = cosPhi >= 0
                                              ? 0.45 * (sigmaSqr / (sigmaSqr + 0.09)) * sin(alpha)
                                              : 0.45 * (sigmaSqr / (sigmaSqr + 0.09)) * (sin(alpha) - pow(
                                                  (2.0 * beta) / UNITY_PI, 3.0));
                float C3 = 0.125 * (sigmaSqr / (sigmaSqr + 0.09)) *
                    pow((4.0 * alpha * beta) / (UNITY_PI * UNITY_PI), 2);

                float3 L1 = _DiffuseColour * E0 * cos(theta_i) * (C1 + (C2 * cosPhi * tan(beta)) + (C3 * (1.0 - abs(cosPhi)) *
                    tan((alpha + beta) / 2.0)));
                float3 L2 = 0.17 * (_DiffuseColour * _DiffuseColour) * E0 * cos(theta_i) * (sigmaSqr / (sigmaSqr + 0.13)) * (1.0 - cosPhi *
                    pow((2.0 * beta) / UNITY_PI, 2.0));

                float3 L = (L1 + L2);

                // Cook-Torrance: https://en.wikipedia.org/wiki/Specular_highlight#Cook–Torrance_model

                float NdotH = saturate(dot(n, h));
                float a = acos(NdotH);
                float m = clamp(sigmaSqr, 0.01, 1);
                float exponent = exp(-tan(a) * tan(a) / (m * m));
                float D = clamp(exponent / (UNITY_PI * m * m * pow(NdotH, 4)), 0.01, 1e30);

                float F0 = ((_RefractiveIndex - 1) * (_RefractiveIndex - 1)) / ((_RefractiveIndex + 1) * (_RefractiveIndex + 1));
                float F = F0 + (1 - F0) * pow(1 - clamp(dot(v, h), 0, 1), 5);

                float G1 = 2 * dot(h, n) * dot(n, v) / dot(v, h);
                float G2 = 2 * dot(h, n) * dot(n, l) / dot(v, h);
                float G = min(1, min(G1, G2));

                float specular = ((D * G * F) / (4 * dot(n, l)) * dot(n, v)) * _LightColor0;

                float3 skyboxColor = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, float3(0,1,0)).rgb;
                fixed3 ambient = 0.5 * (UNITY_LIGHTMODEL_AMBIENT + _LightColor0 + skyboxColor);

                return float4(ambient + lerp(L, specular, _Metallic), 1.0);
            }
            ENDCG
        }
    }
}