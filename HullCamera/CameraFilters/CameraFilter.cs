// CameraFilter.cs
//
// Author: Marc Bernier
//   Date: 2014-11-14

using System;
using System.IO;
using System.Collections.Generic;

using UnityEngine;
//using KSP.IO;

namespace HullcamVDS
{

    // Base class for camera filters
    public class CameraFilter
    {

        public enum eCameraMode
        {
            Normal = 0,
            DockingCam = 1,
            BlackAndWhiteFilm = 2,
            BlackAndWhiteLoResTV = 3,
            BlackAndWhiteHiResTV = 4,
            ColorFilm = 5,
            ColorLoResTV = 6,
            ColorHiResTV = 7,
            NightVision = 8
        }

        protected static Material mtShader = null;
        protected static Material nvShader = null;

        protected static Texture2D dockingDisplay = null;
        protected static Texture2D filmVignette = null;
        protected static Texture2D scratches = null;
        protected static Texture2D dust = null;
        protected static Texture2D noise = null;
        protected static Texture2D crtMesh = null;
        protected static Texture2D nvMesh = null;
        protected static Texture2D vHold = null;
        protected static Texture2D noneTX = null;

        public static bool InitializeAssets()
        {
            if (mtShader == null && nvShader == null && dockingDisplay == null && filmVignette == null && scratches == null && dust == null && noise == null && crtMesh == null && nvMesh == null && vHold == null)
            {
                mtShader = LoadShaderFile("MovieTime.shader");
                nvShader = LoadShaderFile("NightVision.shader");
                dockingDisplay = LoadTextureFile("dockingdisplay");
                filmVignette = LoadTextureFile("FilmVignette.png");
                scratches = LoadTextureFile("Scratches.png");
                dust = LoadTextureFile("Dust.png");
                noise = LoadTextureFile("Noise.png");
                crtMesh = LoadTextureFile("CRTMesh.png");
                nvMesh = LoadTextureFile("NVMesh.png");
                vHold = LoadTextureFile("VHold.png");
                noneTX = LoadTextureFile("none.png");


                if (dockingDisplay != null) dockingDisplay.wrapMode = TextureWrapMode.Repeat;
                if (filmVignette != null) filmVignette.wrapMode = TextureWrapMode.Repeat;
                if (scratches != null) scratches.wrapMode = TextureWrapMode.Repeat;
                if (dust != null) dust.wrapMode = TextureWrapMode.Repeat;
                if (noise != null) noise.wrapMode = TextureWrapMode.Repeat;
                if (crtMesh != null) crtMesh.wrapMode = TextureWrapMode.Repeat;
                if (nvMesh != null) nvMesh.wrapMode = TextureWrapMode.Repeat;
                if (vHold != null) vHold.wrapMode = TextureWrapMode.Repeat;
                if (noneTX != null) noneTX.wrapMode = TextureWrapMode.Repeat;

                if (mtShader != null && nvShader != null && dockingDisplay != null && filmVignette != null && scratches != null && dust != null && noise != null && crtMesh != null && nvMesh != null && vHold != null && noneTX != null)
                    return false;
            }
            return true;
        }

        public static void ReleaseAssets()
        {
            if (mtShader != null) MonoBehaviour.Destroy(mtShader);
            mtShader = null;
            if (nvShader != null) MonoBehaviour.Destroy(nvShader);
            nvShader = null;
            if (dockingDisplay != null) MonoBehaviour.Destroy(dockingDisplay);
            dockingDisplay = null;
            if (filmVignette != null) MonoBehaviour.Destroy(filmVignette);
            filmVignette = null;
            if (scratches != null) MonoBehaviour.Destroy(scratches);
            scratches = null;
            if (dust != null) MonoBehaviour.Destroy(dust);
            dust = null;
            if (noise != null) MonoBehaviour.Destroy(noise);
            noise = null;
            if (crtMesh != null) MonoBehaviour.Destroy(crtMesh);
            crtMesh = null;
            if (nvMesh != null) MonoBehaviour.Destroy(nvMesh);
            nvMesh = null;
            if (vHold != null) MonoBehaviour.Destroy(vHold);
            vHold = null;
            if (noneTX != null) MonoBehaviour.Destroy(noneTX);
            noneTX = null;
        }

        // CameraFilter class factory:
        public static CameraFilter CreateFilter(eCameraMode cameraMode)
        {
            switch (cameraMode)
            {
                case eCameraMode.Normal:
                    return new CameraFilterNormal();
                case eCameraMode.DockingCam:
                    return new CameraFilterDockingCam();
                case eCameraMode.BlackAndWhiteFilm:
                    return new CameraFilterBlackAndWhiteFilm();
                case eCameraMode.BlackAndWhiteLoResTV:
                    return new CameraFilterBlackAndWhiteLoResTV();
                case eCameraMode.BlackAndWhiteHiResTV:
                    return new CameraFilterBlackAndWhiteHiResTV();
                case eCameraMode.ColorFilm:
                    return new CameraFilterColorFilm();
                case eCameraMode.ColorLoResTV:
                    return new CameraFilterColorLoResTV();
                case eCameraMode.ColorHiResTV:
                    return new CameraFilterColorHiResTV();
                case eCameraMode.NightVision:
                    return new CameraFilterNightVision();
            }
            return null;
        }

        public virtual void Load(string moduleName)
        {
        }

        public virtual void Save(string moduleName)
        {
        }

