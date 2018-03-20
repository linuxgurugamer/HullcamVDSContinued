// CameraFilterBlackAndWhiteHiResTV.cs
//
// Author: Marc Bernier
//   Date: 2014-11-18

using UnityEngine;

namespace HullcamVDS {
  public class CameraFilterBlackAndWhiteHiResTV : CameraFilter {
    private float contrast = 3.09f;
    private float brightness = .10f;

    private float vignetteAmount = .75f;
    private float overlay1Amount = .76f;
    private float overlay2Amount = .78f;
    private int rollFrequency = 0;
    private float rollSpeed = .04f;

    private RandomJitter overlay2Jitter = new RandomJitter(0, 1, 1, 0);
    private VHoldRoller vHoldRoller = new VHoldRoller();

    public CameraFilterBlackAndWhiteHiResTV() : base() { }

    public override bool Activate() {
      vHoldRoller.SetRollSpeed(rollSpeed);
      vHoldRoller.SetRollFrequency(rollFrequency);
      return true;
    }

    public override void RenderImageWithFilter(RenderTexture source, RenderTexture target) {
      if (mtShader != null && vHold != null && crtMesh != null && noise != null) {

        mtShader.SetTexture("_VignetteTex", vHold);
        mtShader.SetTexture("_Overlay1Tex", crtMesh);
        mtShader.SetTexture("_Overlay2Tex", noise);
		mtShader.SetTexture ("_TitleTex", noneTX);

        mtShader.SetFloat("_Monochrome", 1);
        mtShader.SetColor("_MonoColor", new Color(.5f, .5f, .5f, 1));
        mtShader.SetFloat("_ColorJitter", 1);
        mtShader.SetFloat("_Contrast", contrast);
        mtShader.SetFloat("_ContrastJitter", 1);
        mtShader.SetFloat("_Brightness", brightness);
        mtShader.SetFloat("_BrightnessJitter", 1);

        source.wrapMode = TextureWrapMode.Repeat;
        mtShader.SetFloat("_MainOffsetX", 0);
        mtShader.SetFloat("_MainOffsetY", vHoldRoller.CalculcateRollOffset());
        mtShader.SetFloat("_MainSpeedX", 0);
        mtShader.SetFloat("_MainSpeedY", 0);

        mtShader.SetFloat("_VignetteAmount", vignetteAmount);
        mtShader.SetFloat("_VignetteOffsetX", 0);
        mtShader.SetFloat("_VignetteOffsetY", vHoldRoller.GetRollOffset());
        mtShader.SetFloat("_VignetteSpeedX", 0);
        mtShader.SetFloat("_VignetteSpeedY", 0);

        mtShader.SetFloat("_Overlay1Amount", overlay1Amount);
        mtShader.SetFloat("_Overlay1OffsetX", 0);
        mtShader.SetFloat("_Overlay1OffsetY", 0);
        mtShader.SetFloat("_Overlay1SpeedX", 0);
        mtShader.SetFloat("_Overlay1SpeedY", 0);

        mtShader.SetFloat("_Overlay2Amount", overlay2Amount);
        mtShader.SetFloat("_Overlay2OffsetX", overlay2Jitter.NextValue());
        mtShader.SetFloat("_Overlay2OffsetY", overlay2Jitter.NextValue());
        mtShader.SetFloat("_Overlay2SpeedX", 0);
        mtShader.SetFloat("_Overlay2SpeedY", 0);

        Graphics.Blit(source, target, mtShader);
      } else {
        base.RenderImageWithFilter(source, target);
      }
    }


  }
}