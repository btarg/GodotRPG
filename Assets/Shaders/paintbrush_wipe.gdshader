// Paintbrush effect written by Vitor
shader_type canvas_item;

uniform sampler2D noise1: repeat_enable;
uniform sampler2D noise2: repeat_enable;
uniform float progress: hint_range(0.0, 1.0);

uniform bool horizontal = true;
uniform bool luminance_based_colouring = false;
// True = black is tinted, false = white is tinted
uniform bool invert_luminance = false;
// Colour to tint the texture based on luminance
uniform vec4 target_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

// Final alpha to multiply by
uniform float desired_alpha: hint_range(0, 1) = 0.6;

uniform bool gradient_enabled = false;
uniform sampler2D gradient_texture;

uniform bool flip_wipe_direction = false; // false for normal, true for flipped

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // At full progress, just show the texture to avoid artifacts and redundant calculations
    if ((progress < 1.0 && !flip_wipe_direction) || (progress > 0.0 && flip_wipe_direction)) {
        float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
        vec2 scaled_uv = (SCREEN_UV  - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0);

        vec4 noise1_tex = texture(noise1, scaled_uv * vec2(1.0, 2.0));
        vec4 noise2_tex = texture(noise2, scaled_uv * vec2(1.0, 2.0));

        float noise1_value = noise1_tex.r + noise1_tex.g + noise1_tex.b;
        float noise2_value = noise2_tex.r + noise2_tex.g + noise2_tex.b;

        vec4 progress_alpha = vec4(1, 1, 1, step(horizontal ? UV.x : UV.y,
        (noise1_value + noise2_value) * progress * 0.5));

        if (flip_wipe_direction) {
            progress_alpha.a = 1.0 - progress_alpha.a;
        }

        COLOR = tex * progress_alpha;
    }
    if (luminance_based_colouring) {
        float luminance = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
        if (invert_luminance) {
            luminance = 1.0 - luminance;
        }
        // Apply gradient instead of solid colour
        if (gradient_enabled) {
            vec4 gradient_color = texture(gradient_texture, UV);
            COLOR.rgb = mix(COLOR.rgb, gradient_color.rgb, luminance);
        } else {
            COLOR.rgb = target_color.rgb * luminance;
        }
    }
    COLOR.a *= desired_alpha;
}