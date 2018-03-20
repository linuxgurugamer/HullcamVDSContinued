// MovieTime.cs
//
// Author: Marc Bernier
//   Date: 2014-12-28

using System;
using UnityEngine;

namespace HullcamVDS
{
    [KSPAddon(KSPAddon.Startup.Flight, false)]
    public class MovieTime : MonoBehaviour
    {

        // Docking cam settings
        private static GUIStyle guiStyle = new GUIStyle("label");

        public bool HasTargetData;

        public string targetName;
        public string currentMode;

        public double targetDistance = double.NaN;
        public double targetRelVelocity = double.NaN;
        public double targetVelX;
        public double targetVelY;
        public double targetVelZ;

        public string closeAp;

        // Filter settings

        private static MovieTimeFilter flightCameraFilter = null;

        public MovieTime() { }

        public void Awake()
        {
            CameraFilter.InitializeAssets();
        }

        public void Start()
        {

            guiStyle.fontSize = 20;

            flightCameraFilter = CreateFilter(FlightCamera.fetch.mainCamera);

            if (flightCameraFilter != null) flightCameraFilter.Initialize("Flight", MovieTimeFilter.eFilterType.Flight);

            RefreshTitleTexture();
        }

        public static void DrawOutline(Rect rect, string text, GUIStyle style)
        {
            float halfSize = 4 * 0.5F;
            GUIStyle backupStyle = new GUIStyle(style);
            Color backupColor = GUI.color;

            style.normal.textColor = Color.black;
            GUI.color = Color.black;

            rect.x -= halfSize;
            GUI.Label(rect, text, style);

            rect.x += 4;
            GUI.Label(rect, text, style);

            rect.x -= halfSize;
            rect.y -= halfSize;
            GUI.Label(rect, text, style);

            rect.y += 4;
            GUI.Label(rect, text, style);

            rect.y -= halfSize;
            style.normal.textColor = Color.white;
            GUI.color = backupColor;
            GUI.Label(rect, text, style);

            style = backupStyle;
        }

        private void LateUpdate()
        {
            if (flightCameraFilter != null && MovieTimeFilter.LoadedScene() == MovieTimeFilter.eFilterType.Flight)
            {
                flightCameraFilter.LateUpdate();

            }
        }

        public void setNightVision()
        {
            Debug.Log("setNightVision");
            SetCameraMode(CameraFilter.eCameraMode.NightVision);
        }

        void OnGUI()
        {
            if (!MapView.MapIsEnabled)
            {

                if (HasTargetData && currentMode == "DockingCam")
                {



                    guiStyle.normal.textColor = Color.white;
                    guiStyle.alignment = TextAnchor.MiddleLeft;
                    DrawOutline(new Rect(Screen.width / 6, Screen.height / 2 + 80, 300, 25), "Relative Velocity", guiStyle);
                    DrawOutline(new Rect(Screen.width / 6, Screen.height / 2 + 100, 300, 25), "X:", guiStyle);
                    DrawOutline(new Rect(Screen.width / 6, Screen.height / 2 + 120, 300, 25), "Y:", guiStyle);
                    DrawOutline(new Rect(Screen.width / 6, Screen.height / 2 + 140, 300, 25), "Z:", guiStyle);
                    guiStyle.alignment = TextAnchor.MiddleRight;
                    DrawOutline(new Rect(Screen.width / 6 + 20, Screen.height / 2 + 100, 150, 25), targetVelX + "m/s", guiStyle);
                    DrawOutline(new Rect(Screen.width / 6 + 20, Screen.height / 2 + 120, 150, 25), targetVelY + "m/s", guiStyle);
                    DrawOutline(new Rect(Screen.width / 6 + 20, Screen.height / 2 + 140, 150, 25), targetVelZ + "m/s", guiStyle);
                    guiStyle.alignment = TextAnchor.MiddleLeft;

                    DrawOutline(new Rect(Screen.width / 6, Screen.height / 2 + 18, 800, 25), "Target:" + targetName, guiStyle);
                    DrawOutline(new Rect(Screen.width / 6, Screen.height / 2 + 40, 300, 25), "DST:", guiStyle);
                    DrawOutline(new Rect(Screen.width / 6, Screen.height / 2 + 60, 400, 25), "TCA:", guiStyle);
                    guiStyle.alignment = TextAnchor.MiddleRight;
                    DrawOutline(new Rect(Screen.width / 6 + 20, Screen.height / 2 + 40, 150, 25), Math.Round(targetDistance, 2) + "m", guiStyle);
                    guiStyle.alignment = TextAnchor.MiddleLeft;

                }
            }
        }

