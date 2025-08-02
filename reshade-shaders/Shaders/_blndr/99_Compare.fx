#include "ReShade.fxh"

texture OriginalTex <source="OriginalTex";>;
sampler OriginalTexSampler { Texture = OriginalTex; };

texture EffectedTex : COLOR;
sampler EffectedSampler { Texture = EffectedTex; };

uniform int DisplayMode <
    ui_type = "combo";
    ui_items = "Split Game View (L/R)\0Compare Left Half\0Compare Center Half\0";
> = 2;

float4 PS_Compare(float4 svpos : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
    float split_x_output = 0.5;
    float4 output_color;
    float2 sample_uv = texcoord;
    bool is_left_panel = texcoord.x < split_x_output;

    if (DisplayMode == 0)
    {
        if (is_left_panel)
            output_color = tex2D(OriginalTexSampler, texcoord);
        else
            output_color = tex2D(EffectedSampler, texcoord);
    }
    else if (DisplayMode == 1)
    {
        if (is_left_panel)
        {
            sample_uv.x = texcoord.x;
            output_color = tex2D(OriginalTexSampler, sample_uv);
        }
        else
        {
            sample_uv.x = texcoord.x - 0.5;
            output_color = tex2D(EffectedSampler, sample_uv);
        }
    }
    else
    {
        if (is_left_panel)
        {
            sample_uv.x = texcoord.x + 0.25;
            output_color = tex2D(OriginalTexSampler, sample_uv);
        }
        else
        {
            sample_uv.x = texcoord.x - 0.25;
            output_color = tex2D(EffectedSampler, sample_uv);
        }
    }

    return output_color;
}

technique Compare
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_Compare;
    }
}