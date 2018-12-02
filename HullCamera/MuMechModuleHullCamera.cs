using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

namespace HullcamVDS
{

    public class MuMechModuleHullCamera : PartModule
    {
        MovieTime mt = new MovieTime();

        // TODO: Bugs:
        // - If the vessel is entirely destroyed with AllowMainCamera == false it's still possible to get stuck without a camera.
        //   When that happens the menus don't work and we're stuck.
        //   The part might be dead but not removed, so part management needs improving.

        // TODO: If we prevent cycling between different vessels, then it's a better experience to keep track of each vessels active camera.
        // TODO: Test action groups.
        // TODO: Look at describing what camera we're viewing from.

        // TODO: No-main-camera issues:
        // - Can't rename vessel
        // - Can't make crew reports
        // - Can't control from different places

        private const bool adjustMode = false;

        [KSPField]
        public float cameraFoVMax = 60;

        [KSPField]
        public float cameraFoVMin = 60;

        [KSPField]
        public float cameraZoomMult = 1.25f;

        [KSPAction("Zoom In")]
        public void ZoomInAction(KSPActionParam ap)
        {
            sActionFlags.zoomIn = true;
        }

        [KSPAction("Zoom Out")]
        public void ZoomOutAction(KSPActionParam ap)
        {
            sActionFlags.zoomOut = true;
        }

        [KSPField]
        public Vector3 cameraPosition = Vector3.zero;

        [KSPField]
        public Vector3 cameraForward = Vector3.forward;

        [KSPField]
        public Vector3 cameraFlip = Vector3.forward;

        [KSPField]
        public Vector3 cameraUp = Vector3.up;

        [KSPField]
        public string cameraTransformName = "";

        [KSPField]
        public bool allowFlip = false;

        [KSPField]
        public float cameraFoV = 60;

        [KSPField(isPersistant = false)]
        public float cameraClip = 0.01f;

        [KSPField]
        public bool camActive = false; // Saves when we're viewing from this camera.

        [KSPField]
        public bool camEnabled = true; // Lets us skip cycling through cameras.

        [KSPField(isPersistant = false)]
        public string cameraName = "Hull";

        [KSPField]
        public float cameraMode = 0;

        [KSPField(isPersistant = false)]
        public string mode = "Hull";

        public static List<MuMechModuleHullCamera> sCameras = new List<MuMechModuleHullCamera>();

        // Keep track of the camera we're viewing from.
        // A null value represents using the main camera.
        public static MuMechModuleHullCamera sCurrentCamera = null;

        // One camera module is the designated input handler, all others ignore it.
        // A camera's destroy function clears this and we have to set another in the update routine.
        public static MuMechModuleHullCamera sCurrentHandler = null;

        // Stores the current flight camera.
        protected static FlightCamera sCam = null;

        // Camera distance from active vessel
        public double sCameraDistance = double.NaN;

        // Takes a backup of the external camera.
        protected static Transform sOrigParent = null;
        protected static Quaternion sOrigRotation = Quaternion.identity;
        protected static Vector3 sOrigPosition = Vector3.zero;
        protected static float sOrigFov;
        protected static float sOrigClip;
        protected static Texture2D sOverlayTex = null;


        // Stores the intended action to allow it to be passed to the update function.
        // Is there a reason for the action being deferred until Update, or can they just call the same function?
        protected struct ActionFlags
        {
            public bool deactivateCamera;
            public bool nextCamera;
            public bool prevCamera;
            public bool zoomIn;
            public bool zoomOut;
        }
        protected static ActionFlags sActionFlags;

        #region Configuration

        public static KeyBinding CAMERA_NEXT = new KeyBinding(KeyCode.O);
        public static KeyBinding CAMERA_PREV = new KeyBinding(KeyCode.P);
        public static KeyBinding CAMERA_RESET = new KeyBinding(KeyCode.Escape);

        // Allows switching to the main camera.
        // The main camera will only be used if there aren't any camera parts to use.
        public static bool sAllowMainCamera = true;

        // If the main camera can be switched to, allows cycling to it via next/previous actions.
        public static bool sCycleToMainCamera = true;

