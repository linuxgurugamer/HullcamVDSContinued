using UnityEditor;

public class CreateAssetBundles
{
    [MenuItem("My Mod/Build Bundles")]
    static void BuildAllAssetBundles()
    {
        BuildPipeline.BuildAssetBundles("Bundles-windows", BuildAssetBundleOptions.UncompressedAssetBundle, BuildTarget.StandaloneWindows);
        BuildPipeline.BuildAssetBundles("Bundles-osx", BuildAssetBundleOptions.UncompressedAssetBundle, BuildTarget.StandaloneOSXUniversal);
        BuildPipeline.BuildAssetBundles("Bundles-linux", BuildAssetBundleOptions.UncompressedAssetBundle, BuildTarget.StandaloneLinuxUniversal);
    }
}
