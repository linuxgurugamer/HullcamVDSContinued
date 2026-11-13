using HullcamVDS;
using System.Linq;

namespace HullCamera
{
    public class HullCameraVesselModule : VesselModule
    {
        protected override void OnStart()
        {
            base.OnStart();
            this.enabled = true;
        }

        public override void OnUnloadVessel()
        {
            // Clean up camera before its transform gets destroyed
            foreach (var camera in MuMechModuleHullCamera.sCameras.Where(c => c.vessel.id == this.vessel.id).ToList())
            {
                MuMechModuleHullCamera.DebugOutput("OnUnloadVessel");
                camera.CleanUp();
            }

            base.OnUnloadVessel();
        }
    }
}
