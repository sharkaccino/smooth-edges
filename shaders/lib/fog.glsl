uniform int isEyeInWater;
uniform vec3 fogColor;
uniform float fogStart;
uniform float fogEnd;
uniform int fogShape;
uniform int fogMode;

#ifdef DHTWEAK
uniform vec3 skyColor;
uniform int dhRenderDistance;
uniform float blindness;
#endif

// int GL_EXP = 2048;
// int GL_EXP2 = 2049;
// int GL_LINEAR = 9729;

int spherical = 0;
int cylindrical = 1;

// currently, this only uses linear mode for calculating fog, 
// but there are technically two other modes: GL_EXP and GL_EXP2. 
// from the testing i've done so far, most fog in minecraft seems 
// to just stick with linear, and linear is already close enough 
// to the majority of fog effects that we *probably* don't even 
// need to worry about supporting these different modes.

vec4 applyFog(vec4 albedo, vec3 pos) {
  vec4 newAlbedo = albedo;
  vec3 finalFogColor = fogColor;

  vec3 fogCoord = vec3(pos.x, 0, pos.z);
  if (fogShape == spherical) {
    fogCoord.y = pos.y;
  }

  float finalFogStart = fogStart;
  float finalFogEnd = fogEnd;

  #ifdef DHTWEAK
  // TODO: make these values configurable
  if (isEyeInWater == 0) {
    // based on DH's default values
    finalFogStart = mix(dhRenderDistance * 0.4, fogStart, blindness);
    finalFogEnd = mix(dhRenderDistance, fogEnd, blindness);
  }
  #endif

  #ifdef SKY
  if (isEyeInWater == 0) {
    return albedo;
  } else {
    discard;
  }
  #endif

  // if (fogMode == GL_EXP) {
  //   newAlbedo = vec4(1, 0, 0, 1);
  // } else if (fogMode == GL_EXP2) {
  //   newAlbedo = vec4(0, 1, 0, 1);
  // } else {
  //   newAlbedo = vec4(0, 0, 1, 1);
  // }

  float fogFactor = smoothstep(finalFogStart, finalFogEnd, length(fogCoord));
  newAlbedo.rgb = mix(newAlbedo.rgb, finalFogColor, fogFactor);

  if (fogShape == cylindrical) {
    vec3 fogCoord2 = vec3(0, pos.y, 0);
    float fogFactor2 = smoothstep(finalFogStart, finalFogEnd, length(fogCoord2));
    newAlbedo.rgb = mix(newAlbedo.rgb, finalFogColor, fogFactor2);
  }

  return newAlbedo;
}