#include "ReShade.fxh"

texture OriginalTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler OriginalTexSampler { Texture = OriginalTex; };

texture EffectedTex : COLOR;
sampler EffectedSampler { Texture = EffectedTex; };

uniform float ViewShift <
    ui_category = "Display & Comparison";
    ui_type = "slider";
    ui_label = "View Shift";
    ui_tooltip = "Shifts the duplicated view.\n0.5 is the center, 0 is left, 1 is right.";
    ui_min = 0.0;
    ui_max = 1.0;
> = 0.5;

uniform bool WorldOnRight <
    ui_category = "Display & Comparison";
    ui_label = "World on Right";
    ui_tooltip = "When checked, the world pass is on the right side of the screen.";
> = false;

uniform bool InvertDepth <
    ui_category = "Display & Comparison";
    ui_label = "Invert Depth";
    ui_tooltip = "Inverts the colors of the depth pass.";
> = false;

uniform bool EnableAspectRatioCorrection <
    ui_category = "Aspect Ratio Correction";
    ui_label = "Enable Aspect Ratio Correction";
> = false;

uniform int AspectRatioPreset <
    ui_category = "Aspect Ratio Correction";
    ui_type = "combo";
    ui_label = "Original Aspect Ratio";
    ui_items = "16:9 (Standard)" "\0" "16:10" "\0" "21:9 (Ultrawide)" "\0" "4:3";
    ui_tooltip = "Select the intended aspect ratio of the game content to correct for stretching.";
> = 0;

float4 PS_Compare(float4 svpos : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target
{
    float split_x_output = 0.5;
    bool is_left_panel = texcoord.x < split_x_output;

    // Calculate the starting position of the 50% view window based on the slider
    float sample_start_x = ViewShift * 0.5;

    float2 sample_uv = texcoord;

    // Map the left and right halves of the screen to the same view window
    if (is_left_panel)
    {
        sample_uv.x = texcoord.x + sample_start_x;
    }
    else // right panel
    {
        sample_uv.x = (texcoord.x - 0.5) + sample_start_x;
    }

    // --- ASPECT RATIO CORRECTION ---
    float2 final_uv = sample_uv;
    bool is_outside = false;

    if (EnableAspectRatioCorrection)
    {
        float targetAR = 16.0 / 9.0; // Default for preset 0
        if (AspectRatioPreset == 1) { targetAR = 16.0 / 10.0; }
        else if (AspectRatioPreset == 2) { targetAR = 21.0 / 9.0; }
        else if (AspectRatioPreset == 3) { targetAR = 4.0 / 3.0; }

        float currentAR = (float)BUFFER_WIDTH / (float)BUFFER_HEIGHT;
        float correction = currentAR / targetAR;

        if (correction > 1.0) // Pillarbox (squeeze horizontally)
        {
            final_uv.x = 0.5 + (sample_uv.x - 0.5) * correction;
        }
        else // Letterbox (squeeze vertically)
        {
            final_uv.y = 0.5 + (sample_uv.y - 0.5) / correction;
        }

        if (final_uv.x < 0.0 || final_uv.x > 1.0 || final_uv.y < 0.0 || final_uv.y > 1.0)
        {
            is_outside = true;
        }
    }
    // --- END CORRECTION ---

    float4 output_color;
    bool is_effected_side;

    if (is_left_panel) { is_effected_side = WorldOnRight; }
    else { is_effected_side = !WorldOnRight; }

    if (is_outside)
    {
        output_color = float4(0.0, 0.0, 0.0, 1.0); // Black bars
    }
    else
    {
        if (is_left_panel)
        {
            if (WorldOnRight) { output_color = tex2D(EffectedSampler, final_uv); }
            else { output_color = tex2D(OriginalTexSampler, final_uv); }
        }
        else // right panel
        {
            if (WorldOnRight) { output_color = tex2D(OriginalTexSampler, final_uv); }
            else { output_color = tex2D(EffectedSampler, final_uv); }
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