/*
    References:
        https://roystan.net/articles/toon-shader/
        https://en.wikipedia.org/wiki/Blinn–Phong_reflection_model

    Known issues:
        Avoid 90-deg downwards pointing directional light. This causes odd shadows.

*/
Shader "Lighting/Toon"
{
    Properties
    {
        [Header(Colours)][Space(10)]
        _DiffuseColour("Diffuse Colour", Color) = (1,1,1,1)
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        [Toggle(USETRANSPARENT)] _UseTransparent("Use Transparent", float) = 0
        _AlphaCutoff("Alpha Cutoff", Range(0, 1)) = 0.5

        [Header(Emission)][Space(10)]
        [Toggle(USEEMISSIVE)] _Emissive("Emissive", float) = 0
        [HDR] _EmissiveColour("Emissive Colour", Color) = (1,1,1,1)
        _EmissiveTexture("Emissive Texture", 2D) = "white"{}

        [Header(Normal)][Space(10)]
        [Normal]_Normal("Normal", 2D) = "bump" {}
        _NormalStrength("Normal Strength", Range(0,20)) = 1

        [Header(Blinn Phong)][Space(10)]
        [Toggle(SPECULAR)] _Specular("Specular Highlight", float) = 1

        _k ("Coefficients (Ambient, Diffuse, Specular)", Vector) = (0.5,0.5,0.8)
        _SpecularExponent("Specular Exponent", Float) = 80

        [Header(Rim)][Space(10)]
        [Toggle(RIM)] _Rim("Rim", float) = 1
        [Toggle(USERIMCOLOUR)] _UseRim("Use Rim", float) = 0
        [HDR]_RimColour("Rim Colour", Color) = (1,1,1,1)
        _FresnelPower("Fresnel Power", Range(0.01, 1)) = 0.5
        _RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        Pass
        {
            // This pass is responsible for rendering objects from the perspective of light sources.
            // It writes depth values into the shadow map to determine shadowed areas in the scene.
            // Pixels that fail the alpha test are excluded from the shadow map and will neither cast nor receive shadows.

            Name "Clip Alphas"

            Tags
            {
                "LightMode" = "ShadowCaster" // Marks this pass for shadow map rendering
            }

            Cull Off  // Disable back-face culling to ensure shadows from both sides of an object
            ZWrite On // Enable depth writing to store depth information in the shadow map

            HLSLPROGRAM

            // Include Unity shader libraries
            #include "UnityCG.cginc"

            // Shader entry points
            #pragma vertex vertShadow
            #pragma fragment fragShadow

            // Enables shadow caster variant compilation for different lighting scenarios
            #pragma multi_compile_shadowcaster

            // Structure defining the vertex data (input)
            struct appdata
            {
                half4 vertex : POSITION;  // Object-space vertex position
                half3 normal : NORMAL;    // Normal vector (unused in this pass)
                half2 uv : TEXCOORD0;     // UV coordinates for texture sampling
                half4 tangent : TANGENT;  // Tangent vector (unused in this pass)
            };

            // Structure defining the interpolated data passed to the fragment shader
            struct v2f
            {
                float2 uv_MainTex : TEXCOORD0; // UV coordinates for albedo texture
                float4 pos : SV_POSITION;      // Clip-space position for depth rendering
            };

            // ===== Shader Properties (Uniforms) =====
            sampler2D _MainTex;   // Main texture (for alpha testing)
            float _AlphaCutoff;   // Alpha threshold for transparency clipping

            v2f vertShadow(appdata v)
            {
                v2f o;

                // Transform object-space vertex position into clip-space
                o.pos = UnityObjectToClipPos(v.vertex);

                // Pass UV coordinates to the fragment shader for texture sampling
                o.uv_MainTex = v.uv;

                return o;
            }

            float4 fragShadow(v2f i) : SV_Target
            {
                // Sample the texture to retrieve the alpha value
                float4 c = tex2D(_MainTex, i.uv_MainTex);

                // Apply alpha clipping: if alpha is below the cutoff, discard the fragment
                clip(c.a - _AlphaCutoff);

                // Shadow map does not require color output, return zero
                return 0;
            }

            ENDHLSL
        }


         Pass
        {
            // This pass handles the base lighting for the MAIN directional light.
            // It includes diffuse, specular, rim, and emissive effects.

            Name "ForwardBase"

            Tags
            {
                "LightMode" = "ForwardBase" // Marks this as the base pass for directional lighting
            }

            Cull Off                             // Disable back-face culling to ensure lighting applies to both sides
            Blend SrcAlpha OneMinusSrcAlpha      // Alpha blending for transparency support

            HLSLPROGRAM

            // Shader entry points
            #pragma vertex vert
            #pragma fragment frag

            // Enables support for shadows, lightmaps, and light probes in the base pass
            #pragma multi_compile_fwdbase

            // Enable Unity fog
            #pragma multi_compile_fog

            // Enable optional features controlled by shader keywords
            #pragma shader_feature RIM              // Enables rim lighting effect
            #pragma shader_feature SPECULAR         // Enables Blinn-Phong specular reflections
            #pragma shader_feature USETRANSPARENT   // Enables transparency (alpha cutoff)
            #pragma shader_feature USEEMISSIVE      // Enables emissive lighting
            #pragma shader_feature USERIMCOLOUR     // Enables custom rim light colour

            // Include Unity shader libraries
            #include "UnityCG.cginc"
            #include "AutoLight.cginc" // Includes functions for light attenuation and shadowing

            // ===== Shader Properties (Uniforms) =====

            uniform half4 _DiffuseColour;  // Base diffuse colour multiplier

            // Albedo (diffuse texture)
            uniform sampler2D _MainTex;
            uniform half4 _MainTex_ST;  // Texture scale and offset

            // Emissive color and texture
            uniform half4 _EmissiveColour;
            uniform sampler2D _EmissiveTexture;
            uniform half4 _EmissiveTexture_ST;

            // Transparency settings
            uniform half _AlphaCutoff;

            // Normal map settings
            uniform sampler2D _Normal;
            uniform half4 _Normal_ST;  // Texture scale and offset
            uniform half _NormalStrength;  // Normal map strength multiplier

            // Lighting coefficients (Ambient, Diffuse, Specular)
            uniform half3 _k;

            // Specular lighting parameters
            uniform float _SpecularExponent;

            // Rim lighting parameters
            uniform float _FresnelPower;
            uniform float _RimThreshold;
            uniform half4 _RimColour;

            // Colour of the active light source (directional)
            uniform half4 _LightColor0;

            // Structure defining the vertex data (input)
            struct appdata
            {
                half4 vertex: POSITION;         // Vertex position
                half3 normal: NORMAL;           // Vertex normal
                half2 uv : TEXCOORD0;           // UV coordinates for textures
                half4 tangent : TANGENT;        // Tangent vector for normal mapping
            };

            // Structure defining the interpolated data passed to the fragment shader
            struct v2f
            {
                half4 pos: SV_POSITION;         // Clip-space position
                half2 uv_MainTex : TEXCOORD0;   // UV coordinates for albedo texture
                half2 uv_Normal : TEXCOORD1;    // UV coordinates for normal map
                half2 uv_Emissive : TEXCOORD2;  // UV coordinates for emissive map
                half3 worldPos: TEXCOORD3;      // World-space position of the fragment
                half3x3 TBN : TEXCOORD4;        // Tangent-to-world-space matrix for normal mapping
                SHADOW_COORDS(7)                // Shadow coordinates
                UNITY_FOG_COORDS(8)             // Fog coordinates
            };

            v2f vert(appdata v)
            {
                v2f o;

                // Compute UV coordinates for textures
                o.uv_MainTex = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv_Normal = v.uv * _Normal_ST.xy + _Normal_ST.zw;
                o.uv_Emissive = v.uv * _EmissiveTexture_ST.xy + _EmissiveTexture_ST.zw;

                // Transform vertex position from object space to clip space
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                // Compute world-space normal and tangent
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half3 worldTangent = mul((float3x3)unity_ObjectToWorld, v.tangent);

                // Compute bitangent (cross product of normal and tangent)
                half3 bitangent = cross(worldNormal, worldTangent);
                half3 worldBitangent = mul((float3x3)unity_ObjectToWorld, bitangent);

                // Construct the TBN matrix to transform normal maps from tangent space to world space
                o.TBN = float3x3(worldTangent, worldBitangent, worldNormal);

                // Transfer shadow coordinates
                TRANSFER_SHADOW(o);

                // Transfer fog coordinates
                UNITY_TRANSFER_FOG(o, o.pos);

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                // Sample the emissive map and apply the emissive colour
                half3 emissive = half3(0, 0, 0);
                #ifdef USEEMISSIVE
                emissive = tex2D(_EmissiveTexture, i.uv_Emissive) * _EmissiveColour.rgb;
                #endif

                // Sample the main texture and apply the diffuse colour
                half4 c = tex2D(_MainTex, i.uv_MainTex) * _DiffuseColour;

                // Apply alpha cutoff for transparency (if enabled)
                #ifdef USETRANSPARENT
                clip(c.a - _AlphaCutoff);
                #endif

                // Sample the normal map and apply strength scaling
                half3 normalMap = UnpackNormal(tex2D(_Normal, i.uv_Normal));
                normalMap.xy *= _NormalStrength;

                // Declare light direction and attenuation variables
                half3 l = normalize(_WorldSpaceLightPos0.xyz);
                half atten = 1.0;

                // Transforming normal map vectors from tangent space to world space. TBN * v_world = v_tangent | TBN-1 * v_tangent = v_world
                half3 n = normalize(mul(transpose(i.TBN), normalMap));

                // Calculate view direction and Blinn-Phong half vector
                half3 v = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 h = normalize(l + v);

                // Compute diffuse intensity
                fixed NdotL = saturate(dot(n, l)) * atten;

                // Apply shadow attenuation with a smooth threshold to remove artefacts
                fixed shadow = smoothstep(0.0, 0.02, SHADOW_ATTENUATION(i));

                // Compute final light intensity (optimized over smoothstep)
                float lightIntensity = saturate(NdotL * shadow / 0.001);

                // Blinn-Phong Lighting Model
                fixed Ia = _k.x;    // Ambient term
                fixed Id = _k.y * lightIntensity;   // Diffuse term

                #ifdef SPECULAR
                // Compute specular reflection intensity
                float Is = _k.z * pow(saturate(dot(h, n)), _SpecularExponent * _SpecularExponent);
                Is = smoothstep(0.005, 0.01, Is) * atten;
                #else
                float Is = 0.0;  // Specular is disabled if unchecked
                #endif

                // For simplicity, we just take the colour of the skybox in the fixed upward direction for the sky's contribution.
                half3 skyboxColour = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, float3(0,1,0)).rgb;

                // Compute ambient, diffuse, specular contributions.
                half3 ambient = Ia * c * (UNITY_LIGHTMODEL_AMBIENT + skyboxColour * 0.2);
                half3 diffuse = Id * c * _LightColor0.rgb * shadow;
                half3 specular = Is * _LightColor0.rgb * shadow;

                // Fresnel Rim Lighting (if enabled)
                half4 fresnel;
                #ifdef RIM
                // Compute rim effect based on view and normal dot product
                fixed rimDot = 1 - dot(v, n);
                float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
                rimIntensity = smoothstep(_FresnelPower - 0.01, _FresnelPower + 0.01, rimIntensity);

                #ifdef USERIMCOLOUR
                fresnel = rimIntensity * _RimColour;
                #else
                fresnel = rimIntensity * _LightColor0;
                #endif

                #else
                fresnel = 0;    // No rim lighting if disabled
                #endif

                // Compute final color with diffuse, specular, and fresnel contributions
                half3 finalColour = ambient + diffuse + specular + fresnel;

                // Apply fog effect if necessary
                UNITY_APPLY_FOG(i.fogCoord, finalColour);

                // Return final color with original alpha
                return half4(finalColour + emissive, c.a);
            }
            ENDHLSL

        }

        Pass
        {
            // This pass is run for each additional light in the scene.
            // Only directional and point lights are supported.

            Name "ForwardAdd"
            Tags
            {
                "LightMode" = "ForwardAdd"  // Marks this as a pass for additive lighting
            }
            Cull Off        // Disables back-face culling to ensure proper lighting on both sides
            Blend One One   // Additive blending mode (adds this pass's lighting to the previous result)

            HLSLPROGRAM

            // Shader entry points
            #pragma vertex vertAdd
            #pragma fragment fragAdd

            #pragma multi_compile_fwdadd_fullshadows    // Enable full shadows support for additional lights
            #pragma multi_compile_fog   // Enable Unity fog

            // Enable optional features controlled by shader keywords
            #pragma shader_feature RIM
            #pragma shader_feature SPECULAR
            #pragma shader_feature USETRANSPARENT
            #pragma shader_feature USERIMCOLOUR

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"  // Includes light attenuation calculations

            // ===== Shader Properties (Uniforms) =====

            uniform half4 _DiffuseColour;   // Base diffuse colour multiplier

            // Albedo (diffuse texture)
            uniform sampler2D _MainTex;
            uniform half4 _MainTex_ST;  // Texture scale and offset

            // Transparency settings
            uniform half _AlphaCutoff;

            // Normal map settings
            uniform half4 _Normal_ST;
            uniform sampler2D _Normal;  // Texture scale and offset
            uniform half _NormalStrength;   // Normal map strength multiplier

            // Lighting coefficients (Ambient, Diffuse, Specular)
            uniform half3 _k;

            // Specular lighting parameters
            uniform float _SpecularExponent;

            // Rim lighting parameters
            uniform float _FresnelPower;
            uniform float _RimThreshold;
            uniform half4 _RimColour;

            // Colour of the active light source (point or directional)
            uniform half4 _LightColor0;

            // Structure defining the vertex data (input)
            struct appdata
            {
                half4 vertex: POSITION;     // Vertex position
                half3 normal: NORMAL;       // Vertex normal
                half2 uv : TEXCOORD0;       // UV coordinates for textures
                half4 tangent : TANGENT;    // Tangent vector for normal mapping
            };

            // Structure defining the interpolated data passed to the fragment shader
            struct v2f
            {
                half4 pos : SV_POSITION;      // Clip-space position
                half2 uv_MainTex : TEXCOORD0; // UV coordinates for albedo texture
                half2 uv_Normal : TEXCOORD1;  // UV coordinates for normal map
                half3 worldPos : TEXCOORD2;   // World-space position of the fragment
                half3x3 TBN : TEXCOORD3;      // Tangent-to-world-space matrix for normal mapping
                UNITY_FOG_COORDS(6)           // Fog coordinates
                float3 lightDir : TEXCOORD7;  // Light direction vector
                LIGHTING_COORDS(8, 9)         // Stores light attenuation data for point/spot lights
            };

            v2f vertAdd(appdata v)
            {
                v2f o;

                // Compute UV coordinates for textures
                o.uv_MainTex = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv_Normal = v.uv * _Normal_ST.xy + _Normal_ST.zw;

                // Transform vertex position from object space to clip space
                o.pos = UnityObjectToClipPos(v.vertex);

                // Transform vertex position from object space to world space
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                // Compute world-space normal and tangent
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half3 worldTangent = mul((float3x3)unity_ObjectToWorld, v.tangent);

                // Compute bitangent (cross product of normal and tangent)
                half3 bitangent = cross(worldNormal, worldTangent);
                half3 worldBitangent = mul((float3x3)unity_ObjectToWorld, bitangent);

                // Construct the TBN matrix to transform normal maps from tangent space to world space
                o.TBN = float3x3(worldTangent, worldBitangent, worldNormal);

                // Compute light direction in object space
                o.lightDir = ObjSpaceLightDir(v.vertex).xyz;

                // Transfer fog coordinates
                UNITY_TRANSFER_FOG(o, o.pos);

                // Transfer lighting coordinates (needed for LIGHT_ATTENUATION in the fragment shader to calculate point lighting)
                TRANSFER_VERTEX_TO_FRAGMENT(o);

                return o;
            }

            half4 fragAdd(v2f i) : SV_Target
            {
                // Sample the main texture and apply the diffuse colour
                half4 c = tex2D(_MainTex, i.uv_MainTex) * _DiffuseColour;

                // Apply alpha cutoff for transparency (if enabled)
                #ifdef USETRANSPARENT
                clip(c.a - _AlphaCutoff);
                #endif

                // Sample the normal map and apply strength scaling
                half3 normalMap = UnpackNormal(tex2D(_Normal, i.uv_Normal));
                normalMap.xy *= _NormalStrength;

                // Declare light direction and attenuation variables
                half3 l;
                half atten;

                // Determine light direction and attenuation based on light type
                if (_WorldSpaceLightPos0.w == 0.0)
                {
                    // Directional light: no attenuation, use normalized direction
                    l = normalize(_WorldSpaceLightPos0.xyz);
                    atten = 1.0;
                }
                else
                {
                    // Point light: calculate attenuation based on distance
                    l = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                    atten = LIGHT_ATTENUATION(i);
                }

                // Transforming normal map vectors from tangent space to world space. TBN * v_world = v_tangent | TBN-1 * v_tangent = v_world
                float3 n = normalize(mul(transpose(i.TBN), normalMap));

                // Calculate view direction and Blinn-Phong half vector
                half3 v = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 h = normalize(l + v);

                // Compute diffuse intensity
                fixed NdotL = saturate(dot(n, l)) * atten;

                // Apply shadow attenuation with a smooth threshold to remove artefacts
                fixed shadow = smoothstep(0.0, 0.02, SHADOW_ATTENUATION(i));

                // Compute final light intensity (optimized over smoothstep)
                float lightIntensity = saturate(NdotL * shadow / 0.001);

                // Blinn-Phong Lighting Model
                fixed Id = _k.y * lightIntensity;   // Diffuse term

                #ifdef SPECULAR
                // Compute specular reflection intensity
                float Is = _k.z * pow(saturate(dot(h, n)), _SpecularExponent * _SpecularExponent);
                Is = smoothstep(0., 0.01, Is) * atten;
                #else
                float Is = 0.0; // Specular is disabled if unchecked
                #endif

                // Compute diffuse and specular contributions
                half3 diffuse = Id * c * _LightColor0.rgb * shadow;
                half3 specular = Is * _LightColor0.rgb * shadow;

                // Fresnel Rim Lighting (if enabled)
                half4 fresnel;
                #ifdef RIM
                // Compute rim effect based on view and normal dot product
                fixed rimDot = 1 - dot(v, n);
                float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
                rimIntensity = smoothstep(_FresnelPower - 0.01, _FresnelPower + 0.01, rimIntensity);

                #ifdef USERIMCOLOUR
                fresnel = rimIntensity * _RimColour;
                #else
                fresnel = rimIntensity * _LightColor0;
                #endif

                #else
                fresnel = 0;    // No rim lighting if disabled
                #endif

                // Compute final color with diffuse, specular, and fresnel contributions
                half3 finalColour = diffuse + specular + fresnel;

                // Apply fog effect if necessary
                UNITY_APPLY_FOG(i.fogCoord, finalColour);

                // Return final color with original alpha
                return half4(finalColour, c.a);
            }
            ENDHLSL

        }
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }

    Fallback "Diffuse"

}