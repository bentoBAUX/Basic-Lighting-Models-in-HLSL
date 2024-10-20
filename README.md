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
I_d = \mathbf{n} \cdot \mathbf{l} 
```

```math
B_D = I_d * C_s * I_l
```
Where:

$\quad$ $n$ is the surface’s unit normal vector, pointing perpendicular to the surface.<br/>
$\quad$ $l$ is the unit vector in the direction of the incoming light.<br/>
$\quad$ $I_d$ represents the reflected diffuse light intensity. <br/>
<br/>
$\quad$ $C_s$ is the surface's colour.<br/>
$\quad$ $I_l$ is the intensity (and colour) of the incoming light.<br/>
$\quad$ $B_D$ is the final observed colour.<br/>

#### Code Snippet

```hlsl
half3 n = UnityObjectToWorldNormal(v.normal); // Converting vertex normals to world normals.
half3 l = normalize(_WorldSpaceLightPos0.xyz); // Normalises the light direction vector.

float Id = kD * saturate(dot(n, l)); // kD controls the strength of Id. saturate() to clamp dot product values between 0 and 1 to prevent negative light intensities.
finalColour = Id * _DiffuseColour * _LightColor0; // Multiplying I with the surface's colour and the light's colour to get the final observed colour.
```
---
### 2. Gouraud-Phong Lighting

#### Overview

Gouraud shading, named after the French computer scientist Henri Gouraud, enhances Lambertian lighting by incorporating specular and ambient terms. As with Lambert shading, lighting calculations are performed at the vertices in the vertex shader, and the resulting colour values are interpolated across the surface of the polygon during rasterisation, which happens in the fragment shader.

While efficient, Gouraud shading can lead to poor shading results, especially in low-poly models, due to the per-vertex lighting calculation. This approach may cause the loss of finer lighting details, such as sharp specular highlights, since those details are "smoothed out" through interpolation across the surface.

#### Mathematical Formula

$$\left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)$$

#### Code Snippet

```hlsl
float3 lightDir = normalize(_LightPosition - worldPos);
float NdotL = max(0, dot(normal, lightDir));
float3 diffuse = _LightColor * NdotL;
```

### 3. Phong Lighting

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

### 4. Blinn-Phong Lighting

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

### 5. Flat Shading

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

### 6. Toon Shading

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


