#include "ReShade.fxh"

texture OriginalTex
{
    Width = BUFFER_WIDTH;
    Height = BUFFER_HEIGHT;
    Format = RGBA8;
};

texture PassInputColorTex : COLOR;
sampler PassInputColorSampler { Texture = PassInputColorTex; };

float4 PS_Capture(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target0
{
    return tex2D(PassInputColorSampler, texcoord);
}

technique Capture
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_Capture;
        RenderTarget0 = OriginalTex;
    }
}