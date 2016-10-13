// MovieTimeFilter.cs
//
// Author: Marc Bernier
//   Date: 2014-11-16

using UnityEngine;

namespace HullcamVDS {
  public class MovieTimeFilter : MonoBehaviour {
    public enum eFilterType { Flight, Map, Centre, TrackingStation };

    protected static eFilterType currentMode;

    private string moduleName = "";
    private CameraFilter cameraFilter = null;
    private CameraFilter.eCameraMode cameraMode;
    private eFilterType filterType;

    private bool title = true;
	private string titleFile = "dockingdisplay.png";
    private Texture2D titleTexture = null;

    public MovieTimeFilter() {
    }

    public void Initialize(string module, eFilterType filtType, bool initializeCamera = true) {
      moduleName = module;
      filterType = filtType;


      if (initializeCamera) {
        cameraFilter = CameraFilter.CreateFilter(cameraMode);
        cameraFilter.Activate();
      }
      currentMode = (filterType == eFilterType.Map ? eFilterType.Flight : filterType);

      if (titleFile != "")
        titleTexture = CameraFilter.LoadTextureFile(titleFile);
    }



    public void SetMode(CameraFilter.eCameraMode mode) {
            Debug.Log("SetMode");
      if (mode != cameraMode) {
        CameraFilter newFilter = CameraFilter.CreateFilter(mode);
        if (newFilter != null && newFilter.Activate()) {
          if (cameraFilter != null) {
            cameraFilter.Save(moduleName);
            cameraFilter.Deactivate();
          }
          cameraFilter = newFilter;
          cameraFilter.Load(moduleName);
          cameraMode = mode;
        }
      }
    }

    public void ToggleTitleMode() {
      title = !title;
    }

    public void RefreshTitleTexture() {

      if (titleTexture != null)
        MonoBehaviour.Destroy(titleTexture);
      titleTexture = null;
      if (titleFile != "")
        titleTexture = CameraFilter.LoadTextureFile(titleFile);
    }

    public CameraFilter GetFilter() {
      return cameraFilter;
    }

    public void SetFilter(CameraFilter filter) {
      cameraFilter = filter;
    }

    public CameraFilter.eCameraMode GetMode() {
      return cameraMode;
    }
	
		public void Update() {

		}

		public void LateUpdate() {
			if (cameraFilter != null)
				cameraFilter.LateUpdate();
    }

    private void OnRenderImage(RenderTexture source, RenderTexture target) {
      if (cameraFilter != null && filterType == LoadedScene()) {
        cameraFilter.RenderTitlePage(title, titleTexture);
        cameraFilter.RenderImageWithFilter(source, target);
      } else {
        Graphics.Blit(source, target);
      }
    }



    public static eFilterType LoadedScene() {
      if (currentMode == eFilterType.Flight && !MapView.MapIsEnabled)
        return eFilterType.Flight;
      else if (currentMode == eFilterType.Flight && MapView.MapIsEnabled)
        return eFilterType.Map;
      return currentMode;
    }
  }
}