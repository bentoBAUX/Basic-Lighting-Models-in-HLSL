# *README IS WORK-IN-PROGRESS*
# Lighting Models in Unity using HLSL

This repository contains several basic lighting models implemented in Unity using HLSL (High-Level Shading Language).
Each lighting model is explained with its corresponding mathematical formulation and a breakdown of how it's implemented
in code.

## Table of Contents

- [Overview](#overview)
- [Implemented Lighting Models](#implemented-lighting-models)
    - [Lambert Lighting](#1-lambert-lighting)
    - [Gouraud-Phong Lighting](#2-gouraud-phong-lighting)
    - [Phong Lighting](#3-phong-lighting)
    - [Blinn-Phong Lighting](#4-blinn-phong-lighting)
    - [Flat Shading](#5-flat-shading)
    - [Toon Shading](#6-toon-shading)
    - [Oren-Nayar](#7-oren-nayar)
    - [Cook-Torrance](#8-cook-torrance)
- [Usage](#usage)
- [Installation](#installation)
- [Contributing](#contributing)
- [License](#license)

## Overview

This project demonstrates different lighting techniques used in real-time computer graphics. The models implemented
cover a range from basic diffuse lighting like Lambertian and Phong Lighting to more advanced techniques like Oren-Nayar and Cook-Torrance.

All shaders are written in HLSL and designed to be used in Unity’s Built In Rendering Pipeline. Below is an overview of the
implemented lighting models, along with the mathematical concepts and code snippets for each.

## Implemented Lighting Models

### 1. Lambert Lighting

#### Overview

The Lambertian lighting, named after Johann Heinrich Lambert, is the most fundamental model for simulating diffuse reflection in computer graphics. It assumes that light is scattered uniformly in all directions from each point on the surface, which makes it ideal for modelling matte materials such as unpolished surfaces like chalk or clay. The model’s simplicity lies in the fact that the intensity of reflected light is determined solely by the cosine of the angle between the surface normal and the direction of incoming light, a principle known as Lambert’s Cosine Law. 

In this example, the lighting will be calculated in the vertex shader.

#### Mathematical Formula

```math
I_d = k_d * n \cdot l
```

```math
C_r = I_d * C_s * I_l
```
Where:

$\quad$ $k_d$ is the diffuse coefficient, controlling the strength of $I_d$. <br/>
$\quad$ $n$ is the surface’s unit normal vector, pointing perpendicular to the surface.<br/>
$\quad$ $l$ is the unit vector in the direction of the incoming light.<br/>
$\quad$ $I_d$ represents the reflected diffuse light intensity. <br/>
<br/>
$\quad$ $C_s$ is the surface's colour.<br/>
$\quad$ $I_l$ is the intensity (and colour) of the incoming light.<br/>
$\quad$ $C_r$ is the final observed colour.<br/>

#### Code Snippet

```hlsl
half3 n = UnityObjectToWorldNormal(v.normal);       // Converting vertex normals to world normals.
half3 l = normalize(_WorldSpaceLightPos0.xyz);      // Normalises the light direction vector.

float Id = kD * saturate(dot(n, l));                // saturate() to clamp dot product values between 0 and 1 to prevent negative light intensities.
finalColour = Id * _DiffuseColour * _LightColor0;   // Multiplying I with the surface's colour and the light's colour to get the final observed colour.
```
---
### 2. Gouraud-Phong Lighting

#### Overview

Gouraud shading, named after the French computer scientist Henri Gouraud, enhances Lambertian lighting by incorporating specular and ambient terms from Phong lighting. However unlike Phong Lighting, lighting calculations are performed at the vertices in the vertex shader, and the resulting colour values are interpolated across the surface of the polygon during rasterisation, which happens in the fragment shader.

While efficient, Gouraud shading can lead to poor shading results, especially in low-poly models, due to the per-vertex lighting calculation. This approach may cause the loss of finer lighting details, such as sharp specular highlights, since those details are "smoothed out" through interpolation across the surface.

#### Mathematical Formula
```math
I_a = k_a
```
```math
I_d = k_d * n \cdot l
```
```math
I_s = k_s * (r \cdot v)^s
```
<br/>

```math
C_r = (I_a + I_d + I_s) * C_s * I_l
```

Where:

$\quad$ $k_a$, $k_d$, $k_s$ are the coefficients that control the strength of $I_a$, $I_d$, $I_s$ respectively. <br/>
$\quad$ $n$ is the surface’s unit normal vector, pointing perpendicular to the surface.<br/>
$\quad$ $l$ is the unit vector in the direction of the incoming light.<br/>
$\quad$ $r$ is the reflection unit vector, which represents the direction that the light reflects off the surface. <br/>
$\quad$ $v$ is the view vector, which represents the direction towards the camera or the viewer. <br/>
$\quad$ $s$ is the specular exponent (higher values lead to sharper highlights). <br/> <br/>

$\quad$ $I_a$ represents the reflected ambient light intensity. <br/>
$\quad$ $I_d$ represents the reflected diffuse light intensity. <br/>
$\quad$ $I_s$ represents the reflected specular light intensity. <br/>  <br/>

$\quad$ $C_s$ is the surface's colour.<br/>
$\quad$ $I_l$ is the intensity (and colour) of the incoming light.<br/>
$\quad$ $C_r$ is the final observed colour.<br/>

#### Code Snippet

```hlsl
float3 worldPos = mul(unity_ObjectToWorld, vx.vertex).xyz; // Transform vertex position to world space
half3 n = UnityObjectToWorldNormal(vertex.normal);         // Transform normal to world space
half3 l = normalize(_WorldSpaceLightPos0.xyz);             // Get normalized light direction
half3 r = 2.0 * dot(n, l) * n - l;                         // Calculate reflection vector
half3 v = normalize(_WorldSpaceCameraPos - worldPos);      // Get normalized view direction

float Ia = _k.x;                                           // Ambient light intensity (_k.x = ambient coefficient)
float Id = _k.y * saturate(dot(n, l));                     // Diffuse light intensity using Lambert's law
float Is = _k.z * pow(saturate(dot(r, v)), _SpecularExponent); // Specular light intensity using Phong model

float3 ambient = Ia;                                       // Calculate ambient lighting
float3 diffuse = Id * _LightColor0.rgb;                    // Calculate diffuse lighting
float3 specular = Is * _LightColor0.rgb;                   // Calculate specular lighting

o.color = fixed4((ambient + diffuse + specular) * _DiffuseColour.rgb, 1.0); // Output final colour with full opacity
```

### 3. Phong Lighting

#### Overview
Phong lighting builds upon the same mathematical principles as Gouraud-Phong lighting but differs in its implementation within shaders. While Gouraud shading performs the lighting calculation per vertex in the vertex shader and then interpolates the resulting colours across a triangle, Phong shading interpolates **surface normals** across the triangle and performs the lighting calculations per pixel in the fragment shader. This allows for a smoother and more detailed lighting effecs, paricularly for specular highlights and shiny surfaces.

By performing per-pixel lighting, Phong shading offers a visually more realistic appearance, especially when dealing with curved surfaces or complex lighting conditions. However, the per-pixel lighting calculation coms at a higher computational cost, especially for large triangles or high-resolution renderings.

#### Mathematical Formula

*Same as in Gouraud shading*

#### Code Snippet
```hlsl
// Same as in Gouraud shading but calculations are performed in the fragment shader.
```

### 4. Blinn-Phong Lighting

#### Overview
Blinn-Phong shading is a refined version of Phong shading that optimises the calculation of specular highlights. Instead of using the reflection vector like Phong shading, it calculates a halfway vector, which is the vector between the light direction and the view direction. This makes the specular calculation more efficient, reducing the computational cost while maintaining similar visual quality, especially for smooth surfaces. 

This lighting model also improves the visual quality of specular reflections as documented [here](https://learnopengl.com/Advanced-Lighting/Advanced-Lighting) in detail.

#### Mathematical Formula

```math
H = \frac{L + V}{\|L + V\|}
```
<br/>

```math
I_{\text{s}} = k_s \cdot (N \cdot H)^{\alpha}
```

Where: 

$\quad$ $k_s$ is the specular reflection coefficient. <br/>
$\quad$ $N$ is the surface normal.<br/>
$\quad$ $H$ is the halfway vector.<br/>
$\quad$ $\alpha$ is the shininess exponent (controls the highlight size).<br/>


#### Code Snippet
```hlsl
half3 h = normalize(l + v);                            // Compute halfway vector (both l and v are already normalised)
...
float Is = _k.z * pow(saturate(dot(h, n)), _SpecularExponent); // Calculate the specular intensity using Blinn-Phong model
...
```

### 5. Flat Shading

#### Overview
Flat shading with Blinn-Phong lighting works by assigning a single normal to an entire triangle, rather than per vertex. In this case, the normal is calculated using the cross product of the screen-space derivatives of the triangle’s world positions, ensuring it represents the entire face. This normal is then used in the Blinn-Phong lighting model to calculate the lighting for all pixels within the triangle. Since the same normal is applied across the entire surface, the specular highlights and shading appear flat and uniform for each triangle, giving the model a faceted look while still using Blinn-Phong's lighting principles.

#### Mathematical Formula
```math
N = \frac{\text{cross}\left(\frac{\partial P}{\partial y}, \frac{\partial P}{\partial x}\right)}{\|\text{cross}\left(\frac{\partial P}{\partial y}, \frac{\partial P}{\partial x}\right)\|}
```

Where: 

$\quad$ $P$ is the world position of the vertex.<br/>
$\quad$ $\frac{\partial P}{\partial x}$ is the partial derivative of the world position in the x direction.<br/>
$\quad$ $\frac{\partial P}{\partial y}$ is the partial derivative of the world position in the y direction.<br/>
$\quad$ $N$ is the flat normal for the triangle.<br/>


#### Code Snippet
```hlsl
float3 worldNormal = normalize(cross(ddy(i.worldPos), ddx(i.worldPos))); // Calculate the flat normal for the triangle using screen-space derivatives
half3 n = normalize(worldNormal);                                        // Ensure the normal is a unit vector for lighting calculations
...
```

### 6. Toon Shading

#### Overview
Toon shading, influenced by Japanese anime and Western animation, uses stylised lighting to give 3D graphics a 2D, hand-drawn look. The math behind this shader builds, too, on the Blinn-Phong lighting model, with smoothstep functions to create clear yet smooth lighting bands. For additional lights (directional, point, and spot), I used an additive approach to allow multiple sources to interact naturally without heavy performance costs. For the extra stylised look, I used a Fresnel-based approach for rim lighting which I learned from [here](https://roystan.net/articles/toon-shader/), where light wraps around the edges of an object based on the viewing angle, creating a subtle highlight that enhances shape definition. Combined with textures, normal maps, and outlines for clear borders, this setup brings a polished comic-book feel. The full repository will be available soon.


#### Mathematical Formula

*Smoothstep Diffuse and Specular*

$\quad$ For the shader's signature distinction between highlights and shadows, smoothstep is applied to both diffuse and specular intensities:

$$
I_d = \text{smoothstep}(0.005, 0.01, I_d)
$$

$$
I_s = \text{smoothstep}(0.005, 0.01, I_s)
$$

$\quad$ where $I_d$ is the diffuse intensity and $I_s$ is the specular intensity from [Blinn-Phong](#4-blinn-phong-lighting).

*Rim Lighting (Fresnel)*

$\quad$ Rim lighting is calculated based on a Fresnel approximation, producing an intensity based on view angle and light direction:

$$
\text{RimIntensity} = (1 - v \cdot n) \cdot (n \cdot l)^{\text{RimThreshold}} 
$$

$\quad$ A smoothstep function refines the rim lighting for soft transitions:

$$
\text{RimIntensity} = \text{smoothstep}(\text{FresnelPower} - 0.01, \text{FresnelPower} + 0.01, \text{RimIntensity}) * \text{LightColor0}
$$

*Final Colour Calculation with Rim Light*

$\quad$ The final colour calculation, including ambient, diffuse, specular, and rim lighting, is:

$$
C_r = (\text{ambient} + \text{diffuse} + \text{specular} + \text{rim})
$$

$\quad$ This incorporates the rim lighting effect, enhancing edge definition based on the viewing angle, giving the shader a distinct stylised depth.

#### Code Snippet
```hlsl
// Smoothstep Diffuse Calculation
...
Id = smoothstep(0.005, 0.01, Id);                                   // Apply smoothstep to diffuse term

// Smoothstep Specular Calculation
...
Is = smoothstep(0.005, 0.01, Is);                                   // Apply smoothstep to specular term

// Fresnel Rim Lighting
fixed rimDot = 1 - dot(v, n);                                       // Fresnel-based view-angle calculation
float rimIntensity = rimDot * pow(NdotL, _RimThreshold);            // Adjust intensity with threshold
rimIntensity = smoothstep(_FresnelPower - 0.01, _FresnelPower + 0.01, rimIntensity); // Smooth transition for rim
half4 rim = rimIntensity * _LightColor0;                            // Apply Fresnel effect as rim light

// Final Colour Calculation
half3 lighting = ambient + diffuse + specular + rim;                // Combine diffuse, specular, and rim lighting
...
```

### 7. Oren-Nayar

#### Overview
The Oren-Nayar model is a reflection model developed by Michael Oren and Shree K. Nayar to extend simple Lambertian shading for rough, diffuse surfaces. Unlike Lambertian shading, which assumes light scatters evenly in all directions, Oren-Nayar calculates how surface roughness affects light scattering, using parameters like the viewer's angle, light direction, and surface roughness, σ. This model captures realistic diffuse behaviour, especially for materials like cloth or plaster, where surface microstructures cause directional variation in brightness. By introducing these variables, Oren-Nayar enables more realistic shading in computer graphics for non-smooth, matte surfaces. My implementation directly mirrors the standard calculations outlined on [Wikipedia](https://en.wikipedia.org/wiki/Oren–Nayar_reflectance_model), using the same parameters and cosine terms to enhance realism in shading effects for rough, matte surfaces.

#### Mathematical Formula

The reflected light $L_r$ is given by

```math
L_r = L_1 + L_2
```

and the direct illumination term, $L_1$, and the term $L_2$, which accounts for light bounces between the facets, are defined as follows.

```math
L_1 = \frac{\rho}{\pi}E_0\cos(\theta_i)(C_1 + C_2\cos(\phi_i-\phi_r)\tan(\beta) + C_3(1-|(cos(\phi_i-\phi_r)|)\tan(\frac{\alpha+\beta}{2})
```
```math
L_2 = 0.17\frac{\rho^2}{\pi}E_0\cos(\theta_i)\frac{\sigma^2}{\sigma^2 + 0.13}[1-\cos(\phi_i-\phi_r)(\frac{2\beta}{\pi})^2]
```

Where: <br/>
<br/>

```math
C_1 = 1 - 0.5\frac{\sigma^2}{\sigma^2 + 0.33}
```
```math
C_2 = \begin{cases}
0.45 \frac{\sigma^2}{\sigma^2 + 0.09} \sin \alpha & \text{if } \cos(\phi_i - \phi_r) \geq 0, \\
0.45 \frac{\sigma^2}{\sigma^2 + 0.09} \left( \sin \alpha - \left( \frac{2 \beta}{\pi} \right)^3 \right) & \text{otherwise,}
\end{cases}
```
```math
C_3 = 0.125\frac{\sigma^2}{\sigma^2 + 0.09}(\frac{4\alpha\beta}{\pi^2})^2
```
```math
\alpha = max(\theta_i, \theta_r),
```
```math
\beta = min(\theta_i, \theta_r)
```
and <br/><br/>
$\quad$ $E_0$ is the irradiance when the facet is illuminated head-on. <br/>
$\quad$ $\rho$ is the albedo of surface. <br/>
$\quad$ $\sigma$ is the roughness of surface. <br/>
$\quad$ $\theta_i$ is the angle between the incident light and the surface's normal.<br/>
$\quad$ $\theta_r$ is the angle between the reflected light and the surface's normal.<br/>
$\quad$ $\phi_i$ is the azimuthal angle of the incident light with respect to the surface's normal.<br/>
$\quad$ $\phi_r$ is the azimuthal angle of the reflected light with respect to the surface's normal.<br/>
#### Code Snippet
```hlsl
...
float3 E0 = _LightColor0.rgb * saturate(dot(n, l)); 

// Calculate angles of incidence and reflection
float theta_i = acos(dot(l, n));
float theta_r = acos(dot(r, n));

// Project light and view vectors onto the tangent plane to calculate cosPhi, the cosine of the azimuthal angle (difference in orientation) between projected light and view
float3 Lproj = normalize(l - n * NdotL);
float3 Vproj = normalize(v - n * NdotV + 1); // +1 to remove a visual artifact
float cosPhi = dot(Lproj, Vproj);

// Determine max and min angles for roughness calculation
float alpha = max(theta_i, theta_r);
float beta = min(theta_i, theta_r);
float sigmaSqr = _sigma * _sigma;

// Calculate C1, C2, C3
float C1 = 1 - 0.5 * (sigmaSqr / (sigmaSqr + 0.33));
float C2 = cosPhi >= 0 ? 0.45 * (sigmaSqr / (sigmaSqr + 0.09)) * sin(alpha) 
            : 0.45 * (sigmaSqr / (sigmaSqr + 0.09)) * (sin(alpha) - pow((2.0 * beta) / UNITY_PI, 3.0));
float C3 = 0.125 * (sigmaSqr / (sigmaSqr + 0.09)) * pow((4.0 * alpha * beta) / (UNITY_PI * UNITY_PI), 2.0);

// Compute direct illumination term L1 and interreflected term L2
float3 L1 = _DiffuseColour * E0 * cos(theta_i) * (C1 + (C2 * cosPhi * tan(beta)) + (C3 * (1.0 - abs(cosPhi)) * tan((alpha + beta) / 2.0)));
float3 L2 = 0.17 * (_DiffuseColour * _DiffuseColour) * E0 * cos(theta_i) * (sigmaSqr / (sigmaSqr + 0.13)) 
            * (1.0 - cosPhi * pow((2.0 * beta) / UNITY_PI, 2.0));

// Final light intensity
float3 L = (L1 + L2);
...
```

### 8. Cook-Torrance

#### Overview
The Cook-Torrance model is a reflection model developed by Robert Cook and Kenneth Torrance in 1982, designed to simulate specular reflection on rough, shiny surfaces with a level of realism that surpasses simpler models like Phong or Blinn-Phong. While those earlier models treat surfaces as smooth, Cook-Torrance assumes a surface is made up of countless microscopic facets, each acting as a tiny mirror. This model calculates specular reflection based on factors like viewing angle, light direction, and a roughness parameter, similar to Oren-Nayar but tailored to specular highlights.

Core components include the Fresnel effect, which increases reflectivity at grazing angles; the Geometry Term, which accounts for shadowing between facets; and the Normal Distribution Function (NDF), describing the spread of facet orientations, with rougher surfaces creating broader specular highlights. By combining Cook-Torrance for specular reflection with Oren-Nayar for diffuse reflection, this approach captures the nuanced behaviour of light on both matte and glossy surfaces. My implementation mirrors standard calculations as described [here](https://en.wikipedia.org/wiki/Specular_highlight#Cook%E2%80%93Torrance_model), including the Fresnel-Schlick approximation and GGX distribution, for lifelike specular effects on rough surfaces.

#### Mathematical Formula

The Cook-Torrance model implements the specular term so:

```math
specular = \frac{FDG}{\pi(V \cdot N)(N \cdot L)}
```

Where: <br/>
<br/>

F is the Fresnel term of this equation, approximated using [Schlick's approximation](https://en.wikipedia.org/wiki/Schlick%27s_approximation) for performance reasons. For simplicity, the index of refraction $n_1$ is up to the user to set, and $n_2$ is set to one, as it is the refraction index of air.

$R_0$ is therefore our reflective coefficient for the light vector parallel to the normal. 

$\cos(\theta)$ will be the dot product between the view vector and halfway vector.

```math
F = R_0 + (1-R_0)(1-\cos(\theta))^5
```
<br/>

```math
R_0 = (\frac{n_1 - n_2}{n_1 + n_2})^2
```

D is the Beckmann distribution factor, where $m$ is in this case the roughness of the material (see Wikipedia for detailed explanation) and $\alpha$ is the arccosine of the dot product between the surface normal vector and the halfway vector that we calculated in Blinn Phong.

```math
D = \frac{exp(\frac{\tan^{2}(\alpha)}{m^2})}{\pi m^2\cos^{4}(\alpha)}
```

and G is our geometric attenuation term, where $L$, $N$, $H$ and $V$ are the vector to the light source, surface normal, halfway vector and view direction respectively.

```math
G = min(1, \frac{2(H \cdot N)(V \cdot N)}{V \cdot H}, \frac{2(H \cdot N)(L \cdot N)}{V \cdot H})
```

#### Code Snippet
```hlsl
...                                                        // Oren-Nayar above...
float NdotH = saturate(dot(n, h));                         // Dot product between normal and halfway vector, clamped to [0,1]
float a = acos(NdotH);                                     // Convert NdotH to an angle in radians
float m = clamp(sigmaSqr, 0.01, 1);                        // Clamp roughness value to avoid extreme cases
float exponent = exp(-tan(a) * tan(a) / (m * m));          // Exponent term for Beckmann distribution
float D = clamp(exponent / (UNITY_PI * m * m * pow(NdotH, 4)), 0.01, 1e30);  // Beckmann distribution function (D)

// Base Fresnel reflectance (F0) calculated from the refractive index
float F0 = ((_RefractiveIndex - 1) * (_RefractiveIndex - 1)) / ((_RefractiveIndex + 1) * (_RefractiveIndex + 1));

// Fresnel term (F) using Schlick's approximation
float F = F0 + (1 - F0) * pow(1 - clamp(dot(v, h), 0, 1), 5);

// Geometry term (G) using Smith's approximation
float G1 = 2 * dot(h, n) * dot(n, v) / dot(v, h);
float G2 = 2 * dot(h, n) * dot(n, l) / dot(v, h);
float G = min(1, min(G1, G2));                             // Final geometry term (G) as the minimum of G1 and G2

// Specular reflection component
float specular = ((D * G * F) / (4 * dot(n, l) * dot(n, v))) * _LightColor0;

// Sample ambient light from skybox and calculate overall ambient light
float3 skyboxColor = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, float3(0,1,0)).rgb;
fixed3 ambient = 0.5 * (UNITY_LIGHTMODEL_AMBIENT + _LightColor0 + skyboxColor);

// Combine ambient and specular components with a metallic factor and return final color
return float4(ambient + lerp(L, specular, _Metallic), 1.0);

```