        // Prevents cycling to cameras not on the active vessel.
        public static bool sCycleOnlyActiveVessel = false;

        // Whether to log things to the debug log.
        // This could be made into an integer that describes how many things to log.
        public static bool sDebugOutput = false;

        public static bool sDisplayCameraNameWhenSwitching = true;
        public static bool sDisplayVesselNameWhenSwitching = true;
        public static float sMessageDuration = 3.0f;

        #endregion

        #region Static Initialization

        protected static void DebugOutput(object o)
        {
   			if (sDebugOutput)
            {
                Debug.Log("HullCam: " + o.ToString());
            }
        }

        //protected static bool sInit = false;

        protected static void StaticInit()
        {
            // Commented out so that we can reload the config by reloading a save file rather than restarting KSP.
            /*
			if (sInit)
			{
				return;
			}
			sInit = true;
			*/

            try
            {
                foreach (ConfigNode cfg in GameDatabase.Instance.GetConfigNodes("HullCameraVDSConfig"))
                {
                    if (cfg.HasNode("CAMERA_NEXT"))
                    {
                        CAMERA_NEXT.Load(cfg.GetNode("CAMERA_NEXT"));
                    }
                    if (cfg.HasNode("CAMERA_PREV"))
                    {
                        CAMERA_PREV.Load(cfg.GetNode("CAMERA_PREV"));
                    }
                    if (cfg.HasNode("CAMERA_RESET"))
                    {
                        CAMERA_RESET.Load(cfg.GetNode("CAMERA_RESET"));
                    }
                    if (cfg.HasValue("CycleMainCamera"))
                    {
                        sCycleToMainCamera = Boolean.Parse(cfg.GetValue("CycleMainCamera"));
                    }
                    if (cfg.HasValue("AllowMainCamera"))
                    {
                        sAllowMainCamera = Boolean.Parse(cfg.GetValue("AllowMainCamera"));
                    }
                    if (cfg.HasValue("CycleOnlyActiveVessel"))
                    {
                        sCycleOnlyActiveVessel = Boolean.Parse(cfg.GetValue("CycleOnlyActiveVessel"));
                    }
                    if (cfg.HasValue("DebugOutput"))
                    {
                        sDebugOutput = Boolean.Parse(cfg.GetValue("DebugOutput"));
                    }

                    if (cfg.HasValue("DisplayCameraNameWhenSwitching"))
                    {
                        sDisplayCameraNameWhenSwitching = Boolean.Parse(cfg.GetValue("DisplayCameraNameWhenSwitching"));
                    }
                    if (cfg.HasValue("DisplayVesselNameWhenSwitching"))
                    {
                        sDisplayVesselNameWhenSwitching = Boolean.Parse(cfg.GetValue("DisplayVesselNameWhenSwitching"));
                    }
                    if (cfg.HasValue("MessageDuration"))
                    {
                        try
                        {
                            sMessageDuration = (float)Double.Parse(cfg.GetValue("MessageDuration"));
                        }
                        catch { }
                        if (sMessageDuration < 1 || sMessageDuration > 10)
                            sMessageDuration = 3;
                    }
                }
            }
            catch (Exception e)
            {
                print("Exception when loading HullCamera config: " + e.ToString());
            }

            Debug.Log(string.Format("CMC: {0} AMC: {1} COA: {2}", sCycleToMainCamera, sAllowMainCamera, sCycleOnlyActiveVessel));
        }

        #endregion

        static Part sOrigVesselTransformPart;

        protected static void SaveMainCamera()
        {
            DebugOutput("SaveMainCamera");

            sOrigParent = sCam.transform.parent;
            sOrigClip = Camera.main.nearClipPlane;
            sOrigFov = Camera.main.fieldOfView;
            sOrigPosition = sCam.transform.localPosition;
            sOrigRotation = sCam.transform.localRotation;
            if (sOrigVesselTransformPart == null)
            {
                sOrigVesselTransformPart = FlightGlobals.ActiveVessel.GetReferenceTransformPart();
                ScreenMessages.PostScreenMessage("Original Control Point: " + sOrigVesselTransformPart.partInfo.title);
            }
        }

