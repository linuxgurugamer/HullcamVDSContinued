Shader "Custom/MovieTime" {
	Properties {
		_MainTex("Base Texture", 2D)="white" {}
		_TitleTex("Title Texture", 2D)="white" {}
		_VignetteTex("Vignette Texture", 2D)="white" {}
		_Overlay1Tex("Overlay 1 Texture", 2D)="white" {}
		_Overlay2Tex("Overlay 2 Texture", 2D)="white" {}

		_Monochrome("Monochrome", Float)=1
		_MonoColor("Monochrome Color", Color)=(0,0,0,0)
		_Contrast("Contrast", Range(0,4))=2
		_Brightness("Brightness", Range(0,2))=1

		_Title("Overlay Title", Float)=0

		_MainOffsetX("Main Offset X", Range(0,1))=0
		_MainOffsetY("Main Offset Y", Range(0,1))=0
		_MainSpeedX("Main Speed X", Float)=0
		_MainSpeedY("Main Speed Y", Float)=0

		_VignetteAmount("Vignette Amount", Range(0,1)) = 1
		_VignetteOffsetX("Vignette Offset X", Range(0,1))=0
		_VignetteOffsetY("Vignette Offset Y", Range(0,1))=0
		_VignetteSpeedX("Vignette Speed X", Float)=0
		_VignetteSpeedY("Vignette Speed Y", Float)=0

		_Overlay1Amount("Overlay 1 Amount", Range(0,1)) = 1
		_Overlay1OffsetX("Overlay 1 Offset X", Range(0,1))=0
		_Overlay1OffsetY("Overlay 1 Offset Y", Range(0,1))=0
		_Overlay1SpeedX("Overlay 1 Speed X", Float)=0
		_Overlay1SpeedY("Overlay 1 Speed Y", Float)=0

		_Overlay2Amount("Overlay 2 Amount", Range(0,1)) = 1
		_Overlay2OffsetX("Overlay 2 Offset X", Range(0,1))=0
		_Overlay2OffsetY("Overlay 2 Offset Y", Range(0,1))=0
		_Overlay2SpeedX("Overlay 2 Speed X", Float)=0
		_Overlay2SpeedY("Overlay 2 Speed Y", Float)=0

		_ColorJitter("Color Jitter", Range(.9,1.1))=1
		_ContrastJitter("Contrast Jitter", Range(.9,1.1))=1
		_BrightnessJitter("Brightness Jitter", Range(.9,1.1))=1
	}
	SubShader {
        Pass{
			Program "vp" {
// Vertex combos: 1
//   opengl - ALU: 8 to 8
//   d3d9 - ALU: 8 to 8
//   d3d11 - ALU: 6 to 6, TEX: 0 to 0, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
"3.0-!!ARBvp1.0
# 8 ALU
PARAM c[9] = { { 0 },
		state.matrix.mvp,
		state.matrix.texture[0] };
TEMP R0;
MOV R0.zw, c[0].x;
MOV R0.xy, vertex.texcoord[0];
DP4 result.texcoord[0].y, R0, c[6];
DP4 result.texcoord[0].x, R0, c[5];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 8 instructions, 1 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Matrix 4 [glstate_matrix_texture0]
"vs_3_0
; 8 ALU
dcl_position o0
dcl_texcoord0 o1
def c8, 0.00000000, 0, 0, 0
dcl_position0 v0
dcl_texcoord0 v1
mov r0.zw, c8.x
mov r0.xy, v1
dp4 o1.y, r0, c5
dp4 o1.x, r0, c4
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
"
}

SubProgram "d3d11 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
ConstBuffer "UnityPerDraw" 336 // 64 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
ConstBuffer "UnityPerDrawTexMatrices" 768 // 576 used size, 5 vars
Matrix 512 [glstate_matrix_texture0] 4
BindCB "UnityPerDraw" 0
BindCB "UnityPerDrawTexMatrices" 1
// 7 instructions, 1 temp regs, 0 temp arrays:
// ALU 6 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0
eefiecedeedelkdobbmimfefjdhgabnhlefmpcmlabaaaaaaciacaaaaadaaaaaa
cmaaaaaaiaaaaaaaniaaaaaaejfdeheoemaaaaaaacaaaaaaaiaaaaaadiaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaaebaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaadadaaaafaepfdejfeejepeoaafeeffiedepepfceeaaklkl
epfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaaaaaaaaaaabaaaaaaadaaaaaa
aaaaaaaaapaaaaaaeeaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaadamaaaa
fdfgfpfaepfdejfeejepeoaafeeffiedepepfceeaaklklklfdeieefceiabaaaa
eaaaabaafcaaaaaafjaaaaaeegiocaaaaaaaaaaaaeaaaaaafjaaaaaeegiocaaa
abaaaaaaccaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaaddcbabaaaabaaaaaa
ghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaaddccabaaaabaaaaaagiaaaaac
abaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaaaaaaaaaa
abaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaaaaaaaaaaaaaaaaaagbabaaa
aaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaaaaaaaaa
acaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpccabaaaaaaaaaaa
egiocaaaaaaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaadiaaaaai
dcaabaaaaaaaaaaafgbfbaaaabaaaaaaegiacaaaabaaaaaacbaaaaaadcaaaaak
dccabaaaabaaaaaaegiacaaaabaaaaaacaaaaaaaagbabaaaabaaaaaaegaabaaa
aaaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { }
"!!GLES


#ifdef VERTEX

varying mediump vec2 xlv_TEXCOORD0;
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_mvp;
attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesVertex;
void main ()
{
  vec2 tmpvar_1;
  tmpvar_1 = _glesMultiTexCoord0.xy;
  mediump vec2 tmpvar_2;
  highp vec2 tmpvar_3;
  highp vec4 tmpvar_4;
  tmpvar_4.zw = vec2(0.0, 0.0);
  tmpvar_4.x = tmpvar_1.x;
  tmpvar_4.y = tmpvar_1.y;
  tmpvar_3 = (glstate_matrix_texture0 * tmpvar_4).xy;
  tmpvar_2 = tmpvar_3;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying mediump vec2 xlv_TEXCOORD0;
uniform lowp float _BrightnessJitter;
uniform lowp float _ContrastJitter;
uniform lowp float _ColorJitter;
uniform highp float _Overlay2SpeedY;
uniform highp float _Overlay2SpeedX;
uniform highp float _Overlay2OffsetY;
uniform highp float _Overlay2Amount;
uniform highp float _Overlay1SpeedY;
uniform highp float _Overlay1SpeedX;
uniform highp float _Overlay1OffsetY;
uniform highp float _Overlay1OffsetX;
uniform highp float _Overlay1Amount;
uniform highp float _VignetteSpeedY;
uniform highp float _VignetteSpeedX;
uniform highp float _VignetteOffsetY;
uniform highp float _VignetteOffsetX;
uniform highp float _VignetteAmount;
uniform highp float _MainSpeedY;
uniform highp float _MainSpeedX;
uniform highp float _MainOffsetY;
uniform highp float _MainOffsetX;
uniform highp float _Title;
uniform lowp float _Brightness;
uniform lowp float _Contrast;
uniform lowp vec4 _MonoColor;
uniform lowp float _Monochrome;
uniform sampler2D _Overlay2Tex;
uniform sampler2D _Overlay1Tex;
uniform sampler2D _VignetteTex;
uniform sampler2D _TitleTex;
uniform sampler2D _MainTex;
uniform highp vec4 _Time;
void main ()
{
  mediump vec2 overlay2UV_1;
  mediump vec2 overlay1UV_2;
  mediump vec2 vignetteUV_3;
  mediump vec2 titleUV_4;
  lowp vec4 renderTex_5;
  mediump vec2 renderTexUV_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = ((xlv_TEXCOORD0.x + _MainOffsetX) + (_Time.x * _MainSpeedX));
  tmpvar_7.y = ((xlv_TEXCOORD0.y + _MainOffsetY) + (_Time.x * _MainSpeedY));
  renderTexUV_6 = tmpvar_7;
  lowp vec4 tmpvar_8;
  tmpvar_8 = texture2D (_MainTex, renderTexUV_6);
  renderTex_5 = tmpvar_8;
  highp vec2 tmpvar_9;
  tmpvar_9.x = ((xlv_TEXCOORD0.x + _MainOffsetX) + (_Time.x * _MainSpeedX));
  tmpvar_9.y = ((xlv_TEXCOORD0.y + _MainOffsetY) + (_Time.x * _MainSpeedY));
  titleUV_4 = tmpvar_9;
  lowp vec4 tmpvar_10;
  tmpvar_10 = texture2D (_TitleTex, titleUV_4);
  highp vec2 tmpvar_11;
  tmpvar_11.x = ((xlv_TEXCOORD0.x + _VignetteOffsetX) + (_Time.x * _VignetteSpeedX));
  tmpvar_11.y = ((xlv_TEXCOORD0.y + _VignetteOffsetY) + (_Time.x * _VignetteSpeedY));
  vignetteUV_3 = tmpvar_11;
  lowp vec4 tmpvar_12;
  tmpvar_12 = texture2D (_VignetteTex, vignetteUV_3);
  highp vec2 tmpvar_13;
  tmpvar_13.x = ((xlv_TEXCOORD0.x + _Overlay1OffsetX) + (_Time.x * _Overlay1SpeedX));
  tmpvar_13.y = ((xlv_TEXCOORD0.y + _Overlay1OffsetY) + (_Time.x * _Overlay1SpeedY));
  overlay1UV_2 = tmpvar_13;
  lowp vec4 tmpvar_14;
  tmpvar_14 = texture2D (_Overlay1Tex, overlay1UV_2);
  highp vec2 tmpvar_15;
  tmpvar_15.x = ((xlv_TEXCOORD0.x + _Overlay2OffsetY) + (_Time.x * _Overlay2SpeedX));
  tmpvar_15.y = ((xlv_TEXCOORD0.y + _Overlay2OffsetY) + (_Time.x * _Overlay2SpeedY));
  overlay2UV_1 = tmpvar_15;
  lowp vec4 tmpvar_16;
  tmpvar_16 = texture2D (_Overlay2Tex, overlay2UV_1);
  if ((_Monochrome != 0.0)) {
    renderTex_5.xyz = vec3(dot (vec3(0.299, 0.587, 0.114), tmpvar_8.xyz));
    renderTex_5.xyz = ((((renderTex_5.xyz - 0.5) * _Contrast) * _ContrastJitter) * 0.5);
    renderTex_5.xyz = (renderTex_5.xyz + (_Brightness * _BrightnessJitter));
    renderTex_5.xyz = (renderTex_5.xyz + mix (_MonoColor, (_MonoColor + vec4(0.1, 0.1, 0.1, 0.1)), vec4(_ColorJitter)).xyz);
  } else {
    renderTex_5.xyz = (((renderTex_5.xyz - 0.5) * _Contrast) + (_ContrastJitter * 0.5));
    renderTex_5.xyz = (renderTex_5.xyz + (_Brightness * _BrightnessJitter));
  };
  if (((_Title != 0.0) && (tmpvar_10.w >= 1.0))) {
    renderTex_5.xyz = tmpvar_10.xyz;
  } else {
    if (((_Title != 0.0) && (tmpvar_10.w > 0.0))) {
      renderTex_5.xyz = vec3(dot (vec3(0.299, 0.587, 0.144), renderTex_5.xyz));
      renderTex_5.xyz = ((tmpvar_10.xyz * tmpvar_10.w) - (renderTex_5.xyz * (1.0 - tmpvar_10.w)));
    };
  };
  highp vec3 tmpvar_17;
  tmpvar_17 = (renderTex_5.xyz * mix (tmpvar_12.xyz, vec3(1.0, 1.0, 1.0), vec3(_VignetteAmount)));
  renderTex_5.xyz = tmpvar_17;
  highp vec3 tmpvar_18;
  tmpvar_18 = (renderTex_5.xyz * mix (tmpvar_14.xyz, vec3(1.0, 1.0, 1.0), vec3(_Overlay1Amount)));
  renderTex_5.xyz = tmpvar_18;
  highp vec3 tmpvar_19;
  tmpvar_19 = (renderTex_5.xyz * mix (tmpvar_16.xyz, vec3(1.0, 1.0, 1.0), vec3(_Overlay2Amount)));
  renderTex_5.xyz = tmpvar_19;
  gl_FragData[0] = renderTex_5;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES


#ifdef VERTEX

varying mediump vec2 xlv_TEXCOORD0;
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_mvp;
attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesVertex;
void main ()
{
  vec2 tmpvar_1;
  tmpvar_1 = _glesMultiTexCoord0.xy;
  mediump vec2 tmpvar_2;
  highp vec2 tmpvar_3;
  highp vec4 tmpvar_4;
  tmpvar_4.zw = vec2(0.0, 0.0);
  tmpvar_4.x = tmpvar_1.x;
  tmpvar_4.y = tmpvar_1.y;
  tmpvar_3 = (glstate_matrix_texture0 * tmpvar_4).xy;
  tmpvar_2 = tmpvar_3;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_2;
}



#endif
#ifdef FRAGMENT

varying mediump vec2 xlv_TEXCOORD0;
uniform lowp float _BrightnessJitter;
uniform lowp float _ContrastJitter;
uniform lowp float _ColorJitter;
uniform highp float _Overlay2SpeedY;
uniform highp float _Overlay2SpeedX;
uniform highp float _Overlay2OffsetY;
uniform highp float _Overlay2Amount;
uniform highp float _Overlay1SpeedY;
uniform highp float _Overlay1SpeedX;
uniform highp float _Overlay1OffsetY;
uniform highp float _Overlay1OffsetX;
uniform highp float _Overlay1Amount;
uniform highp float _VignetteSpeedY;
uniform highp float _VignetteSpeedX;
uniform highp float _VignetteOffsetY;
uniform highp float _VignetteOffsetX;
uniform highp float _VignetteAmount;
uniform highp float _MainSpeedY;
uniform highp float _MainSpeedX;
uniform highp float _MainOffsetY;
uniform highp float _MainOffsetX;
uniform highp float _Title;
uniform lowp float _Brightness;
uniform lowp float _Contrast;
uniform lowp vec4 _MonoColor;
uniform lowp float _Monochrome;
uniform sampler2D _Overlay2Tex;
uniform sampler2D _Overlay1Tex;
uniform sampler2D _VignetteTex;
uniform sampler2D _TitleTex;
uniform sampler2D _MainTex;
uniform highp vec4 _Time;
void main ()
{
  mediump vec2 overlay2UV_1;
  mediump vec2 overlay1UV_2;
  mediump vec2 vignetteUV_3;
  mediump vec2 titleUV_4;
  lowp vec4 renderTex_5;
  mediump vec2 renderTexUV_6;
  highp vec2 tmpvar_7;
  tmpvar_7.x = ((xlv_TEXCOORD0.x + _MainOffsetX) + (_Time.x * _MainSpeedX));
  tmpvar_7.y = ((xlv_TEXCOORD0.y + _MainOffsetY) + (_Time.x * _MainSpeedY));
  renderTexUV_6 = tmpvar_7;
  lowp vec4 tmpvar_8;
  tmpvar_8 = texture2D (_MainTex, renderTexUV_6);
  renderTex_5 = tmpvar_8;
  highp vec2 tmpvar_9;
  tmpvar_9.x = ((xlv_TEXCOORD0.x + _MainOffsetX) + (_Time.x * _MainSpeedX));
  tmpvar_9.y = ((xlv_TEXCOORD0.y + _MainOffsetY) + (_Time.x * _MainSpeedY));
  titleUV_4 = tmpvar_9;
  lowp vec4 tmpvar_10;
  tmpvar_10 = texture2D (_TitleTex, titleUV_4);
  highp vec2 tmpvar_11;
  tmpvar_11.x = ((xlv_TEXCOORD0.x + _VignetteOffsetX) + (_Time.x * _VignetteSpeedX));
  tmpvar_11.y = ((xlv_TEXCOORD0.y + _VignetteOffsetY) + (_Time.x * _VignetteSpeedY));
  vignetteUV_3 = tmpvar_11;
  lowp vec4 tmpvar_12;
  tmpvar_12 = texture2D (_VignetteTex, vignetteUV_3);
  highp vec2 tmpvar_13;
  tmpvar_13.x = ((xlv_TEXCOORD0.x + _Overlay1OffsetX) + (_Time.x * _Overlay1SpeedX));
  tmpvar_13.y = ((xlv_TEXCOORD0.y + _Overlay1OffsetY) + (_Time.x * _Overlay1SpeedY));
  overlay1UV_2 = tmpvar_13;
  lowp vec4 tmpvar_14;
  tmpvar_14 = texture2D (_Overlay1Tex, overlay1UV_2);
  highp vec2 tmpvar_15;
  tmpvar_15.x = ((xlv_TEXCOORD0.x + _Overlay2OffsetY) + (_Time.x * _Overlay2SpeedX));
  tmpvar_15.y = ((xlv_TEXCOORD0.y + _Overlay2OffsetY) + (_Time.x * _Overlay2SpeedY));
  overlay2UV_1 = tmpvar_15;
  lowp vec4 tmpvar_16;
  tmpvar_16 = texture2D (_Overlay2Tex, overlay2UV_1);
  if ((_Monochrome != 0.0)) {
    renderTex_5.xyz = vec3(dot (vec3(0.299, 0.587, 0.114), tmpvar_8.xyz));
    renderTex_5.xyz = ((((renderTex_5.xyz - 0.5) * _Contrast) * _ContrastJitter) * 0.5);
    renderTex_5.xyz = (renderTex_5.xyz + (_Brightness * _BrightnessJitter));
    renderTex_5.xyz = (renderTex_5.xyz + mix (_MonoColor, (_MonoColor + vec4(0.1, 0.1, 0.1, 0.1)), vec4(_ColorJitter)).xyz);
  } else {
    renderTex_5.xyz = (((renderTex_5.xyz - 0.5) * _Contrast) + (_ContrastJitter * 0.5));
    renderTex_5.xyz = (renderTex_5.xyz + (_Brightness * _BrightnessJitter));
  };
  if (((_Title != 0.0) && (tmpvar_10.w >= 1.0))) {
    renderTex_5.xyz = tmpvar_10.xyz;
  } else {
    if (((_Title != 0.0) && (tmpvar_10.w > 0.0))) {
      renderTex_5.xyz = vec3(dot (vec3(0.299, 0.587, 0.144), renderTex_5.xyz));
      renderTex_5.xyz = ((tmpvar_10.xyz * tmpvar_10.w) - (renderTex_5.xyz * (1.0 - tmpvar_10.w)));
    };
  };
  highp vec3 tmpvar_17;
  tmpvar_17 = (renderTex_5.xyz * mix (tmpvar_12.xyz, vec3(1.0, 1.0, 1.0), vec3(_VignetteAmount)));
  renderTex_5.xyz = tmpvar_17;
  highp vec3 tmpvar_18;
  tmpvar_18 = (renderTex_5.xyz * mix (tmpvar_14.xyz, vec3(1.0, 1.0, 1.0), vec3(_Overlay1Amount)));
  renderTex_5.xyz = tmpvar_18;
  highp vec3 tmpvar_19;
  tmpvar_19 = (renderTex_5.xyz * mix (tmpvar_16.xyz, vec3(1.0, 1.0, 1.0), vec3(_Overlay2Amount)));
  renderTex_5.xyz = tmpvar_19;
  gl_FragData[0] = renderTex_5;
}



#endif"
}

SubProgram "gles3 " {
Keywords { }
"!!GLES3#version 300 es


#ifdef VERTEX

#define gl_Vertex _glesVertex
in vec4 _glesVertex;
#define gl_MultiTexCoord0 _glesMultiTexCoord0
in vec4 _glesMultiTexCoord0;

#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform highp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 315
uniform sampler2D _MainTex;
uniform sampler2D _TitleTex;
uniform sampler2D _VignetteTex;
uniform sampler2D _Overlay1Tex;
#line 319
uniform sampler2D _Overlay2Tex;
uniform lowp float _Monochrome;
uniform lowp vec4 _MonoColor;
uniform lowp float _Contrast;
#line 323
uniform lowp float _Brightness;
uniform highp float _Title;
uniform highp float _MainOffsetX;
uniform highp float _MainOffsetY;
#line 327
uniform highp float _MainSpeedX;
uniform highp float _MainSpeedY;
uniform highp float _VignetteAmount;
uniform highp float _VignetteOffsetX;
#line 331
uniform highp float _VignetteOffsetY;
uniform highp float _VignetteSpeedX;
uniform highp float _VignetteSpeedY;
uniform highp float _Overlay1Amount;
#line 335
uniform highp float _Overlay1OffsetX;
uniform highp float _Overlay1OffsetY;
uniform highp float _Overlay1SpeedX;
uniform highp float _Overlay1SpeedY;
#line 339
uniform highp float _Overlay2Amount;
uniform highp float _Overlay2OffsetX;
uniform highp float _Overlay2OffsetY;
uniform highp float _Overlay2SpeedX;
#line 343
uniform highp float _Overlay2SpeedY;
uniform lowp float _ColorJitter;
uniform lowp float _ContrastJitter;
uniform lowp float _BrightnessJitter;
#line 347
#line 193
highp vec2 MultiplyUV( in highp mat4 mat, in highp vec2 inUV ) {
    highp vec4 temp = vec4( inUV.x, inUV.y, 0.0, 0.0);
    temp = (mat * temp);
    #line 197
    return temp.xy;
}
#line 199
v2f_img vert_img( in appdata_img v ) {
    #line 201
    v2f_img o;
    o.pos = (glstate_matrix_mvp * v.vertex);
    o.uv = MultiplyUV( glstate_matrix_texture0, v.texcoord);
    return o;
}
out mediump vec2 xlv_TEXCOORD0;
void main() {
    v2f_img xl_retval;
    appdata_img xlt_v;
    xlt_v.vertex = vec4(gl_Vertex);
    xlt_v.texcoord = vec2(gl_MultiTexCoord0);
    xl_retval = vert_img( xlt_v);
    gl_Position = vec4(xl_retval.pos);
    xlv_TEXCOORD0 = vec2(xl_retval.uv);
}


#endif
#ifdef FRAGMENT

#define gl_FragData _glesFragData
layout(location = 0) out mediump vec4 _glesFragData[4];

#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform highp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 315
uniform sampler2D _MainTex;
uniform sampler2D _TitleTex;
uniform sampler2D _VignetteTex;
uniform sampler2D _Overlay1Tex;
#line 319
uniform sampler2D _Overlay2Tex;
uniform lowp float _Monochrome;
uniform lowp vec4 _MonoColor;
uniform lowp float _Contrast;
#line 323
uniform lowp float _Brightness;
uniform highp float _Title;
uniform highp float _MainOffsetX;
uniform highp float _MainOffsetY;
#line 327
uniform highp float _MainSpeedX;
uniform highp float _MainSpeedY;
uniform highp float _VignetteAmount;
uniform highp float _VignetteOffsetX;
#line 331
uniform highp float _VignetteOffsetY;
uniform highp float _VignetteSpeedX;
uniform highp float _VignetteSpeedY;
uniform highp float _Overlay1Amount;
#line 335
uniform highp float _Overlay1OffsetX;
uniform highp float _Overlay1OffsetY;
uniform highp float _Overlay1SpeedX;
uniform highp float _Overlay1SpeedY;
#line 339
uniform highp float _Overlay2Amount;
uniform highp float _Overlay2OffsetX;
uniform highp float _Overlay2OffsetY;
uniform highp float _Overlay2SpeedX;
#line 343
uniform highp float _Overlay2SpeedY;
uniform lowp float _ColorJitter;
uniform lowp float _ContrastJitter;
uniform lowp float _BrightnessJitter;
#line 347
#line 347
lowp vec4 frag( in v2f_img i ) {
    lowp vec3 constantWhite = vec3( 1.0, 1.0, 1.0);
    mediump vec2 renderTexUV = vec2( ((i.uv.x + _MainOffsetX) + (_Time.x * _MainSpeedX)), ((i.uv.y + _MainOffsetY) + (_Time.x * _MainSpeedY)));
    #line 351
    lowp vec4 renderTex = texture( _MainTex, renderTexUV);
    mediump vec2 titleUV = vec2( ((i.uv.x + _MainOffsetX) + (_Time.x * _MainSpeedX)), ((i.uv.y + _MainOffsetY) + (_Time.x * _MainSpeedY)));
    lowp vec4 titleTex = texture( _TitleTex, titleUV);
    mediump vec2 vignetteUV = vec2( ((i.uv.x + _VignetteOffsetX) + (_Time.x * _VignetteSpeedX)), ((i.uv.y + _VignetteOffsetY) + (_Time.x * _VignetteSpeedY)));
    #line 355
    lowp vec4 vignetteTex = texture( _VignetteTex, vignetteUV);
    mediump vec2 overlay1UV = vec2( ((i.uv.x + _Overlay1OffsetX) + (_Time.x * _Overlay1SpeedX)), ((i.uv.y + _Overlay1OffsetY) + (_Time.x * _Overlay1SpeedY)));
    lowp vec4 overlay1Tex = texture( _Overlay1Tex, overlay1UV);
    mediump vec2 overlay2UV = vec2( ((i.uv.x + _Overlay2OffsetY) + (_Time.x * _Overlay2SpeedX)), ((i.uv.y + _Overlay2OffsetY) + (_Time.x * _Overlay2SpeedY)));
    #line 359
    lowp vec4 overlay2Tex = texture( _Overlay2Tex, overlay2UV);
    if ((_Monochrome != 0.0)){
        renderTex.xyz = vec3( dot( vec3( 0.299, 0.587, 0.114), renderTex.xyz));
        #line 363
        renderTex.xyz = ((((renderTex.xyz - 0.5) * _Contrast) * _ContrastJitter) * 0.5);
        renderTex.xyz += (_Brightness * _BrightnessJitter);
        renderTex.xyz += vec3( mix( _MonoColor, (_MonoColor + vec4( 0.1, 0.1, 0.1, 0.1)), vec4( _ColorJitter)));
    }
    else{
        #line 369
        renderTex.xyz = (((renderTex.xyz - 0.5) * _Contrast) + (_ContrastJitter * 0.5));
        renderTex.xyz += (_Brightness * _BrightnessJitter);
    }
    if (((_Title != 0.0) && (titleTex.w >= 1.0))){
        #line 374
        renderTex.xyz = titleTex.xyz;
    }
    else{
        if (((_Title != 0.0) && (titleTex.w > 0.0))){
            #line 378
            renderTex.xyz = vec3( dot( vec3( 0.299, 0.587, 0.144), renderTex.xyz));
            renderTex.xyz = ((titleTex.xyz * titleTex.w) - (renderTex.xyz * (1.0 - titleTex.w)));
        }
    }
    renderTex.xyz *= mix( vignetteTex.xyz, constantWhite, vec3( _VignetteAmount));
    #line 382
    renderTex.xyz *= mix( overlay1Tex.xyz, constantWhite, vec3( _Overlay1Amount));
    renderTex.xyz *= mix( overlay2Tex.xyz, constantWhite, vec3( _Overlay2Amount));
    return renderTex;
}
in mediump vec2 xlv_TEXCOORD0;
void main() {
    lowp vec4 xl_retval;
    v2f_img xlt_i;
    xlt_i.pos = vec4(0.0);
    xlt_i.uv = vec2(xlv_TEXCOORD0);
    xl_retval = frag( xlt_i);
    gl_FragData[0] = vec4(xl_retval);
}


#endif"
}

}
Program "fp" {
// Fragment combos: 1
//   opengl - ALU: 81 to 81, TEX: 5 to 5
//   d3d9 - ALU: 78 to 78, TEX: 5 to 5
//   d3d11 - ALU: 42 to 42, TEX: 5 to 5, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Vector 0 [_Time]
Float 1 [_Monochrome]
Vector 2 [_MonoColor]
Float 3 [_Contrast]
Float 4 [_Brightness]
Float 5 [_Title]
Float 6 [_MainOffsetX]
Float 7 [_MainOffsetY]
Float 8 [_MainSpeedX]
Float 9 [_MainSpeedY]
Float 10 [_VignetteAmount]
Float 11 [_VignetteOffsetX]
Float 12 [_VignetteOffsetY]
Float 13 [_VignetteSpeedX]
Float 14 [_VignetteSpeedY]
Float 15 [_Overlay1Amount]
Float 16 [_Overlay1OffsetX]
Float 17 [_Overlay1OffsetY]
Float 18 [_Overlay1SpeedX]
Float 19 [_Overlay1SpeedY]
Float 20 [_Overlay2Amount]
Float 21 [_Overlay2OffsetY]
Float 22 [_Overlay2SpeedX]
Float 23 [_Overlay2SpeedY]
Float 24 [_ColorJitter]
Float 25 [_ContrastJitter]
Float 26 [_BrightnessJitter]
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TitleTex] 2D
SetTexture 2 [_VignetteTex] 2D
SetTexture 3 [_Overlay1Tex] 2D
SetTexture 4 [_Overlay2Tex] 2D
"3.0-!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 81 ALU, 5 TEX
PARAM c[29] = { program.local[0..26],
		{ 1, 0, 0.5, 0.099975586 },
		{ 0.29907227, 0.58691406, 0.14404297, 0.11401367 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
ABS R0.w, c[1].x;
MOV R2.w, c[26].x;
ADD R0.x, fragment.texcoord[0].y, c[7];
MOV R0.y, c[9].x;
MAD R3.y, R0, c[0].x, R0.x;
ADD R0.x, fragment.texcoord[0], c[6];
MOV R0.y, c[8].x;
MAD R3.x, R0.y, c[0], R0;
TEX R1, R3, texture[0], 2D;
DP3 R0.x, R1, c[28].xyww;
CMP R0.xyz, -R0.w, R0.x, R1;
ADD R1.xyz, R0, -c[27].z;
MUL R1.xyz, R1, c[3].x;
MUL R1.xyz, R1, c[25].x;
MUL R1.xyz, R1, c[27].z;
CMP R0.xyz, -R0.w, R1, R0;
MAD R1.xyz, R2.w, c[4].x, R0;
CMP R0.xyz, -R0.w, R1, R0;
MOV R3.z, c[24].x;
MOV R2.xyz, c[2];
MAD R2.xyz, R3.z, c[27].w, R2;
ADD R1.xyz, R0, R2;
CMP R0.xyz, -R0.w, R1, R0;
MOV R2.x, c[27].z;
CMP R0.w, -R0, c[27].x, c[27].y;
ABS R0.w, R0;
CMP R0.w, -R0, c[27].y, c[27].x;
ADD R1.xyz, R0, -c[27].z;
MUL R2.x, R2, c[25];
MAD R1.xyz, R1, c[3].x, R2.x;
CMP R0.xyz, -R0.w, R1, R0;
MAD R1.xyz, R2.w, c[4].x, R0;
CMP R1.xyz, -R0.w, R1, R0;
TEX R0, R3, texture[1], 2D;
ABS R2.x, c[5];
CMP R2.x, -R2, c[27], c[27].y;
SGE R2.y, R0.w, c[27].x;
MUL R2.y, R2.x, R2;
CMP R1.xyz, -R2.y, R0, R1;
SLT R2.z, c[27].y, R0.w;
DP3 R3.x, R1, c[28];
MUL R2.z, R2.x, R2;
ABS R2.y, R2;
CMP R2.x, -R2.y, c[27].y, c[27];
MUL R2.w, R2.x, R2.z;
CMP R2.xyz, -R2.w, R3.x, R1;
ADD R3.x, -R0.w, c[27];
MUL R3.xyz, R2, R3.x;
MAD R0.xyz, R0, R0.w, -R3;
CMP R0.xyz, -R2.w, R0, R2;
ADD R1.x, fragment.texcoord[0].y, c[12];
MOV R1.y, c[14].x;
MAD R1.y, R1, c[0].x, R1.x;
MOV R1.z, c[13].x;
ADD R1.x, fragment.texcoord[0], c[11];
MAD R1.x, R1.z, c[0], R1;
TEX R1.xyz, R1, texture[2], 2D;
ADD R4.xyz, -R1, c[27].x;
MAD R1.xyz, R4, c[10].x, R1;
MUL R2.xyz, R0, R1;
ADD R0.x, fragment.texcoord[0].y, c[17];
MOV R0.y, c[19].x;
MAD R0.y, R0, c[0].x, R0.x;
MOV R0.z, c[18].x;
ADD R0.x, fragment.texcoord[0], c[16];
MAD R0.x, R0.z, c[0], R0;
TEX R0.xyz, R0, texture[3], 2D;
ADD R3.xyz, -R0, c[27].x;
MAD R0.xyz, R3, c[15].x, R0;
ADD R0.w, fragment.texcoord[0].y, c[21].x;
MOV R1.x, c[23];
MAD R1.y, R1.x, c[0].x, R0.w;
ADD R0.w, fragment.texcoord[0].x, c[21].x;
MOV R1.x, c[22];
MAD R1.x, R1, c[0], R0.w;
TEX R1.xyz, R1, texture[4], 2D;
ADD R4.xyz, -R1, c[27].x;
MAD R1.xyz, R4, c[20].x, R1;
MUL R0.xyz, R2, R0;
MUL result.color.xyz, R0, R1;
MOV result.color.w, R1;
END
# 81 instructions, 5 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Vector 0 [_Time]
Float 1 [_Monochrome]
Vector 2 [_MonoColor]
Float 3 [_Contrast]
Float 4 [_Brightness]
Float 5 [_Title]
Float 6 [_MainOffsetX]
Float 7 [_MainOffsetY]
Float 8 [_MainSpeedX]
Float 9 [_MainSpeedY]
Float 10 [_VignetteAmount]
Float 11 [_VignetteOffsetX]
Float 12 [_VignetteOffsetY]
Float 13 [_VignetteSpeedX]
Float 14 [_VignetteSpeedY]
Float 15 [_Overlay1Amount]
Float 16 [_Overlay1OffsetX]
Float 17 [_Overlay1OffsetY]
Float 18 [_Overlay1SpeedX]
Float 19 [_Overlay1SpeedY]
Float 20 [_Overlay2Amount]
Float 21 [_Overlay2OffsetY]
Float 22 [_Overlay2SpeedX]
Float 23 [_Overlay2SpeedY]
Float 24 [_ColorJitter]
Float 25 [_ContrastJitter]
Float 26 [_BrightnessJitter]
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TitleTex] 2D
SetTexture 2 [_VignetteTex] 2D
SetTexture 3 [_Overlay1Tex] 2D
SetTexture 4 [_Overlay2Tex] 2D
"ps_3_0
; 78 ALU, 5 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
def c27, 0.00000000, 1.00000000, -1.00000000, -0.50000000
def c28, 0.29907227, 0.58691406, 0.11401367, 0.09997559
def c29, 0.50000000, 0.29907227, 0.58691406, 0.14404297
dcl_texcoord0 v0.xy
mov r0.x, c0
add r0.y, v0, c7.x
mad r0.y, c9.x, r0.x, r0
add r0.z, v0.x, c6.x
mov r0.x, c0
mad r0.x, c8, r0, r0.z
texld r1, r0, s0
abs_pp r0.z, c1.x
dp3_pp r0.w, r1, c28
cmp_pp r1.xyz, -r0.z, r1, r0.w
add r2.xyz, r1, c27.w
mul r2.xyz, r2, c3.x
mul r2.xyz, r2, c25.x
mul r2.xyz, r2, c29.x
cmp_pp r2.xyz, -r0.z, r1, r2
mov_pp r0.w, c4.x
mad_pp r1.xyz, c26.x, r0.w, r2
cmp_pp r1.xyz, -r0.z, r2, r1
mov_pp r0.w, c28
mov_pp r3.xyz, c2
mad_pp r3.xyz, c24.x, r0.w, r3
add_pp r2.xyz, r1, r3
cmp_pp r1.xyz, -r0.z, r1, r2
mov r0.w, c25.x
abs_pp r0.z, c1.x
cmp_pp r0.z, -r0, c27.x, c27.y
abs_pp r2.w, r0.z
add r2.xyz, r1, c27.w
mul r0.w, c29.x, r0
mad r2.xyz, r2, c3.x, r0.w
cmp_pp r1.xyz, -r2.w, r2, r1
mov_pp r0.z, c4.x
mad_pp r2.xyz, c26.x, r0.z, r1
cmp_pp r1.xyz, -r2.w, r2, r1
texld r0, r0, s1
add_pp r2.y, r0.w, c27.z
abs r2.x, c5
cmp r2.x, -r2, c27, c27.y
cmp_pp r2.z, -r0.w, c27.x, c27.y
cmp_pp r2.y, r2, c27, c27.x
mul_pp r2.y, r2.x, r2
cmp_pp r1.xyz, -r2.y, r1, r0
dp3_pp r3.x, r1, c29.yzww
mul_pp r2.z, r2.x, r2
abs_pp r2.y, r2
cmp_pp r2.x, -r2.y, c27.y, c27
mul_pp r2.w, r2.x, r2.z
cmp_pp r2.xyz, -r2.w, r1, r3.x
add_pp r3.x, -r0.w, c27.y
mul_pp r3.xyz, r2, r3.x
mad_pp r0.xyz, r0, r0.w, -r3
cmp_pp r0.xyz, -r2.w, r2, r0
mov r1.x, c0
add r1.y, v0, c12.x
mad r1.y, c14.x, r1.x, r1
add r1.z, v0.x, c11.x
mov r1.x, c0
mad r1.x, c13, r1, r1.z
texld r1.xyz, r1, s2
add_pp r4.xyz, -r1, c27.y
mad_pp r1.xyz, r4, c10.x, r1
mul_pp r2.xyz, r0, r1
mov r0.x, c0
add r0.y, v0, c17.x
mad r0.y, c19.x, r0.x, r0
add r0.z, v0.x, c16.x
mov r0.x, c0
mad r0.x, c18, r0, r0.z
texld r0.xyz, r0, s3
add_pp r3.xyz, -r0, c27.y
mad_pp r0.xyz, r3, c15.x, r0
add r1.x, v0.y, c21
mov r0.w, c0.x
mad r1.y, c23.x, r0.w, r1.x
add r1.x, v0, c21
mov r0.w, c0.x
mad r1.x, c22, r0.w, r1
texld r1.xyz, r1, s4
add_pp r4.xyz, -r1, c27.y
mad_pp r1.xyz, r4, c20.x, r1
mul_pp r0.xyz, r2, r0
mul_pp oC0.xyz, r0, r1
mov_pp oC0.w, r1
"
}

SubProgram "d3d11 " {
Keywords { }
ConstBuffer "$Globals" 160 // 148 used size, 28 vars
Float 16 [_Monochrome]
Vector 32 [_MonoColor] 4
Float 48 [_Contrast]
Float 52 [_Brightness]
Float 56 [_Title]
Float 60 [_MainOffsetX]
Float 64 [_MainOffsetY]
Float 68 [_MainSpeedX]
Float 72 [_MainSpeedY]
Float 76 [_VignetteAmount]
Float 80 [_VignetteOffsetX]
Float 84 [_VignetteOffsetY]
Float 88 [_VignetteSpeedX]
Float 92 [_VignetteSpeedY]
Float 96 [_Overlay1Amount]
Float 100 [_Overlay1OffsetX]
Float 104 [_Overlay1OffsetY]
Float 108 [_Overlay1SpeedX]
Float 112 [_Overlay1SpeedY]
Float 116 [_Overlay2Amount]
Float 124 [_Overlay2OffsetY]
Float 128 [_Overlay2SpeedX]
Float 132 [_Overlay2SpeedY]
Float 136 [_ColorJitter]
Float 140 [_ContrastJitter]
Float 144 [_BrightnessJitter]
ConstBuffer "UnityPerCamera" 128 // 16 used size, 8 vars
Vector 0 [_Time] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
SetTexture 0 [_MainTex] 2D 0
SetTexture 1 [_TitleTex] 2D 1
SetTexture 2 [_VignetteTex] 2D 2
SetTexture 3 [_Overlay1Tex] 2D 3
SetTexture 4 [_Overlay2Tex] 2D 4
// 52 instructions, 3 temp regs, 0 temp arrays:
// ALU 40 float, 0 int, 2 uint
// TEX 5 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0
eefiecedpipcalgpdjeblipeggfbhglbffcelimcabaaaaaalmaiaaaaadaaaaaa
cmaaaaaaieaaaaaaliaaaaaaejfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaaeeaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaadadaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfcee
aaklklklepfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklklfdeieefcpmahaaaa
eaaaaaaappabaaaafjaaaaaeegiocaaaaaaaaaaaakaaaaaafjaaaaaeegiocaaa
abaaaaaaabaaaaaafkaaaaadaagabaaaaaaaaaaafkaaaaadaagabaaaabaaaaaa
fkaaaaadaagabaaaacaaaaaafkaaaaadaagabaaaadaaaaaafkaaaaadaagabaaa
aeaaaaaafibiaaaeaahabaaaaaaaaaaaffffaaaafibiaaaeaahabaaaabaaaaaa
ffffaaaafibiaaaeaahabaaaacaaaaaaffffaaaafibiaaaeaahabaaaadaaaaaa
ffffaaaafibiaaaeaahabaaaaeaaaaaaffffaaaagcbaaaaddcbabaaaabaaaaaa
gfaaaaadpccabaaaaaaaaaaagiaaaaacadaaaaaaaaaaaaaibcaabaaaaaaaaaaa
akbabaaaabaaaaaadkiacaaaaaaaaaaaadaaaaaadcaaaaalbcaabaaaaaaaaaaa
akiacaaaabaaaaaaaaaaaaaabkiacaaaaaaaaaaaaeaaaaaaakaabaaaaaaaaaaa
aaaaaaaiecaabaaaaaaaaaaabkbabaaaabaaaaaaakiacaaaaaaaaaaaaeaaaaaa
dcaaaaalccaabaaaaaaaaaaaakiacaaaabaaaaaaaaaaaaaackiacaaaaaaaaaaa
aeaaaaaackaabaaaaaaaaaaaefaaaaajpcaabaaaabaaaaaaegaabaaaaaaaaaaa
eghobaaaaaaaaaaaaagabaaaaaaaaaaaefaaaaajpcaabaaaaaaaaaaaegaabaaa
aaaaaaaaeghobaaaabaaaaaaaagabaaaabaaaaaabaaaaaakbcaabaaaacaaaaaa
aceaaaaaihbgjjdokcefbgdpnfhiojdnaaaaaaaaegacbaaaabaaaaaaaaaaaaah
bcaabaaaacaaaaaaakaabaaaacaaaaaaabeaaaaaaaaaaalpdiaaaaaibcaabaaa
acaaaaaaakaabaaaacaaaaaaakiacaaaaaaaaaaaadaaaaaadiaaaaaibcaabaaa
acaaaaaaakaabaaaacaaaaaadkiacaaaaaaaaaaaaiaaaaaadiaaaaajccaabaaa
acaaaaaabkiacaaaaaaaaaaaadaaaaaaakiacaaaaaaaaaaaajaaaaaadcaaaaaj
bcaabaaaacaaaaaaakaabaaaacaaaaaaabeaaaaaaaaaaadpbkaabaaaacaaaaaa
dcaaaaaoocaabaaaacaaaaaakgikcaaaaaaaaaaaaiaaaaaaaceaaaaaaaaaaaaa
mnmmmmdnmnmmmmdnmnmmmmdnagijcaaaaaaaaaaaacaaaaaaaaaaaaahhcaabaaa
acaaaaaajgahbaaaacaaaaaaagaabaaaacaaaaaadjaaaaaiicaabaaaacaaaaaa
akiacaaaaaaaaaaaabaaaaaaabeaaaaaaaaaaaaaaaaaaaakhcaabaaaabaaaaaa
egacbaaaabaaaaaaaceaaaaaaaaaaalpaaaaaalpaaaaaalpaaaaaaaadgaaaaaf
iccabaaaaaaaaaaadkaabaaaabaaaaaadiaaaaaiicaabaaaabaaaaaadkiacaaa
aaaaaaaaaiaaaaaaabeaaaaaaaaaaadpdcaaaaakhcaabaaaabaaaaaaegacbaaa
abaaaaaaagiacaaaaaaaaaaaadaaaaaapgapbaaaabaaaaaadcaaaaalhcaabaaa
abaaaaaafgifcaaaaaaaaaaaadaaaaaaagiacaaaaaaaaaaaajaaaaaaegacbaaa
abaaaaaadhaaaaajhcaabaaaabaaaaaapgapbaaaacaaaaaaegacbaaaacaaaaaa
egacbaaaabaaaaaabaaaaaakicaabaaaabaaaaaaaceaaaaaihbgjjdokcefbgdp
lmhebddoaaaaaaaaegacbaaaabaaaaaaaaaaaaaibcaabaaaacaaaaaadkaabaia
ebaaaaaaaaaaaaaaabeaaaaaaaaaiadpdiaaaaahicaabaaaabaaaaaadkaabaaa
abaaaaaaakaabaaaacaaaaaadcaaaaakhcaabaaaacaaaaaaegacbaaaaaaaaaaa
pgapbaaaaaaaaaaapgapbaiaebaaaaaaabaaaaaadbaaaaahicaabaaaabaaaaaa
abeaaaaaaaaaaaaadkaabaaaaaaaaaaadjaaaaaiicaabaaaacaaaaaackiacaaa
aaaaaaaaadaaaaaaabeaaaaaaaaaaaaaabaaaaahicaabaaaabaaaaaadkaabaaa
abaaaaaadkaabaaaacaaaaaadhaaaaajhcaabaaaabaaaaaapgapbaaaabaaaaaa
egacbaaaacaaaaaaegacbaaaabaaaaaabnaaaaahicaabaaaaaaaaaaadkaabaaa
aaaaaaaaabeaaaaaaaaaiadpabaaaaahicaabaaaaaaaaaaadkaabaaaaaaaaaaa
dkaabaaaacaaaaaadhaaaaajhcaabaaaaaaaaaaapgapbaaaaaaaaaaaegacbaaa
aaaaaaaaegacbaaaabaaaaaaaaaaaaaidcaabaaaabaaaaaaegbabaaaabaaaaaa
egiacaaaaaaaaaaaafaaaaaadcaaaaaldcaabaaaabaaaaaaagiacaaaabaaaaaa
aaaaaaaaogikcaaaaaaaaaaaafaaaaaaegaabaaaabaaaaaaefaaaaajpcaabaaa
abaaaaaaegaabaaaabaaaaaaeghobaaaacaaaaaaaagabaaaacaaaaaaaaaaaaal
hcaabaaaacaaaaaaegacbaiaebaaaaaaabaaaaaaaceaaaaaaaaaiadpaaaaiadp
aaaaiadpaaaaaaaadcaaaaakhcaabaaaabaaaaaapgipcaaaaaaaaaaaaeaaaaaa
egacbaaaacaaaaaaegacbaaaabaaaaaadiaaaaahhcaabaaaaaaaaaaaegacbaaa
aaaaaaaaegacbaaaabaaaaaaaaaaaaaidcaabaaaabaaaaaaegbabaaaabaaaaaa
jgifcaaaaaaaaaaaagaaaaaadcaaaaalbcaabaaaacaaaaaaakiacaaaabaaaaaa
aaaaaaaadkiacaaaaaaaaaaaagaaaaaaakaabaaaabaaaaaadcaaaaalccaabaaa
acaaaaaaakiacaaaabaaaaaaaaaaaaaaakiacaaaaaaaaaaaahaaaaaabkaabaaa
abaaaaaaefaaaaajpcaabaaaabaaaaaaegaabaaaacaaaaaaeghobaaaadaaaaaa
aagabaaaadaaaaaaaaaaaaalhcaabaaaacaaaaaaegacbaiaebaaaaaaabaaaaaa
aceaaaaaaaaaiadpaaaaiadpaaaaiadpaaaaaaaadcaaaaakhcaabaaaabaaaaaa
agiacaaaaaaaaaaaagaaaaaaegacbaaaacaaaaaaegacbaaaabaaaaaadiaaaaah
hcaabaaaaaaaaaaaegacbaaaaaaaaaaaegacbaaaabaaaaaaaaaaaaaidcaabaaa
abaaaaaaegbabaaaabaaaaaapgipcaaaaaaaaaaaahaaaaaadcaaaaaldcaabaaa
abaaaaaaagiacaaaabaaaaaaaaaaaaaaegiacaaaaaaaaaaaaiaaaaaaegaabaaa
abaaaaaaefaaaaajpcaabaaaabaaaaaaegaabaaaabaaaaaaeghobaaaaeaaaaaa
aagabaaaaeaaaaaaaaaaaaalhcaabaaaacaaaaaaegacbaiaebaaaaaaabaaaaaa
aceaaaaaaaaaiadpaaaaiadpaaaaiadpaaaaaaaadcaaaaakhcaabaaaabaaaaaa
fgifcaaaaaaaaaaaahaaaaaaegacbaaaacaaaaaaegacbaaaabaaaaaadiaaaaah
hccabaaaaaaaaaaaegacbaaaaaaaaaaaegacbaaaabaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES"
}

SubProgram "gles3 " {
Keywords { }
"!!GLES3"
}

}

#LINE 134

		}
	} 
	FallBack "Diffuse"
}