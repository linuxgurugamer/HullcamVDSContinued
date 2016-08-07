// CameraFilterDockingCam.cs
//
// Author: Marc Bernier
//   Date: 2014-11-16

using UnityEngine;

namespace HullcamVDS {
  public class CameraFilterDockingCam : CameraFilter {
    private float contrast = 4;
    private float brightness = .6f;

    private RandomJitter brightnessJitter = new RandomJitter(.95f, 1.05f, .005f, 0);

    public CameraFilterDockingCam() : base() { }

    public override void RenderImageWithFilter(RenderTexture source, RenderTexture target) {
      if (mtShader != null && filmVignette != null && scratches != null & dust != null) {

		mtShader.SetTexture("_VignetteTex", filmVignette);
		mtShader.SetTexture("_Overlay1Tex", filmVignette);
		mtShader.SetTexture("_Overlay2Tex", filmVignette);


        mtShader.SetFloat("_Monochrome", 1);
        mtShader.SetColor("_MonoColor", new Color(.5f, .5f, .5f, .5f));
        mtShader.SetFloat("_ColorJitter", 1);
        mtShader.SetFloat("_Contrast", contrast);
        mtShader.SetFloat("_ContrastJitter", 1);
        mtShader.SetFloat("_Brightness", brightness);
        mtShader.SetFloat("_BrightnessJitter", brightnessJitter.NextValue());

        mtShader.SetFloat("_MainOffsetX", 0);
        mtShader.SetFloat("_MainOffsetY", 0);
        mtShader.SetFloat("_MainSpeedX", 0);
        mtShader.SetFloat("_MainSpeedY", 0);

        mtShader.SetFloat("_VignetteAmount", 0);
        mtShader.SetFloat("_VignetteOffsetX", 0);
        mtShader.SetFloat("_VignetteOffsetY", 0);
        mtShader.SetFloat("_VignetteSpeedX", 0);
        mtShader.SetFloat("_VignetteSpeedY", 0);

        mtShader.SetFloat("_Overlay1Amount", 0);
        mtShader.SetFloat("_Overlay1OffsetX", 0);
        mtShader.SetFloat("_Overlay1OffsetY", 0);
        mtShader.SetFloat("_Overlay1SpeedX", 0);
        mtShader.SetFloat("_Overlay1SpeedY", 0);

        mtShader.SetFloat("_Overlay2Amount", 0);
        mtShader.SetFloat("_Overlay2OffsetX", 0);
        mtShader.SetFloat("_Overlay2OffsetY", 0);
        mtShader.SetFloat("_Overlay2SpeedX", 0);
        mtShader.SetFloat("_Overlay2SpeedY", 0);

        Graphics.Blit(source, target, mtShader);
      } else {
        base.RenderImageWithFilter(source, target);
      }
    }


  }
}