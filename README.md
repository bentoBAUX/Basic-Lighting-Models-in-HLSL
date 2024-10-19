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
cover a range from basic diffuse lighting to more advanced techniques like Blinn-Phong and Toon shading.

All shaders are written in HLSL and designed to be used in Unity’s rendering pipeline. Below is an overview of the
implemented lighting models, along with the mathematical concepts and code snippets for each.

## Implemented Lighting Models

### 1. Lambert Lighting

#### Overview

The Lambert lighting model, also known as diffuse lighting, calculates the illumination of a surface by assuming light
is scattered equally in all directions. This is suitable for matte surfaces.

#### Mathematical Formula

\[
I_{\text{diffuse}} = I_{\text{light}} \cdot \max(0, \mathbf{N} \cdot \mathbf{L})
\]
Where:

- \( \mathbf{N} \) is the surface normal
- \( \mathbf{L} \) is the direction of the light source
- \( I_{\text{light}} \) is the intensity of the light

#### Code Snippet

```hlsl
float3 lightDir = normalize(_LightPosition - worldPos);
float NdotL = max(0, dot(normal, lightDir));
float3 diffuse = _LightColor * NdotL;
```

### 2. Gouraud-Phong Lighting

#### Overview

The Lambert lighting model, also known as diffuse lighting, calculates the illumination of a surface by assuming light
is scattered equally in all directions. This is suitable for matte surfaces.

#### Mathematical Formula

\[
I_{\text{diffuse}} = I_{\text{light}} \cdot \max(0, \mathbf{N} \cdot \mathbf{L})
\]
Where:

- \( \mathbf{N} \) is the surface normal
- \( \mathbf{L} \) is the direction of the light source
- \( I_{\text{light}} \) is the intensity of the light

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
\[
I_{\text{diffuse}} = I_{\text{light}} \cdot \max(0, \mathbf{N} \cdot \mathbf{L})
\]
Where:
- \( \mathbf{N} \) is the surface normal
- \( \mathbf{L} \) is the direction of the light source
- \( I_{\text{light}} \) is the intensity of the light

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
\[
I_{\text{diffuse}} = I_{\text{light}} \cdot \max(0, \mathbf{N} \cdot \mathbf{L})
\]
Where:
- \( \mathbf{N} \) is the surface normal
- \( \mathbf{L} \) is the direction of the light source
- \( I_{\text{light}} \) is the intensity of the light

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
\[
I_{\text{diffuse}} = I_{\text{light}} \cdot \max(0, \mathbf{N} \cdot \mathbf{L})
\]
Where:
- \( \mathbf{N} \) is the surface normal
- \( \mathbf{L} \) is the direction of the light source
- \( I_{\text{light}} \) is the intensity of the light

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
\[
I_{\text{diffuse}} = I_{\text{light}} \cdot \max(0, \mathbf{N} \cdot \mathbf{L})
\]
Where:
- \( \mathbf{N} \) is the surface normal
- \( \mathbf{L} \) is the direction of the light source
- \( I_{\text{light}} \) is the intensity of the light

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
\[
I_{\text{diffuse}} = I_{\text{light}} \cdot \max(0, \mathbf{N} \cdot \mathbf{L})
\]
Where:
- \( \mathbf{N} \) is the surface normal
- \( \mathbf{L} \) is the direction of the light source
- \( I_{\text{light}} \) is the intensity of the light

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
\[
I_{\text{diffuse}} = I_{\text{light}} \cdot \max(0, \mathbf{N} \cdot \mathbf{L})
\]
Where:
- \( \mathbf{N} \) is the surface normal
- \( \mathbf{L} \) is the direction of the light source
- \( I_{\text{light}} \) is the intensity of the light

#### Code Snippet
```hlsl
float3 lightDir = normalize(_LightPosition - worldPos);
float NdotL = max(0, dot(normal, lightDir));
float3 diffuse = _LightColor * NdotL;
```