        public CameraFilter() { }

        public virtual bool Activate() { return true; }

        public virtual void Deactivate() { }

        public virtual void OptionControls() { }

        public virtual void LateUpdate() { }

        public virtual void RenderImageWithFilter(RenderTexture source, RenderTexture target)
        {
            Graphics.Blit(source, target);
        }

        public virtual void RenderTitlePage(bool title, Texture2D titleTex)
        {
            //Debug.Log("RenderTitlePage");        
            if (mtShader == null)
            {
                //Debug.Log("mtShader is null");
                return;
            }
            mtShader.SetFloat("_Title", (title && titleTex != null ? 1 : 0));
            if (title && titleTex != null)
                mtShader.SetTexture("_TitleTex", titleTex);
        }

        protected bool GetToggleValue(string label, bool value)
        {
            GUILayout.BeginHorizontal();
            bool retVal = GUILayout.Toggle(value, label);
            GUILayout.EndHorizontal();
            return retVal;
        }

        protected float GetSliderValue(string label, float value, float leftValue, float rightValue)
        {
            GUILayout.BeginHorizontal();
            GUILayout.Label(label);
            float retVal = GUILayout.HorizontalSlider(value, leftValue, rightValue);
            GUILayout.Label(string.Format("{0:0.00}", value));
            GUILayout.EndHorizontal();
            return retVal;
        }

        private static bool BundleLoaded = false;
        private static Dictionary<string, Shader> LoadedShaders = new Dictionary<string, Shader>();

        public static void LoadBundle()
        {
            if (BundleLoaded)
                return;

			string bundleName;
            Debug.Log("Application.platform: " + Application.platform.ToString());

            switch (Application.platform)
			{
				case RuntimePlatform.OSXPlayer:
				bundleName = "shaders.osx";
				break;

                case RuntimePlatform.LinuxPlayer:
                    bundleName = "shaders.linux";
                    break;

                case RuntimePlatform.WindowsPlayer:
                    if (SystemInfo.graphicsDeviceVersion.Contains("OpenGL"))
                    {
                        Debug.Log("OpenGL found");
                        bundleName = "shaders.windows";
                    }
                    else
                    {
                        Debug.Log("Not OpenGL");
                        bundleName = "shaders.bundle";
                    }
                    
                    break;

                default:
				bundleName = "shaders.windows";
				break;
			}
            using (WWW www = new WWW("file://" + KSPUtil.ApplicationRootPath + "GameData/HullCameraVDS/Resources/" + bundleName))
            {
                if (www.error != null)
                    Debug.Log("Shaders bundle not found!");

                AssetBundle bundle = www.assetBundle;

                Shader[] shaders = bundle.LoadAllAssets<Shader>();

                foreach (Shader shader in shaders)
                {
                    Debug.Log("Shader " + shader.name + " is loaded");
                    LoadedShaders.Add(shader.name, shader);
                }

                bundle.Unload(false);
                www.Dispose();

                BundleLoaded = true;
            }
        }

        public static Material LoadShaderFile(string fileName)
        {
            string s = "";
            try
            {
#if true
                if (!BundleLoaded)
                    LoadBundle();
                Shader shader = null;
                if (fileName == "MovieTime.shader")                    
                    s = "Custom/MovieTime";
                if (fileName == "NightVision.shader")
                    s = "Custom/NightVision";
                if (LoadedShaders.ContainsKey(s))
                    return new Material(LoadedShaders[s]);
                if (shader == null)

                {
                    Debug.Log("1 shader is null");

                    return null; // new Material(fileName);
                }
                Debug.Log("shader: " + shader.ToString());
                return new Material(shader);
#else

                string path = KSPUtil.ApplicationRootPath.Replace(@"\", "/") + "/GameData/HullCameraVDS/Shaders/" + fileName;
                StreamReader reader = new StreamReader(path);
                string shader = reader.ReadToEnd();
                Debug.Log("shader: " + fileName + "  :  " + shader.ToString());
                reader.Close();
                return new Material(shader);
#endif
            }
            catch (Exception ex)
            {
                Debug.Log(string.Format("MovieTime: LoadShaderFile exception: {0}", ex.Message));
            }
            return null;
        }

        public static Texture2D LoadTextureFile(string fileName)
        {
            try
            {
                string path;

                if (Screen.height <= 850)
                    path = KSPUtil.ApplicationRootPath.Replace(@"\", "/") + "/GameData/HullCameraVDS/Textures/Low/" + fileName;
                else if (Screen.height <= 1000)
                    path = KSPUtil.ApplicationRootPath.Replace(@"\", "/") + "/GameData/HullCameraVDS/Textures/Medium/" + fileName;
                else
                    path = KSPUtil.ApplicationRootPath.Replace(@"\", "/") + "/GameData/HullCameraVDS/Textures/High/" + fileName;

                if (!File.Exists(path))
                    path = KSPUtil.ApplicationRootPath.Replace(@"\", "/") + "/GameData/HullCameraVDS/Textures/" + fileName;

                byte[] texture = File.ReadAllBytes(path);
                Texture2D retVal = new Texture2D(1, 1, TextureFormat.ARGB32, true);
                retVal.LoadImage(texture);
                return retVal;
            }
            catch (Exception ex)
            {
                Debug.Log(string.Format("MovieTime: LoadTextureFile exception: {0}", ex.Message));
            }
            return null;
        }
    }
}