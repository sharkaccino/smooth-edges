#version 120

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

#ifdef GLSLANG
#extension GL_GOOGLE_include_directive : enable
#endif

// Get Entity id
attribute float mc_Entity;

// Model * view matrix and its inverse
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform int renderStage;

// Pass vertex information to fragment shader
varying vec4 fragColor;
varying vec2 texCoord0;
varying vec2 texCoord1;
varying vec3 worldPos;

uniform int frameCounter;

// Declare viewWidth and viewHeight as uniform
uniform float viewWidth;  
uniform float viewHeight;

#include "/bsl_lib/util/jitter.glsl"
#include "/lib/oldLighting.glsl"

void main() {
    // Calculate world space position
    worldPos = (gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex).xyz;

    // Output position and fog to fragment shader
    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(worldPos, 1.0);

    // Calculate view space normal
    vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
    normal = (mc_Entity == 1.0) ? vec3(0.0, 1.0, 0.0) : (gbufferModelViewInverse * vec4(normal, 0.0)).xyz;

    // Output color with lighting to fragment shader
    if (renderStage == MC_RENDER_STAGE_PARTICLES) {
        fragColor = gl_Color;
    } else {
        fragColor = applyOldLighting(gl_Color, worldPos, normal);
    }

    // Output texture coordinates to fragment shader
    texCoord0 = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    texCoord1 = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    // Apply temporal anti-aliasing jitter
    gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}