        protected static void RestoreMainCamera()
        {
            DebugOutput("RestoreMainCamera");

            if (sCam != null)
            {
                sCam.transform.parent = sOrigParent;
                sCam.transform.localPosition = sOrigPosition;
                sCam.transform.localRotation = sOrigRotation;
                sCam.SetFoV(sOrigFov);
                sCam.ActivateUpdate();

                if (FlightGlobals.ActiveVessel != null && HighLogic.LoadedScene == GameScenes.FLIGHT)
                {
                    //sCam.SetTarget(FlightGlobals.ActiveVessel.transform, FlightCamera.TargetMode.Transform);
                    sCam.SetTarget(FlightGlobals.ActiveVessel.transform, FlightCamera.TargetMode.Vessel);
                }

                sOrigParent = null;
            }
            if (sCurrentCamera != null)
            {
                sCurrentCamera.mt.SetCameraMode(CameraFilter.eCameraMode.Normal);
                sCurrentCamera.camActive = false;
            }
            sCurrentCamera = null;
            Camera.main.nearClipPlane = sOrigClip;

            /////////////////////////////////////

            if (sOrigVesselTransformPart != null)
            {
                if (GameSettings.MODIFIER_KEY.GetKey(false))
                {
#if false
                    ModuleDockingNode mdn = sOrigVesselTransformPart.FindModuleImplementing<ModuleDockingNode>();
                    if (mdn != null)
                    {
                        sOrigVesselTransformPart.SetReferenceTransform(mdn.controlTransform);
                    } else
#endif
                    {
                       // sOrigVesselTransformPart.SetReferenceTransform(sOrigVesselTransformPart.GetReferenceTransform());
                    }

                    FlightGlobals.ActiveVessel.SetReferenceTransform(sOrigVesselTransformPart, true);
                    ScreenMessages.PostScreenMessage("Control Point restored to " + sOrigVesselTransformPart.partInfo.title);
                    sOrigVesselTransformPart = null;
                }
            }
            /////////////////////////////////////


        }

        public static void changeCameraMode()
        {
            DebugOutput("changeCameraMode");
            if (sCurrentCamera.cameraMode == 0)
            {
                sCurrentCamera.mt.SetCameraMode(CameraFilter.eCameraMode.Normal);
            }
            if (sCurrentCamera.cameraMode == 1)
            {
                sCurrentCamera.mt.SetCameraMode(CameraFilter.eCameraMode.DockingCam);
            }
            if (sCurrentCamera.cameraMode == 2)
            {
                sCurrentCamera.mt.SetCameraMode(CameraFilter.eCameraMode.BlackAndWhiteFilm);
            }
            if (sCurrentCamera.cameraMode == 3)
            {
                sCurrentCamera.mt.SetCameraMode(CameraFilter.eCameraMode.BlackAndWhiteLoResTV);
            }
            if (sCurrentCamera.cameraMode == 4)
            {
                sCurrentCamera.mt.SetCameraMode(CameraFilter.eCameraMode.BlackAndWhiteHiResTV);
            }
            if (sCurrentCamera.cameraMode == 5)
            {
                sCurrentCamera.mt.SetCameraMode(CameraFilter.eCameraMode.ColorFilm);
            }
            if (sCurrentCamera.cameraMode == 6)
            {
                sCurrentCamera.mt.SetCameraMode(CameraFilter.eCameraMode.ColorLoResTV);
            }
            if (sCurrentCamera.cameraMode == 7)
            {
                sCurrentCamera.mt.SetCameraMode(CameraFilter.eCameraMode.ColorHiResTV);
            }
            if (sCurrentCamera.cameraMode == 8)
            {
                sCurrentCamera.mt.SetCameraMode(CameraFilter.eCameraMode.NightVision);
            }
        }

