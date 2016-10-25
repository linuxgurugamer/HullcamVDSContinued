using UnityEditor;

public class CreateAssetBundles
{
    [MenuItem("My Mod/Build Bundles")]
    static void BuildAllAssetBundles()
    {
        BuildPipeline.BuildAssetBundles("Bundles", BuildAssetBundleOptions.UncompressedAssetBundle, BuildTarget.StandaloneWindows);
    }
}