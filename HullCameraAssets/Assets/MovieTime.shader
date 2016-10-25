Shader "Custom/MovieTime" {
	Properties {
		_MainTex("Base Texture", 2D)="white" {}
		_TitleTex("Title Texture", 2D)="black" {}
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
		Pass {
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform sampler2D _TitleTex;
			uniform sampler2D _VignetteTex;
			uniform sampler2D _Overlay1Tex;
			uniform sampler2D _Overlay2Tex;

			fixed _Monochrome;
			fixed4 _MonoColor;
			fixed _Contrast;
			fixed _Brightness;

			float _Title;

			float _MainOffsetX;
			float _MainOffsetY;
			float _MainSpeedX;
			float _MainSpeedY;

			float _VignetteAmount;
			float _VignetteOffsetX;
			float _VignetteOffsetY;
			float _VignetteSpeedX;
			float _VignetteSpeedY;

			float _Overlay1Amount;
			float _Overlay1OffsetX;
			float _Overlay1OffsetY;
			float _Overlay1SpeedX;
			float _Overlay1SpeedY;

			float _Overlay2Amount;
			float _Overlay2OffsetX;
			float _Overlay2OffsetY;
			float _Overlay2SpeedX;
			float _Overlay2SpeedY;

			fixed _ColorJitter;
			fixed _ContrastJitter;
			fixed _BrightnessJitter;

			fixed4 frag(v2f_img i) : COLOR {
				fixed3 constantWhite=fixed3(1,1,1);

				half2 renderTexUV = half2(i.uv.x+_MainOffsetX+_Time.x*_MainSpeedX, i.uv.y+_MainOffsetY+_Time.x*_MainSpeedY);
				fixed4 renderTex = tex2D(_MainTex, renderTexUV);

				half2 titleUV = half2(i.uv.x+_MainOffsetX+_Time.x*_MainSpeedX, i.uv.y+_MainOffsetY+_Time.x*_MainSpeedY);
				fixed4 titleTex = tex2D(_TitleTex, titleUV);

				half2 vignetteUV = half2(i.uv.x+_VignetteOffsetX+_Time.x*_VignetteSpeedX, i.uv.y+_VignetteOffsetY+_Time.x*_VignetteSpeedY);
				fixed4 vignetteTex = tex2D(_VignetteTex, vignetteUV);

				half2 overlay1UV = half2(i.uv.x+_Overlay1OffsetX+_Time.x*_Overlay1SpeedX, i.uv.y+_Overlay1OffsetY+_Time.x*_Overlay1SpeedY);
				fixed4 overlay1Tex = tex2D(_Overlay1Tex, overlay1UV);

				half2 overlay2UV = half2(i.uv.x+_Overlay2OffsetY+_Time.x*_Overlay2SpeedX, i.uv.y+_Overlay2OffsetY+_Time.x*_Overlay2SpeedY);
				fixed4 overlay2Tex = tex2D(_Overlay2Tex, overlay2UV);

				if (_Monochrome!=0) {
					renderTex.rgb=dot(fixed3(0.299, 0.587, 0.114), renderTex.rgb);
					renderTex.rgb=(renderTex.rgb - 0.5f)*_Contrast*_ContrastJitter*0.5f;
					renderTex.rgb+=_Brightness*_BrightnessJitter;
					renderTex.rgb+=lerp(_MonoColor, _MonoColor+fixed4(0.1f, 0.1f, 0.1f, 0.1f), _ColorJitter);
				} else {
					renderTex.rgb=(renderTex.rgb-0.5f)*_Contrast+_ContrastJitter*0.5f;
					renderTex.rgb+=_Brightness*_BrightnessJitter;
				}

				if (_Title!=0 && titleTex.a>=1) {
					renderTex.rgb=titleTex.rgb;
				} else if (_Title!=0 && titleTex.a>0) {
					renderTex.rgb=dot(fixed3(0.299, 0.587, 0.144), renderTex.rgb);
					renderTex.rgb=titleTex.rgb*titleTex.a-renderTex.rgb*(1-titleTex.a);
				}

				renderTex.rgb*=lerp(vignetteTex.rgb, constantWhite, _VignetteAmount);
				renderTex.rgb*=lerp(overlay1Tex.rgb, constantWhite, _Overlay1Amount);
				renderTex.rgb*=lerp(overlay2Tex.rgb, constantWhite, _Overlay2Amount);
				return renderTex;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