        protected static void CycleCamera(int direction)
        {
            DebugOutput(String.Format("CycleMainCamera({0})", direction));

            // Find the next camera to switch to, deactivate the current camera and activate the new one.
            MuMechModuleHullCamera newCam = sCurrentCamera;

            // Iterates the number of cameras and returns as soon as a camera is chosen.
            // Then if no camera is chosen, restore main camera as a last-ditch effort.
            for (int i = 0; i < sCameras.Count + 1; i++)
            {

                // Check if cycle direction is referse and if the current cam is the first hullZcam
                if (direction == -1 && sCameras.IndexOf(sCurrentCamera) == 0)
                {
                    sCurrentCamera.camActive = false;
                    RestoreMainCamera();
                    return;
                }
                int nextCam = sCameras.IndexOf(newCam) + direction;
                if (nextCam >= sCameras.Count)
                {
                    if (sAllowMainCamera && sCycleToMainCamera)
                    {
                        if (sCurrentCamera != null)
                        {
                            sCurrentCamera.camActive = false;
                            RestoreMainCamera();
                        }
                        return;
                    }
                    nextCam = (direction > 0) ? 0 : sCameras.Count - 1;
                }
                newCam = sCameras[nextCam];

#if true
            
                if (newCam.vessel == FlightGlobals.ActiveVessel)
                {
                    if (GameSettings.MODIFIER_KEY.GetKey(false))
                    {
                        ModuleDockingNode mdn = newCam.part.FindModuleImplementing<ModuleDockingNode>();
                        if (mdn != null)
                        {
                            if (sOrigVesselTransformPart == null)
                            {
                                sOrigVesselTransformPart = FlightGlobals.ActiveVessel.GetReferenceTransformPart();
                                ScreenMessages.PostScreenMessage("Original Control Point: " + sOrigVesselTransformPart.partInfo.title);
                            }

                            newCam.part.SetReferenceTransform(mdn.controlTransform);
                            FlightGlobals.ActiveVessel.SetReferenceTransform(newCam.part, true);

                            ScreenMessages.PostScreenMessage("Control Point changed to " + newCam.part.partInfo.title);
                        }
                    }
                }

#endif

                if (sCycleOnlyActiveVessel && FlightGlobals.ActiveVessel != null && FlightGlobals.ActiveVessel != newCam.vessel)
                {
                    continue;
                }


                if (newCam.camEnabled && newCam.part.State != PartStates.DEAD)
                {
                    if (sCurrentCamera != null)
                    {
                        sCurrentCamera.camActive = false;
                    }
                    sCurrentCamera = newCam;
                    changeCameraMode();
                    sCurrentCamera.camActive = true;
                    IdentifyCamera();

                    return;
                }
            }
            // Failed to find a camera including cycling back to the one we started from. Default to main as a last-ditch effort.
            if (sCurrentCamera != null)
            {
                sCurrentCamera.camActive = false;
                sCurrentCamera = null;
                RestoreMainCamera();
            }
        }

        static void IdentifyCamera()
        {
            if (sCurrentCamera != null && sDisplayCameraNameWhenSwitching)
            {
                if (sDisplayVesselNameWhenSwitching)
                    ScreenMessages.PostScreenMessage("Switching to camera: " + sCurrentCamera.cameraName + " on vessel " + sCurrentCamera.vessel.GetDisplayName(), sMessageDuration, ScreenMessageStyle.UPPER_CENTER);
                else
                    ScreenMessages.PostScreenMessage("Switching to camera: " + sCurrentCamera.cameraName, sMessageDuration, ScreenMessageStyle.UPPER_CENTER);
            }
        }

        protected static void LeaveCamera()
        {
            DebugOutput("LeaveCamera");

            if (sCurrentCamera == null)
            {
                return;
            }
            if (sAllowMainCamera)
            {
                RestoreMainCamera();
            }
            else
            {
                DebugOutput(" 5");
                CycleCamera(1);
            }
        }

        protected void Activate()
        {
            DebugOutput("Activate");

            if (part.State == PartStates.DEAD)
            {
                return;
            }
            if (camActive)
            {
                if (sAllowMainCamera)
                {
                    RestoreMainCamera();
                }
                else
                {
                    DebugOutput(" 6");
                    CycleCamera(1);
                }
                return;
            }

            sCurrentCamera = this;
            camActive = true;
            changeCameraMode();

        }

