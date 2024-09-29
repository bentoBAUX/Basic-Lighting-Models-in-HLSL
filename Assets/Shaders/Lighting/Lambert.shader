Shader "Lighting/Lambert"
{
  Properties {
    _DiffuseColour ("Diffuse Colour", Color) = (1, 1, 1, 1)
    kD("Diffuse Reflectivity", Range(0,1)) = 0.5
  }
  SubShader {
    Pass {
      Tags { "LightMode" = "ForwardBase" }

      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #include "UnityCG.cginc"

      // Properties
      uniform fixed4 _LightColor0;
      uniform fixed4 _DiffuseColour;
      uniform float kD;

      // Vertex Input
      struct appdata {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
      };

      // Vertex to Fragment
      struct v2f {
        float4 pos   : SV_POSITION;
        fixed4 color : COLOR0;
      };

      //------------------------------------------------------------------------
      // Vertex Shader
      //------------------------------------------------------------------------
      v2f vert(appdata v)
      {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

        half3 n = UnityObjectToWorldNormal(v.normal);
        half3 l = normalize(_WorldSpaceLightPos0.xyz);

        float I = kD * saturate(dot(n, l));
        o.color = fixed4((I * _DiffuseColour.rgb) * _LightColor0, 1.0);

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