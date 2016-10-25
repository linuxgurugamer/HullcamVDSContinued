// copied from Firespitter
Shader "Custom/NightVision" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
    }
    SubShader {
        Pass {
            Blend SrcColor DstColor
            SetTexture [_MainTex] {
                constantColor (0.5,0.7,0.5,0.5)
                combine constant + texture
            }
        }
        Pass {
            Blend SrcColor DstColor
            SetTexture [_MainTex] {
                combine texture * previous
            }
        }
    }
} 
