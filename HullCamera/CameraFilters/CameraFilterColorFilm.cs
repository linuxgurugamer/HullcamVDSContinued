// CameraFilterColorFilm.cs
//
// Author: Marc Bernier
//   Date: 2014-11-16

using UnityEngine;

namespace HullcamVDS {
  public class CameraFilterColorFilm : CameraFilter {
    private float brightness = .35f;

    private float vignetteAmount = .45f;
    private float overlay1Amount = .67f;
    private float overlay2Amount = .88f;

    private RandomJitter brightnessJitter = new RandomJitter(.95f, 1.05f, .005f, 0);
    private RandomJitter vignetteXJitter = new RandomJitter(-.001f, .001f, .0005f, 0);
    private RandomJitter vignetteYJitter = new RandomJitter(-.001f, .001f, .0005f, 0);
    private RandomJitter overlay1XJitter = new RandomJitter(0, 1, .1f, 10000);
    private RandomJitter overlay2XJitter = new RandomJitter(0, 1, 1, 300);
    private RandomJitter overlay2YJitter = new RandomJitter(0, 1, 1, 300);

    public CameraFilterColorFilm() : base() { }

    public override void OptionControls() {
      GUILayout.BeginVertical();
      brightness = GetSliderValue("Brightness:", brightness, 0, 2);
      vignetteAmount = GetSliderValue("Vignette:", vignetteAmount, 0, 1);
      overlay1Amount = GetSliderValue("Scratches:", overlay1Amount, 0, 1);
      overlay2Amount = GetSliderValue("Dust:", overlay2Amount, 0, 1);
      GUILayout.EndVertical();
    }

    public override void RenderImageWithFilter(RenderTexture source, RenderTexture target) {
      if (mtShader != null && filmVignette != null && scratches != null && dust != null) {

        mtShader.SetTexture("_VignetteTex", filmVignette);
        mtShader.SetTexture("_Overlay1Tex", scratches);
        mtShader.SetTexture("_Overlay2Tex", dust);

        mtShader.SetFloat("_Monochrome", 0);
        mtShader.SetColor("_MonoColor", new Color(.5f, .5f, .5f, 1));
        mtShader.SetFloat("_ColorJitter", 1);
        mtShader.SetFloat("_Contrast", 2);
        mtShader.SetFloat("_ContrastJitter", 1);
        mtShader.SetFloat("_Brightness", brightness);
        mtShader.SetFloat("_BrightnessJitter", brightnessJitter.NextValue());

        mtShader.SetFloat("_MainOffsetX", vignetteXJitter.NextValue());
        mtShader.SetFloat("_MainOffsetY", vignetteYJitter.NextValue());
        mtShader.SetFloat("_MainSpeedX", 0);
        mtShader.SetFloat("_MainSpeedY", 0);

        mtShader.SetFloat("_VignetteAmount", vignetteAmount);
        mtShader.SetFloat("_VignetteOffsetX", vignetteXJitter.Value());
        mtShader.SetFloat("_VignetteOffsetY", vignetteYJitter.Value());
        mtShader.SetFloat("_VignetteSpeedX", 0);
        mtShader.SetFloat("_VignetteSpeedY", 0);

        mtShader.SetFloat("_Overlay1Amount", overlay1Amount);
        mtShader.SetFloat("_Overlay1OffsetX", overlay1XJitter.NextValue());
        mtShader.SetFloat("_Overlay1OffsetY", 0);
        mtShader.SetFloat("_Overlay1SpeedX", 0);
        mtShader.SetFloat("_Overlay1SpeedY", -50);

        mtShader.SetFloat("_Overlay2Amount", overlay2Amount);
        mtShader.SetFloat("_Overlay2OffsetX", overlay2XJitter.NextValue());
        mtShader.SetFloat("_Overlay2OffsetY", overlay2YJitter.NextValue());
        mtShader.SetFloat("_Overlay2SpeedX", 0);
        mtShader.SetFloat("_Overlay2SpeedY", 0);

        Graphics.Blit(source, target, mtShader);
      } else {
        base.RenderImageWithFilter(source, target);
      }
    }

  }
}