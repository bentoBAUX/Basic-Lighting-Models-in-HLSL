Shader "Lighting/Oren-Nayar"
{
    Properties
    {
        _sigma ("Roughness", Range(0,1)) = 0.8
        _rho ("Surface Colour", Color) = (1,1,1,1)
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
            uniform fixed4 _rho;
            uniform fixed4 _LightColor0;

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
                float cosTheta = dot(n, l);
                float3 irradiance = _LightColor0 * max(cosTheta, 0);
                return irradiance;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half3 n = normalize(i.worldNormal);
                half3 l = normalize(_WorldSpaceLightPos0.xyz);
                half3 v = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 r = 2.0 * dot(n, l) * n - l;

                float3 E0 = calculateIrradiance(l, n);

                float theta_i = acos(saturate(dot(l, n)));
                float theta_r = acos(saturate(dot(r, n)));

                float phi_i = phi(l.x, l.y);
                float phi_r = phi(r.x, r.y);

                float cosPhi = cos(phi_i - phi_r);

                float alpha = max(theta_i, theta_r);
                float beta = min(theta_i, theta_r);

                float sigmaSqr = _sigma * _sigma;

                float3 C1 = 1 - 0.5 * (sigmaSqr / (sigmaSqr + 0.33));
                float3 C2 = cosPhi >= 0
                                 ? 0.45 * (sigmaSqr / (sigmaSqr + 0.09)) * sin(alpha)
                                 : 0.45 * (sigmaSqr / (sigmaSqr + 0.09)) * (sin(alpha) - pow((2 * beta) / UNITY_PI, 3));
                float3 C3 = 0.125 * (sigmaSqr / (sigmaSqr + 0.09)) * pow((4 * alpha * beta) / (UNITY_PI * UNITY_PI), 2);

                float3 L1 = (_rho / UNITY_PI) * E0 * cos(theta_i) * ((C1) + (C2 * cosPhi * tan(beta)) + (C3 * (1 -
                    abs(cosPhi)) * pow(tan((alpha + beta) / 2), 2)));
                float3 L2 = 0.17 * ((_rho * _rho) / UNITY_PI) * E0 * cos(theta_i) * (sigmaSqr / (sigmaSqr + 0.13)) * (1
                    - cosPhi * pow((2 * beta) / UNITY_PI, 2));

                float3 L = L1 + L2;

                return fixed4(L, 1.0);
            }
            ENDCG
        }
    }
}