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
                fixed3 n : TEXCOORD0;
            };

            v2f vert(appdata vx)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vx.vertex);
                float3 worldPos = mul(unity_ObjectToWorld, vx.vertex).xyz;

                half3 n = UnityObjectToWorldNormal(vx.normal);          // Convert normal to world space
                half3 l = normalize(_WorldSpaceLightPos0.xyz);          // Light direction in world space
                half3 r = 2.0 * dot(n, l) * n - l;                      // Reflection vector
                half3 v = normalize(_WorldSpaceCameraPos - worldPos);   // View direction

                float Ia = _k.x;                                        // Ambient intensity
                float Id = _k.y * saturate(dot(n, l));                  // Diffuse intensity using Lambert's law
                float Is = _k.z * pow(saturate(dot(r, v)), _SpecularExponent); // Specular intensity

                float3 ambient = Ia * _DiffuseColour.rgb;               // Ambient lighting
                float3 diffuse = Id * _DiffuseColour.rgb * _LightColor0.rgb; // Diffuse lighting
                float3 specular = Is * _LightColor0.rgb;                // Specular lighting

                float3 finalColor = ambient + diffuse + specular;       // Combine all lighting components

                o.color = fixed4(finalColor, 1.0);                      // Set the final output colour
                o.n = n;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 ambientSH = ShadeSH9(float4(i.n, 1));
                fixed3 ambient = _DiffuseColour * ambientSH;
                return fixed4(i.color.rgb + ambient, 1.0);    // Add a portion of the skybox colour and return the final colour
            }
            ENDCG

        }
    }
}