        protected void DirtyWindow()
        {
            foreach (UIPartActionWindow w in GameObject.FindObjectsOfType(typeof(UIPartActionWindow)).Where(w => ((UIPartActionWindow)w).part == part))
            {
                w.displayDirty = true;
            }
        }

#region Events

        // Note: Events show in the part menu in flight.

        [KSPEvent(guiActive = true, guiName = "Activate Camera")]
        public void ActivateCamera()
        {
            Activate();
        }

        [KSPEvent(guiActive = true, guiName = "Disable Camera")]
        public void EnableCamera()
        {
            if (part.State == PartStates.DEAD)
            {
                return;
            }
            camEnabled = !camEnabled;
            Events["EnableCamera"].guiName = camEnabled ? "Disable Camera" : "Enable Camera";


            DirtyWindow();
        }

#endregion

#region Actions

        // Note: Actions are available to action groups.

        [KSPAction("Activate Camera")]
        public void ActivateCameraAction(KSPActionParam ap)
        {
            Activate();
        }

        [KSPAction("Deactivate Camera")]
        public void DeactivateCameraAction(KSPActionParam ap)
        {
            if (part.State == PartStates.DEAD)
            {
                return;
            }
            camEnabled = !camEnabled;
            Events["EnableCamera"].guiName = camEnabled ? "Deactivate Camera" : "Activate Camera";
            DirtyWindow();
        }

        [KSPAction("Next Camera")]
        public void NextCameraAction(KSPActionParam ap)
        {
            sActionFlags.nextCamera = true;
        }

        [KSPAction("Previous Camera")]
        public void PreviousCameraAction(KSPActionParam ap)
        {
            sActionFlags.prevCamera = true;
        }

#endregion

#region Callbacks

        void DebugList()
        {

            foreach (PartModule s in sCameras)
            {
                Debug.Log(s);
            }

        }

        public void LateUpdate()
        {
            // In the VAB
            if (vessel == null)
            {
                return;
            }

            if (sCurrentHandler == null)
            {
                sCurrentHandler = this;
            }

#if false
            if (Input.GetKeyDown(KeyCode.Y) ) {

				print (sCameras.Count);
				print ("sCurrentCamera: " + sCurrentCamera);
				print ("This: " + this);
				print ("sCurrentHandler: " + sCurrentHandler);
				print ("sCurrentCamera.vessel: " + sCurrentCamera.vessel);
				print ("FlightGlobals.ActiveVessel: " + FlightGlobals.ActiveVessel);
				print (sCameras.Count);
				print (sOrigParent);
				print (sActionFlags.nextCamera);
				print (sCycleToMainCamera);
				print (sCameras.IndexOf(sCurrentCamera));
				DebugList ();
			}
#endif

            if (sCurrentCamera != null)
            {
                if (sCurrentCamera.vessel != FlightGlobals.ActiveVessel)
                {
                    Vector3d activeVesselPos = FlightGlobals.ActiveVessel.orbit.getRelativePositionAtUT(Planetarium.GetUniversalTime()) + FlightGlobals.ActiveVessel.orbit.referenceBody.position;
                    Vector3d targetVesselPos = sCurrentCamera.vessel.orbit.getRelativePositionAtUT(Planetarium.GetUniversalTime()) + sCurrentCamera.vessel.orbit.referenceBody.position;

                    sCameraDistance = (activeVesselPos - targetVesselPos).magnitude;

                    if (sCameraDistance >= 2480)
                    {
                        LeaveCamera();
                    }
                }
            }

            if (CameraManager.Instance.currentCameraMode != CameraManager.CameraMode.Flight)
            {
                return;
            }

#if true
            if (sActionFlags.deactivateCamera || CAMERA_RESET.GetKeyDown() || GameSettings.CAMERA_NEXT.GetKeyDown())
            {
                LeaveCamera();
                sActionFlags.deactivateCamera = false;
            }
#endif
            if (sActionFlags.nextCamera || (sCurrentHandler == this && CAMERA_NEXT.GetKeyDown()))
            {
                CycleCamera(1);
                sActionFlags.nextCamera = false;
            }
#if true
            if (sActionFlags.prevCamera || (sCurrentHandler == this && CAMERA_PREV.GetKeyDown()))
            {
                if (sCameras.IndexOf(sCurrentCamera) != -1)
                {
                    CycleCamera(-1);
                    sActionFlags.prevCamera = false;
                }
                else
                {
                    DebugOutput(" 2");
                    CycleCamera(sCameras.Count);
                }
            }
#endif




            /*
	        if (sCurrentCamera == this)
			{
	            if (Input.GetKeyUp(KeyCode.Keypad8))
	            {
	                cameraPosition += cameraUp * 0.1f;
	            }
	            if (Input.GetKeyUp(KeyCode.Keypad2))
	            {
	                cameraPosition -= cameraUp * 0.1f;
	            }
	            if (Input.GetKeyUp(KeyCode.Keypad6))
	            {
	                cameraPosition += cameraForward * 0.1f;
	            }
	            if (Input.GetKeyUp(KeyCode.Keypad4))
	            {
	                cameraPosition -= cameraForward * 0.1f;
	            }
	            if (Input.GetKeyUp(KeyCode.Keypad7))
	            {
	                cameraClip += 0.05f;
	            }
	            if (Input.GetKeyUp(KeyCode.Keypad1))
	            {
	                cameraClip -= 0.05f;
	            }
	            if (Input.GetKeyUp(KeyCode.Keypad9))
	            {
	                cameraFoV += 5;
	            }
	            if (Input.GetKeyUp(KeyCode.Keypad3))
	            {
	                cameraFoV -= 5;
	            }
	            if (Input.GetKeyUp(KeyCode.KeypadMinus))
	            {
	                print("Position: " + cameraPosition + " - Clip = " + cameraClip + " - FoV = " + cameraFoV);
	            }
	        } */
            doOnUpdate();
        }

