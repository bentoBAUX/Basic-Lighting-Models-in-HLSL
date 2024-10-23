# *README IS WORK-IN-PROGRESS*
# Lighting Models in Unity using HLSL

This repository contains several basic lighting models implemented in Unity using HLSL (High-Level Shading Language).
Each lighting model is explained with its corresponding mathematical formulation and a breakdown of how it's implemented
in code.

## Table of Contents

- [Overview](#overview)
- [Implemented Lighting Models](#implemented-lighting-models)
    - [Lambert Lighting](#1-lambert-lighting)
    - [Gouraud Shading](#2-gouraud-shading)
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

$\quad k_s$ is the specular reflection coefficient. <br/>
$\quad N$ is the surface normal.<br/>
$\quad H$ is the halfway vector.<br/>
$\quad \alpha$ is the shininess exponent (controls the highlight size).<br/>


#### Code Snippet
```hlsl
half3 h = normalize(l + v);                            // Compute halfway vector (both l and v are already normalised)

float Is = _k.z * pow(saturate(dot(h, n)), _SpecularExponent); // Calculate the specular intensity using Blinn-Phong model
```

### 5. Flat Shading

#### Overview
Flat shading with Blinn-Phong lighting works by assigning a single normal to an entire triangle, rather than per vertex. In this case, the normal is calculated using the cross product of the screen-space derivatives of the triangle’s world positions, ensuring it represents the entire face. This normal is then used in the Blinn-Phong lighting model to calculate the lighting for all pixels within the triangle. Since the same normal is applied across the entire surface, the specular highlights and shading appear flat and uniform for each triangle, giving the model a faceted look while still using Blinn-Phong's lighting principles.

#### Mathematical Formula
```math
N = \frac{\text{cross}\left(\frac{\partial P}{\partial y}, \frac{\partial P}{\partial x}\right)}{\|\text{cross}\left(\frac{\partial P}{\partial y}, \frac{\partial P}{\partial x}\right)\|}
```

Where: 

$\quad P$ is the world position of the vertex.<br/>
$\quad \frac{\partial P}{\partial x}$ is the partial derivative of the world position in the x direction.<br/>
$\quad \frac{\partial P}{\partial y}$ is the partial derivative of the world position in the y direction.<br/>
$\quad N$ is the flat normal for the triangle.<br/>


#### Code Snippet
```hlsl
float3 worldNormal = normalize(cross(ddy(i.worldPos), ddx(i.worldPos))); // Calculate the flat normal for the triangle using screen-space derivatives
half3 n = normalize(worldNormal);                                        // Ensure the normal is a unit vector for lighting calculations                     
```

### 6. Toon Shading

#### Overview
The Lambert lighting model, also known as diffuse lighting, calculates the illumination of a surface by assuming light is scattered equally in all directions. This is suitable for matte surfaces.

#### Mathematical Formula
```math
N = \frac{\text{cross}\left(\frac{\partial P}{\partial y}, \frac{\partial P}{\partial x}\right)}{\|\text{cross}\left(\frac{\partial P}{\partial y}, \frac{\partial P}{\partial x}\right)\|}
```

#### Code Snippet
```hlsl
float3 lightDir = normalize(_LightPosition - worldPos);
float NdotL = max(0, dot(normal, lightDir));
float3 diffuse = _LightColor * NdotL;
```

### 7. Oren-Nayar

#### Overview
The Lambert lighting model, also known as diffuse lighting, calculates the illumination of a surface by assuming light is scattered equally in all directions. This is suitable for matte surfaces.

#### Mathematical Formula

$$\left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)$$

#### Code Snippet
```hlsl
float3 lightDir = normalize(_LightPosition - worldPos);
float NdotL = max(0, dot(normal, lightDir));
float3 diffuse = _LightColor * NdotL;
```

### 8. Cook-Torrance

#### Overview
The Lambert lighting model, also known as diffuse lighting, calculates the illumination of a surface by assuming light is scattered equally in all directions. This is suitable for matte surfaces.

#### Mathematical Formula

$$\left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)$$

#### Code Snippet
```hlsl
float3 lightDir = normalize(_LightPosition - worldPos);
float NdotL = max(0, dot(normal, lightDir));
float3 diffuse = _LightColor * NdotL;
```


