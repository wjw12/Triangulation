#version 330
uniform mat4 transform;
attribute vec4 position;
flat varying FragData {
  vec4 color;
} FragIn;
uniform vec2 A; // corner
uniform vec2 F; // center
uniform vec2 scales; // mu, mv
uniform vec2 angles; // au, av
uniform vec3 backgroundColor;
uniform float time;
uniform float noiseX, noiseY, variance;
uniform sampler2D tex;
float rand(vec2 co) { return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);}

vec2 rotate(vec2 v, float a){ return vec2(cos(a) * v.x - sin(a) * v.y, cos(a) * v.y + sin(a) * v.x);}

vec2 spiralPt(vec2 A, vec2 F, float m, float a, float t)   { return mix(F, rotate(A - F, t*a) + F, pow(m,t)); }  

vec2 imageOf(vec2 uv) { return spiralPt(spiralPt(A, F, scales.x, angles.x, uv.x), F, scales.y, angles.y, uv.y);}

void main() {
  float r = rand(position.xy + time * mix(0.0000001, 0.000001, variance));
  vec2 transformed = imageOf(position.xy + vec2(-noiseX*r, -noiseY*r));
  vec4 coord = vec4(transformed, 0.0, 1.0);
  gl_Position = transform * coord;
  gl_Position.xy = transformed + vec2(-500, -500);
  vec4 baseColor = vec4(0.9, 1.0 - position.x*0.5, 1.0 - position.y*0.5, 1.0);
  vec4 c = texture(tex, vec2(position.x, 1.0 - position.y));
  if ((c.x > 0.5 || r > 0.6) && r > 0.02)
    FragIn.color = baseColor;
  else
    FragIn.color = vec4(backgroundColor, 1.0);
}