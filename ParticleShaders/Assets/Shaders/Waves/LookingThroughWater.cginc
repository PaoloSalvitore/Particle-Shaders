#if !defined(LOOKING_THROUGH_WATER_INCLUDED)
#define LOOKING_THROUGH_WATER_INCLUDED


sampler2D _CameraDepthTexture;
sampler2D _WaterBackground;
float4 _CameraDepthTexture_TexelSize;
float3 _WaterFogColor;
float _WaterFogDensity;
float _RefractionStrength;

// _RefractionStrength("Refraction Strength", Range (0,1)) = 0.25


float2 AlignWithGrabTexel(float2 uv)
{
    #if UNITY_UV_STARTS_AT_TOP
    if (_CameraDepthTexture_TexelSize.y < 0)
    {
        uv.y = 1 - uv.y;
    }

    #endif
    return (floor(uv * _CameraDepthTexture_TexelSize.zw) + 0.5) * abs(_CameraDepthTexture_TexelSize.xy);
}

float3 ColorBelowWater(float4 screenPos, float3 tangentSpaceNormal)
{
    //float 4 is xyzw
    float2 uvOffset = tangentSpaceNormal.xy * _RefractionStrength;
    uvOffset.y *= _CameraDepthTexture_TexelSize.z * abs(_CameraDepthTexture_TexelSize.y);
    float2 screenUV = AlignWithGrabTexel(screenPos.xy + uvOffset) / screenPos.w; //final depth texture coordinates
    float backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenUV));
    //UNITY_Z_0_FAR_FROMCLIPSPACE convert it to linear depth
    //screenPos.z interpolated clipspace depth
    //simply, its the depth of the surface of the water
    float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(screenPos.z);
    //we have the depth from the surface of the water to the background
    float depthDifference = backgroundDepth - surfaceDepth;

    uvOffset *= saturate(depthDifference);
    screenUV = AlignWithGrabTexel(screenPos.xy + uvOffset )/ screenPos.w;
    backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenUV));
    depthDifference = backgroundDepth - surfaceDepth;

    float3 backgroundColor = tex2D(_WaterBackground, screenUV).rgb;
    float fogFactor = exp2(-_WaterFogDensity * depthDifference);

    return lerp(_WaterFogColor, backgroundColor, fogFactor);
}


#endif
