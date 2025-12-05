#version 120

uniform int biome_category;
uniform int isEyeInWater;
uniform int renderStage;
uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;

varying vec4 color;
varying vec3 worldPos;

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz);
  float factor = fogify(max(upDot * 10 - 0.66, 0.0), 2);
	return mix(skyColor, fogColor, factor);
}

vec3 screenToView(vec3 screenPos) {
	vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * ndcPos;
	return tmp.xyz / tmp.w;
}

void main() {
  vec4 albedo = color;

  if (isEyeInWater == 1) {
    discard;
  }

  if (biome_category == CAT_THE_END) {
    discard;
  }

  if (renderStage == MC_RENDER_STAGE_SKY) {
    vec3 pos = screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
	  albedo = vec4(calcSkyColor(normalize(pos)), 1.0);
  }

  gl_FragData[0] = albedo;
}