using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

///Incorporates code from The HullCameraZoom class of Albert VDS's Mechjeb hullcam fork
///(See http://forum.kerbalspaceprogram.com/threads/46365-0-23-Hullcam-VDS-Added-new-cameras-by-Rubber-Ducky-Updated-30-Dec)
///And design recommended by a question on the unity forums answered by skovacs1 
///(See http://answers.unity3d.com/questions/25965/camera-orbit-on-mouse-drag.html)
namespace HullcamVDS {

public class EVACamera : MuMechModuleHullCamera
    {        
    [KSPField]
    new public float cameraFoVMax = 60;
    
    [KSPField]
    new public float cameraFoVMin = 60;
    
    [KSPField]
    new public float cameraZoomMult = 1.1f;
            
    private bool resetting = false; //The green dude is in the act of facing forward again
    private float resetTimer = 0.0F; //Our countdown for the motion of looking forward again
    private float resetTime = 0.25F; //How long to take to reset
    private float lookSpeed = 10.0F; //Sensitivity to mouse movement
    
    private Vector3 eyeOffset = Vector3.forward * 0.1F; //Eyes don't exist at a point when you move your head
    private Vector3 headLocation = Vector3.up * .35f; // Where the centre of the head is
    
    private float Latitude = 0.0F;
    private float Azimuth = 0.0F;
    
    private float maxLatitude = 38.0F; // Don't allow further motion that this (degrees)
    private float maxAzimuth = 60.0F;
     
    private float endLatitude = 0.0F; //the angles we've reached upon letting go of the mouse
    private float endAzimuth = 0.0F; 
    
    private Quaternion rotation;
    private bool init = false; //Because I wanted code to run on construction, but couldn't figure it out.
    
    public override void OnUpdate()
    {
        base.OnUpdate();
        
        ///THIS IS A HACK
        if (!init) {
            cameraPosition = headLocation + eyeOffset;
            cameraClip = 0.08f;
            init = true;
        }
        //I got lazy. I'm sure there's a better way to do this, but I wasn't sure how exactly a constructor would be 
        //called when adding the module to the part (i.e. the Kerbal).
        ///END HACK
        
        if (vessel == null)
        {
            return;
        }

        if (!camActive || CameraManager.Instance.currentCameraMode != CameraManager.CameraMode.Flight)
            return;
       
        if (GameSettings.ZOOM_IN.GetKeyDown() || (Input.GetAxis("Mouse ScrollWheel") > 0))
        {
            cameraFoV = Mathf.Clamp(cameraFoV / cameraZoomMult, cameraFoVMin, cameraFoVMax);
        }
        if (GameSettings.ZOOM_OUT.GetKeyDown() || (Input.GetAxis("Mouse ScrollWheel") < 0))
        {
            cameraFoV = Mathf.Clamp(cameraFoV * cameraZoomMult, cameraFoVMin, cameraFoVMax);
        }
        if (MapView.MapIsEnabled) 
        { 
            cameraFoV = Mathf.Clamp (cameraFoV / cameraZoomMult, cameraFoVMin, cameraFoVMax);
        }
        
        ///NEW STUFF HERE:
        if(!resetting && Input.GetMouseButtonUp(1)) { //Released right mouse button
         resetting = true; 
         endLatitude = Latitude; //the angles we've reached upon letting go of the mouse
         endAzimuth = Azimuth;
         resetTimer = resetTime; //Reset the reset timer (count down)
         resetting = true;
        }
        if(!resetting && Input.GetMouseButton(1)) { // Right Mouse Button Down
            //Change the angles by the mouse movement
            Azimuth += Input.GetAxis("Mouse X") * lookSpeed;
            Latitude += Input.GetAxis("Mouse Y") * lookSpeed;
            if (Mathf.Abs(Azimuth) > maxAzimuth) {
                Azimuth = maxAzimuth * Mathf.Sign(Azimuth);
            }
            if (Mathf.Abs(Latitude) > maxLatitude) {
                Latitude = maxLatitude * Mathf.Sign(Latitude);
            }
            Reorient();
        } //button held down
        if(resetting && !Input.GetMouseButton(1)) { //Reset
            resetTimer -= Time.deltaTime; //keep counting down;
            if (resetTimer <= 0.0F) { // don't allow negative timer values
                resetTimer = 0.0F;
                resetting = false;
            }
            var amountReset = resetTimer / resetTime; //How far we are in the reset
            Latitude = Mathf.LerpAngle(0.0F, endLatitude, amountReset); //Interpolate
            Azimuth = Mathf.LerpAngle(0.0F, endAzimuth, amountReset);
            Reorient();
        }
    }
    
    private void Reorient() {
        //Euler angle rotation of our up and forward camera vectors
        rotation = Quaternion.Euler(0.0F, Azimuth, 0.0F) * Quaternion.Euler(-Latitude, 0.0F, 0.0F);
        cameraForward = rotation * Vector3.forward;
        cameraUp = rotation * Vector3.up;
        cameraPosition = headLocation + rotation * eyeOffset;
    }
}

//Add EVA camera to all Kerbals on EVA
[KSPAddon(KSPAddon.Startup.MainMenu, true)]
public class initKerbalEVA : UnityEngine.MonoBehaviour {
	public void Awake() {
           
		ConfigNode EVA = new ConfigNode("MODULE");
		EVA.AddValue("name", "EVACamera");
		EVA.AddValue("cameraName", "EVACam");

		try {
						
			PartLoader.getPartInfoByName("kerbalEVA").partPrefab.AddModule(EVA);
		}
		catch{}
		try { PartLoader.getPartInfoByName("kerbalEVAfemale").partPrefab.AddModule(EVA); 
		}
		catch {}
	}
}

}