// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "Lighting/Phong"
{
    Properties
    {
        _DiffuseColour("Diffuse Colour", Color) = (1,1,1,1)
        _SpecularExponent("Specular Exponent", Float) = 80
        _k ("Coefficients (Ambient, Diffuse, Specular)", Vector) = (0.5,0.5,0.8)
        _ambient ("Ambient", Range(0,1)) = 0
    }
    SubShader
    {

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"


            uniform fixed4 _DiffuseColour;
            uniform fixed4 _LightColor0;
            uniform float3 _k;
            uniform float _SpecularExponent;
            uniform bool _ambient;

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

            v2f vert(appdata vx)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vx.vertex);
                o.worldPos = mul(unity_ObjectToWorld, vx.vertex).xyz;

                o.worldNormal = UnityObjectToWorldNormal(vx.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half3 n = normalize(i.worldNormal);
                half3 l = normalize(_WorldSpaceLightPos0.xyz);
                half3 r = 2.0 * dot(n,l) * n - l;
                half3 v = normalize(_WorldSpaceCameraPos - i.worldPos);

                float Ia = _k.x;
                float Id = _k.y * saturate(dot(n,l));
                float Is = _k.z * pow(saturate(dot(r,v)), _SpecularExponent);

                float3 ambient = _ambient ? UNITY_LIGHTMODEL_AMBIENT * Ia * _LightColor0.rgb : Ia * _LightColor0.rgb;
                float3 diffuse = Id * _LightColor0.rgb;
                float3 specular = Is * _LightColor0.rgb;

                float3 skyboxColor = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, n).rgb;

                float3 finalColor = ambient + diffuse + specular + skyboxColor * 0.2;

                i.color = fixed4(finalColor * _DiffuseColour.rgb,1.0);

                return i.color;
            }

            ENDCG

        }
    }
}
