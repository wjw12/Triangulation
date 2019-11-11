#version 330
flat varying FragData {
  vec4 color;
} FragIn;

void main()
{
    gl_FragColor = FragIn.color;
}  