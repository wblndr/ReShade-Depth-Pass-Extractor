#include "ReShade.fxh"

texture OriginalTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler OriginalTexSampler { Texture = OriginalTex; };

texture EffectedTex : COLOR;
sampler EffectedSampler { Texture = EffectedTex; };

uniform int DisplayMode <
    ui_type = "combo";
    ui_items = "Split Game View (L/R)\0Compare Left Half\0Compare Center Half\0";
> = 2;

uniform bool WorldOnRight <
    ui_label = "World on Right";
    ui_tooltip = "When checked, the world pass is on the right side of the screen.";
> = false;

uniform bool InvertDepth = false;

float4 PS_Compare(float4 svpos : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
    float split_x_output = 0.5;
    bool is_left_panel = texcoord.x < split_x_output;

    float4 output_color;
    bool is_effected_side;

    if (is_left_panel)
    {
        float2 sample_uv = texcoord;
        if (DisplayMode == 2)
            sample_uv.x += 0.25;

        if (WorldOnRight)
        {
            output_color = tex2D(EffectedSampler, sample_uv);
            is_effected_side = true;
        }
        else
        {
            output_color = tex2D(OriginalTexSampler, sample_uv);
            is_effected_side = false;
        }
    }
    else // right panel
    {
        float2 sample_uv = texcoord;
        if (DisplayMode == 1)
            sample_uv.x -= 0.5;
        else if (DisplayMode == 2)
            sample_uv.x -= 0.25;

        if (WorldOnRight)
        {
            output_color = tex2D(OriginalTexSampler, sample_uv);
            is_effected_side = false;
        }
        else
        {
            output_color = tex2D(EffectedSampler, sample_uv);
            is_effected_side = true;
        }
    }

    if (InvertDepth && is_effected_side)
    {
        output_color.rgb = 1.0 - output_color.rgb;
    }

    return output_color;
}

technique SideBySideOutput <
    ui_label = "END_SideBySideOutput";
    ui_tooltip = "This shader must be last in the list. It displays the original frame (from 01_Capture) side-by-side with the final processed frame, allowing for easy comparison.";
>
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_Compare;
    }
}
