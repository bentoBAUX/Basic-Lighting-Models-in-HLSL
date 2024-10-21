Shader "Lighting/Gouraud-Phong"
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
                fixed4 color: COLOR0;
            };

            v2f vert(appdata vx)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vx.vertex);
                float3 worldPos = mul(unity_ObjectToWorld, vx.vertex).xyz;

                half3 n = UnityObjectToWorldNormal(vx.normal);
                half3 l = normalize(_WorldSpaceLightPos0.xyz);
                half3 r = 2.0 * dot(n, l) * n - l;
                half3 v = normalize(_WorldSpaceCameraPos - worldPos);

                float Ia = _k.x;
                float Id = _k.y * saturate(dot(n, l));
                float Is = _k.z * pow(saturate(dot(r, v)), _SpecularExponent);


                float3 ambient = Ia * _DiffuseColour.rgb;
                float3 diffuse = Id * _DiffuseColour.rgb * _LightColor0.rgb;
                float3 specular = Is * _LightColor0.rgb;

                float3 finalColor = ambient + diffuse + specular;

                o.color = fixed4(finalColor, 1.0);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 skyboxColor = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, float3(0,1,0)).rgb;
                return fixed4(i.color.rgb + skyboxColor * 0.2, 1.0);
            }
            ENDCG

        }
    }
}