Shader "Lighting/Flat Shading"
{
    Properties
    {
        _DiffuseColour("Diffuse Colour", Color) = (1,1,1,1)
        _SpecularExponent("Specular Exponent", Float) = 80
        _k ("Coefficients (Ambient, Diffuse, Specular)", Vector) = (0.5,0.5,0.8)
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
            #include "UnityCG.cginc"

            uniform fixed4 _DiffuseColour;
            uniform fixed4 _LightColor0;
            uniform float3 _k;
            uniform float _SpecularExponent;

            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float3 worldPos: TEXCOORD0;
                fixed4 color: COLOR0;
            };

            v2f vert(appdata vx)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vx.vertex);
                o.worldPos = mul(unity_ObjectToWorld, vx.vertex).xyz;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldNormal = normalize(cross(ddy(i.worldPos), ddx(i.worldPos)));

                half3 n = normalize(worldNormal);
                half3 l = normalize(_WorldSpaceLightPos0.xyz);
                half3 v = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 h = normalize(l + v);

                float Ia = _k.x;
                float Id = _k.y * saturate(dot(n, l));
                float Is = _k.z * pow(saturate(dot(h, n)), _SpecularExponent);

                float3 ambient = Ia * _DiffuseColour.rgb * ShadeSH9(float4(n, 1)); // Use spherical harmonics (SH) to approximate indirect ambient lighting from the environment.
                float3 diffuse = Id * _DiffuseColour.rgb * _LightColor0.rgb;
                float3 specular = Is * _LightColor0.rgb;

                float3 finalColor = ambient + diffuse + specular;

                i.color = fixed4(finalColor, 1.0);

                return i.color;
            }
            ENDCG

        }
    }
}