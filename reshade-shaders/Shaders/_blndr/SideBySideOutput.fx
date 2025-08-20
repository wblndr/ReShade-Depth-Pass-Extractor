#include "ReShade.fxh"

texture OriginalTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler OriginalTexSampler { Texture = OriginalTex; };

texture EffectedTex : COLOR;
sampler EffectedSampler { Texture = EffectedTex; };

uniform float ViewShift <
    ui_type = "slider";
    ui_label = "View Shift";
    ui_tooltip = "Shifts the duplicated view. 0.5 is the center, 0 is left, 1 is right.";
    ui_min = 0.0;
    ui_max = 1.0;
> = 0.5;

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

    // Calculate the starting position of the 50% view window based on the slider
    float sample_start_x = ViewShift * 0.5;

    float2 sample_uv = texcoord;

    // Map the left and right halves of the screen to the same view window
    if (is_left_panel)
    {
        // Maps [0.0, 0.5] screen coords to [sample_start_x, sample_start_x + 0.5] texture coords
        sample_uv.x = texcoord.x + sample_start_x;
    }
    else // right panel
    {
        // Maps [0.5, 1.0] screen coords to [sample_start_x, sample_start_x + 0.5] texture coords
        sample_uv.x = (texcoord.x - 0.5) + sample_start_x;
    }


    if (is_left_panel)
    {
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
