#version 460 core

#include <flutter/runtime_effect.glsl>

// Everything is in picture units: the canvas is drawn at picture size.
uniform vec2 uSize;
uniform vec2 uStateSize;
uniform float uSelectedColor;
uniform float uStripeWidth;
// Fill animations: xy = origin, z = radius. Slot k is used by regions whose
// state G channel is k + 1.
uniform vec4 uFill0;
uniform vec4 uFill1;
uniform vec4 uFill2;
uniform vec4 uFill3;
uniform vec4 uFill4;
uniform vec4 uFill5;
uniform vec4 uFill6;
uniform vec4 uFill7;

// Region index + 1 per pixel: R low byte, G high byte, 0 = no region.
uniform sampler2D uRegions;
// One texel per region: R = filled, G = animation slot + 1, B = color index.
uniform sampler2D uState;
uniform sampler2D uArtwork;

out vec4 fragColor;

float byteAt(float channel) {
  return floor(channel * 255.0 + 0.5);
}

vec4 fillSlot(float slot) {
  if (slot < 1.5) return uFill0;
  if (slot < 2.5) return uFill1;
  if (slot < 3.5) return uFill2;
  if (slot < 4.5) return uFill3;
  if (slot < 5.5) return uFill4;
  if (slot < 6.5) return uFill5;
  if (slot < 7.5) return uFill6;
  return uFill7;
}

void main() {
  vec2 position = FlutterFragCoord().xy;
  vec2 uv = position / uSize;

  vec4 id = texture(uRegions, uv);
  float region = byteAt(id.r) + byteAt(id.g) * 256.0 - 1.0;
  if (region < 0.0) {
    fragColor = vec4(0.0);
    return;
  }

  vec2 texel = vec2(mod(region, uStateSize.x), floor(region / uStateSize.x));
  vec4 state = texture(uState, (texel + 0.5) / uStateSize);

  bool revealed = state.r > 0.5;
  float slot = byteAt(state.g);
  if (!revealed && slot > 0.5) {
    vec4 fill = fillSlot(slot);
    revealed = distance(position, fill.xy) <= fill.z;
  }
  if (revealed) {
    fragColor = texture(uArtwork, uv);
    return;
  }

  if (abs(byteAt(state.b) - uSelectedColor) < 0.5) {
    float band = mod((position.x + position.y) / uStripeWidth, 2.0);
    fragColor = vec4(0.0, 0.0, 0.0, band < 1.0 ? 0.2 : 0.08);
    return;
  }
  fragColor = vec4(0.0);
}
