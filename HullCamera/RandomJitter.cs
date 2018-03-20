// RandomJitter.cs
//
// Author: Marc Bernier
//   Date: 2014-12-20

using System;

namespace HullcamVDS {
  public class RandomJitter {
    private System.Random random = new System.Random();
    private DateTime lastEvent = DateTime.Now;
    private float value;

    private float minLimit = 0;
    private float maxLimit = 0;
    private float maxJump = 0;
    private int interval = 0;

    public RandomJitter(float minLim, float maxLim, float maxJmp, int intervl) {
      minLimit = minLim;
      maxLimit = maxLim;
      maxJump = maxJmp;
      interval = intervl;
    }

    public float NextValue() {
      if ((DateTime.Now - lastEvent).TotalMilliseconds < interval)
        return value;

      lastEvent = DateTime.Now;
      float randNo = random.Next(1000) * maxJump / 1000 - maxJump / 2;
      value = Math.Min(Math.Max(value + randNo, minLimit), maxLimit);
      return value;
    }

    public float Value() {
      return value;
    }
  }
}