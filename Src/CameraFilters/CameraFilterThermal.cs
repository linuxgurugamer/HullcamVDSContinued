// CameraFilterThermal.cs
//
// Author: Marc Bernier
//   Date: 2014-11-25

using UnityEngine;

namespace HullcamVDS {
  public class CameraFilterThermal : CameraFilter {
    public CameraFilterThermal() : base() { }

    public override bool Activate() {

      Vessel activeVessel = FlightGlobals.ActiveVessel;
      Debug.Log(string.Format("VESSEL \"{0}\"", activeVessel.vesselName));
      foreach (Part part in activeVessel.parts) {
        Debug.Log(string.Format("PART \"{0}\" {1}/{2}", part.partName, part.temperature, part.maxTemp));
        foreach (PartModule partModule in part.Modules) {
          Debug.Log(string.Format("MODULE \"{0}\"", partModule.moduleName));
        }
      }

      return true;
    }

    public override void Deactivate() {
    }

    public override void OptionControls() {
    }

    public override void LateUpdate() {
      Vessel activeVessel = FlightGlobals.ActiveVessel;
      foreach (Part part in activeVessel.parts)
        SetPartGlow(part, true);
    }

    private void SetPartGlow(Part part, bool active) {
      if (active) {

        part.SetHighlightColor(Color.magenta);
        part.SetHighlightType(Part.HighlightType.AlwaysOn);
        part.SetHighlight(true, true);

      } else {
        /*        part.SetHighlightColor(Color.red);
                part.SetHighlightType(Part.HighlightType.OnMouseOver);
                part.SetHighlight(false);*/
      }
      /*      foreach (Part child in part.children)
              SetPartGlow(part, active); */
    }
  }
}