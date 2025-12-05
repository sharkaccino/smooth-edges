#version 120

uniform int isEyeInWater;
uniform int renderStage;

varying vec4 color;
varying vec3 worldPos;

void main() {
  vec4 albedo = color;

  if (isEyeInWater == 1) {
    discard;
  }

  gl_FragData[0] = albedo;
}