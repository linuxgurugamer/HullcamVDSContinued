// VHoldRoller.cs
//
// Author: Marc Bernier
//   Date: 2014-12-20

using System;

namespace HullcamVDS {
  public class VHoldRoller {
    private float rollSpeed = 0;
    private int rollFrequency = 0;

    private DateTime lastRoll = DateTime.Now;
    private bool rolling = false;
    private float rollOffset = 0;

    public VHoldRoller() { }

    public void SetRollSpeed(float speed) {
      rollSpeed = (speed > -.01 && speed < .01 ? 0 : speed);
    }

    public void SetRollFrequency(int frequency) {
      if (rollFrequency != frequency) {
        lastRoll = DateTime.Now;
        rolling = false;
      }
      rollFrequency = frequency;
    }

    public float CalculcateRollOffset() {
      if (!rolling && rollFrequency > 0 && (DateTime.Now - lastRoll).TotalSeconds >= rollFrequency) {
        rolling = true;
        rollOffset = 0;
      } else if (rolling && (rollOffset >= 1 || rollOffset <= -1)) {
        rolling = false;
        lastRoll = DateTime.Now;
      }
      if (rolling) {
        rollOffset += rollSpeed;
        return rollOffset;
      }
      return 0;
    }

    public float GetRollOffset() {
      return rollOffset;
    }
  }
}