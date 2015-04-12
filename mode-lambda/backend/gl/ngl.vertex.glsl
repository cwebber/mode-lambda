#version 410
@glsl-include["lib.glsl"]

uniform sampler2D SpriteIndexTex;

@cstruct-info->glsl-in[_sprite-data:info]

uniform vec2 LogicalSize;

uniform sampler2D LayerConfigTex;

out vec4 Color;
out vec2 TexCoord;
out float Palette;
out float Layer;

float compute_wrap(float x, int xcoeff, float Lw) {
  return x + float(xcoeff) * Lw;
}

void main(void)
{
  @glsl-include["layer.glsl"]

  vec4 in_TexCoord =
    texelFetch(SpriteIndexTex, ivec2(0, spr), 0);

  float  w = in_TexCoord.x;
  float  h = in_TexCoord.y;
  float tx = in_TexCoord.z;
  float ty = in_TexCoord.w;

  Color = vec4(r / 255.0, g / 255.0, b / 255.0, a);

  mat4 Transform =
      glScale(w * 0.5 * mx * Lmx, h * 0.5 * my * Lmy, 1.0 )
    * glRotate(theta, 0.0, 0.0, 1.0)
    * glTranslate(dx, dy, 0.0)
    // xxx These might be Lhw and Lhh
    * glTranslate(-1.0 * LogicalSize.x / 2.0, -1.0 * LogicalSize.y / 2.0, 0.0)
    * glRotate(Ltheta, 0.0, 0.0, 1.0)
    * glTranslate(Lcx, Lcy, 0.0);
  
  vec4 almostPosn =
      vec4(horiz, vert, 0.0, 1.0)
    * Transform;

  if (xcoeff != 0) {
    if (wrapxp == 1.0) {
      almostPosn.x = compute_wrap(almostPosn.x, xcoeff, Lw);
    } else {
      almostPosn.w = 0;
    }
  }
  if (ycoeff != 0) {
    if (wrapyp == 1.0) {
      almostPosn.y = compute_wrap(almostPosn.y, ycoeff, Lh);
    } else {
      almostPosn.w = 0;
    }
  }

  gl_Position =
      almostPosn
    * glOrtho(0.0, LogicalSize.x,
              0.0, LogicalSize.y,
              1.0, -1.0)
    * glScale(1.0, -1.0, 1.0);
  TexCoord =
    vec2(tx + ((horiz + 1.0)/+2.0) * w,
         ty + (( vert + 1.0)/+2.0) * h);
  Palette = pal;
  Layer = layer;
}
