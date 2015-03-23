#version 330

uniform sampler2D SpriteIndexTex;

in vec2 in_Position;
in uvec4 in_iColor;
in uint in_iTexIndex;
in vec3 in_Transforms;
in ivec2 in_iVertexSpecification;
in uint in_iPalette;

uniform uint ViewportWidth;
uniform uint ViewportHeight;

out vec4 Color;
out vec2 TexCoord;
out float Palette;

mat4 glRotate( float angle, float x, float y, float z ) {
  float c = cos(angle);
  float s = sin(angle);
  return mat4( x*x*(1-c) + c, x*y*(1-c) - z*s, x*z*(1-c) + y*s, 0.0,
               y*x*(1-c) + z*s, y*y*(1-c) + c, y*z*(1-c) - x*s, 0.0,
               x*z*(1-c) - y*s, y*z*(1-c) + x*s, z*z*(1-c)+c, 0.0,
               0.0, 0.0, 0.0, 1.0);
}

mat4 glOrtho( float left, float right, float bottom, float top,
              float nearVal, float farVal ) {
  float t_x = - (right + left) / (right - left);
  float t_y = - (top + bottom) / (top - bottom);
  float t_z = - (farVal + nearVal) / (farVal - nearVal);
  return mat4( 2.0 / right - left, 0.0, 0.0, t_x,
               0.0, 2.0 / top - bottom, 0.0, t_y,
               0.0, 0.0, -2 / farVal - nearVal, t_z,
               0.0, 0.0, 0.0, 1.0 );
}

mat4 glTranslate( float x, float y, float z ) {
  return mat4(1.0, 0.0, 0.0, x,
              0.0, 1.0, 0.0, y,
              0.0, 0.0, 1.0, z,
              0.0, 0.0, 0.0, 1.0);
}

void main(void)
{
  float dx = in_Position.x;
  float dy = in_Position.y;
  uint r = in_iColor.r;
  uint g = in_iColor.g;
  uint b = in_iColor.b;
  uint a = in_iColor.a;
  float mx = in_Transforms.x;
  float my = in_Transforms.y;
  float theta = in_Transforms.z;
  uint pal = in_iPalette;
  uint spr = in_iTexIndex;
  int horiz = in_iVertexSpecification.x;
  int vert = in_iVertexSpecification.y;
  
  vec4 in_TexCoord =
    texelFetch(SpriteIndexTex, ivec2(0, spr), 0);

  float tx = in_TexCoord.x;
  float ty = in_TexCoord.y;
  float w = in_TexCoord.z;
  float h = in_TexCoord.w;

  float hw = w / 2.0;
  float hh = h / 2.0;

  Color = vec4(r, g, b, a) / 255.0;
  gl_Position =
    vec4(horiz * hw * mx,
         vert * hh * my,
         0.0, 1.0)
    * glRotate(theta, 0.0, 0.0, 1.0)
    * glTranslate(dx, dy, 0.0)
    * glOrtho(0.0, ViewportWidth,
              0.0, ViewportHeight,
              1.0, -1.0);
  TexCoord =
    vec2(tx + ((horiz + 1.0)/+2.0) * w,
         ty + ((vert - 1.0)/-2.0) * h);
  ;
  Palette = pal;
}
