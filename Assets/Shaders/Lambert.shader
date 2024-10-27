Shader "Lighting/Lambert"
{
    Properties
    {
        _DiffuseColour ("Diffuse Colour", Color) = (1, 1, 1, 1)
        kD("Diffuse Reflectivity", Range(0,1)) = 0.5
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // Properties
            uniform fixed4 _LightColor0;
            uniform fixed4 _DiffuseColour;
            uniform float kD;

            // Vertex Input
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            // Vertex to Fragment
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR0;
            };

            //------------------------------------------------------------------------
            // Vertex Shader
            //------------------------------------------------------------------------
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);         // Transform vertex position to clip space

                half3 n = UnityObjectToWorldNormal(v.normal);   // Converting vertex normals to world normals.
                half3 l = normalize(_WorldSpaceLightPos0.xyz);  // Normalises the light direction vector.

                float Id = kD * saturate(dot(n, l));            // saturate() to clamp dot product values between 0 and 1 to prevent negative light intensities.
                o.color = Id * _DiffuseColour * _LightColor0;   // Multiplying I with the surface's colour and the light's colour to get the final observed colour.

                return o;
            }

            //------------------------------------------------------------------------
            // Fragment Shader
            //------------------------------------------------------------------------
            fixed4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}