        public void Update()
        {

            //if (MapView.MapIsEnabled) {
            //	movieTimeFilter.SetMode (CameraFilter.eCameraMode.Normal);
            //}

            if (Input.GetKeyDown(KeyCode.O))
            {
                print(currentMode);
            }

            HasTargetData = (FlightGlobals.ActiveVessel.targetObject is Vessel);
            currentMode = GetCameraMode().ToString();

            if (HasTargetData)
            {

                targetName = FlightGlobals.fetch.VesselTarget.GetName();
                targetVelX = Math.Round(Vector3d.Dot(FlightGlobals.ship_tgtVelocity, FlightGlobals.ActiveVessel.ReferenceTransform.right), 3);
                targetVelY = Math.Round(Vector3d.Dot(FlightGlobals.ship_tgtVelocity, FlightGlobals.ActiveVessel.ReferenceTransform.forward), 3);
                targetVelZ = Math.Round(Vector3d.Dot(FlightGlobals.ship_tgtVelocity, FlightGlobals.ActiveVessel.ReferenceTransform.up), 3);

                Vessel targetVessel = (Vessel)FlightGlobals.ActiveVessel.targetObject;
                Orbit activeOrbit = FlightGlobals.ActiveVessel.orbit;
                Orbit targetOrbit = targetVessel.orbit;

                Vector3d activeVesselPos = FlightGlobals.ActiveVessel.orbit.getRelativePositionAtUT(Planetarium.GetUniversalTime()) + FlightGlobals.ActiveVessel.orbit.referenceBody.position;
                Vector3d targetVesselPos = targetVessel.orbit.getRelativePositionAtUT(Planetarium.GetUniversalTime()) + targetVessel.orbit.referenceBody.position;

                targetDistance = (activeVesselPos - targetVesselPos).magnitude;
            }






        }

        public void OnDestroy()
        {
            Debug.Log("OnDestroy");
            SetCameraMode(CameraFilter.eCameraMode.Normal);
        }

        private CameraFilter.eCameraMode GetCameraMode()
        {
            if (flightCameraFilter != null && MovieTimeFilter.LoadedScene() == MovieTimeFilter.eFilterType.Flight)
                return flightCameraFilter.GetMode();
            return CameraFilter.eCameraMode.Normal;
        }

        public void SetCameraMode(CameraFilter.eCameraMode mode)
        {
            Debug.Log("SetCameraMode");
            if (flightCameraFilter != null && MovieTimeFilter.LoadedScene() == MovieTimeFilter.eFilterType.Flight)
            {
                flightCameraFilter.SetMode(mode);
            }
        }

        public void ToggleTitleMode() { }

        protected void RefreshTitleTexture()
        {
            if (flightCameraFilter != null && MovieTimeFilter.LoadedScene() == MovieTimeFilter.eFilterType.Flight)
                flightCameraFilter.RefreshTitleTexture();
        }

        public MovieTimeFilter CreateFilter(Camera camera)
        {
            if (camera != null)
            {
                MovieTimeFilter retVal = camera.gameObject.GetComponent<MovieTimeFilter>();
                if (retVal == null)
                {
                    camera.gameObject.AddComponent<MovieTimeFilter>();
                    retVal = camera.gameObject.GetComponent<MovieTimeFilter>();
                }
                return retVal;
            }
            return null;
        }


    }
}