        //public override void OnUpdate()
        void doOnUpdate()
        {
            //base.OnUpdate();

            if (vessel == null)
            {
                return;
            }


            if (!camActive || CameraManager.Instance.currentCameraMode != CameraManager.CameraMode.Flight)
                return;

            if (sActionFlags.zoomIn || GameSettings.ZOOM_IN.GetKeyDown() || (Input.GetAxis("Mouse ScrollWheel") > 0))
            {
                cameraFoV = Mathf.Clamp(cameraFoV / cameraZoomMult, cameraFoVMin, cameraFoVMax);
                sActionFlags.zoomIn = false;
            }
            if (sActionFlags.zoomOut || GameSettings.ZOOM_OUT.GetKeyDown() || (Input.GetAxis("Mouse ScrollWheel") < 0))
            {
                cameraFoV = Mathf.Clamp(cameraFoV * cameraZoomMult, cameraFoVMin, cameraFoVMax);
                sActionFlags.zoomOut = false;
            }
            if (MapView.MapIsEnabled)
            {
                cameraFoV = Mathf.Clamp(cameraFoV / cameraZoomMult, cameraFoVMin, cameraFoVMax);
            }
        }

        public void FixedUpdate()
        {
            // In the VAB
            if (vessel == null)
            {
                return;
            }
            // following "if" added by jbb
            if (MapView.MapIsEnabled)
            {
                return;
            }

            if (part.State == PartStates.DEAD)
            {
                if (camActive)
                {
                    LeaveCamera();
                }
                Events["ActivateCamera"].guiActive = false;
                Events["EnableCamera"].guiActive = false;
                camEnabled = false;
                camActive = false;
                DirtyWindow();
                CleanUp();
                return;
            }

            if (!sAllowMainCamera && sCurrentCamera == null && !vessel.isEVA)
            {
                camActive = true;
                sCurrentCamera = this;
            }

            if (!camActive)
            {
                return;
            }

            if (!camEnabled)
            {
                DebugOutput(" 3");
                CycleCamera(1);
                return;
            }

            if (sCam == null)
            {
                sCam = FlightCamera.fetch;
                // No idea if fetch returns null in normal operation (i.e. when there isn't a game breaking bug going on already)
                // but the original code had similar logic.
                if (sCam == null)
                {
                    return;
                }
            }

            // Either we haven't set sOriginParent, or we've nulled it when restoring the main camera, so we save it again here.
            if (sOrigParent == null)
            {
                SaveMainCamera();
            }


            //sCam.SetTarget(null);
            sCam.SetTargetNone();
            sCam.transform.parent = (cameraTransformName.Length > 0) ? part.FindModelTransform(cameraTransformName) : part.transform;
            sCam.DeactivateUpdate();
            sCam.transform.localPosition = cameraPosition;



            sCam.transform.localRotation = Quaternion.LookRotation(cameraForward, cameraUp);
            sCam.SetFoV(cameraFoV);
            Camera.main.nearClipPlane = cameraClip;

            // If we're only allowed to cycle the active vessel and viewing through a camera that's not the active vessel any more, then cycle to one that is.
            if (sCycleOnlyActiveVessel && FlightGlobals.ActiveVessel != null && FlightGlobals.ActiveVessel != vessel)
            {
                DebugOutput(" 4");
                CycleCamera(1);
            }

            base.OnFixedUpdate();
        }

        private void onGameSceneLoadRequested(GameScenes gameScene)
        {
            if (sCurrentCamera != null)
            {
                print("Clearing camera list");
                sCameras.Clear();
                sCurrentCamera.mt.SetCameraMode(CameraFilter.eCameraMode.Normal);
                sCurrentCamera = null;
            }
        }


        public override void OnStart(StartState state)
        {
            StaticInit();

            GameEvents.onGameSceneLoadRequested.Add(onGameSceneLoadRequested);


            // Reading camEnabled right away, so is something setting this value?
            // KSPFields are saving game state.
            // So this must also be called when we load the game too.
            if ((state != StartState.None) && (state != StartState.Editor))
            {
                if (!sCameras.Contains(this))
                {
                    sCameras.Add(this);
                    this.cameraFoV = this.cameraFoVMax;
                    DebugOutput(String.Format("Added, now {0}", sCameras.Count));
                }
                vessel.OnJustAboutToBeDestroyed += CleanUp;
            }
            part.OnJustAboutToBeDestroyed += CleanUp;
            part.OnEditorDestroy += CleanUp;

            if (part.State == PartStates.DEAD)
            {
                Events["ActivateCamera"].guiActive = false;
                Events["EnableCamera"].guiActive = false;
            }
            else
            {
                Events["EnableCamera"].guiName = camEnabled ? "Disable Camera" : "Enable Camera";
            }

            base.OnStart(state);
        }

        public void CleanUp()
        {
            DebugOutput("Cleanup");
            if (sCurrentHandler == this)
            {
                DebugOutput("sCurrentHandler is this");
                sCurrentHandler = null;
            }
            if (sCurrentCamera == this)
            {
                DebugOutput("If it's the current camera");
                // On destruction, revert to main camera so we're not left hanging.
                LeaveCamera();

            }
            if (sCameras.Contains(this))
            {
                sCameras.Remove(this);
                DebugOutput(String.Format("Removed, now {0}", sCameras.Count));
                // This happens when we're saving and reloading.

                if (sCameras.Count < 1 && sOrigParent != null && !this.camActive)
                {
                    DebugOutput("Set sCurrentCamera to null");
                    sCurrentCamera = null;
                    DebugOutput("RestoreMainCamera");
                    RestoreMainCamera();
                    DebugOutput("RestoringMainCamera");
                }
            }
        }

        public void onVesselDestroy()
        {
            if (sCameras.Contains(this))
            {
                DebugOutput("onVesselDestroy");
                sCameras.Remove(this);
                DebugOutput(String.Format("Removed, now {0}", sCameras.Count));
                LeaveCamera();
            }
        }

        public void OnDestroy()
        {
            DebugOutput("OnDestroy");
            CleanUp();
        }

        private void Remove()
        {
            DebugOutput("On Unload");
            LeaveCamera();
        }



#endregion
    }

}