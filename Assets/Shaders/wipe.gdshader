shader_type canvas_item;

// Wipe an image horizontally or vertically using a custom alpha.
// Supports wiping sprites that have multiple frames.
// Taken from https://godotshaders.com/shader/multi-frame-wipe/.

uniform float percentage: hint_range(0, 1) = 1;
uniform float hidden_alpha: hint_range(0, 1) = 0;
uniform bool flip = false;
uniform bool horizontal = false;
uniform int frames = 1;
uniform float smoothness: hint_range(0.0, 0.1) = 0.01; // Controls the smoothness of the edge
uniform float desired_alpha: hint_range(0, 1) = 0.6; // Final alpha to multiply by

// Recolour brighter sections of the image to the target colour
uniform bool luminance_based_colouring = false;
uniform vec4 target_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

uniform bool luminance_based_alpha = false;
uniform bool flip_wipe_direction = false; // false for normal, true for flipped

void fragment() {
    float frame_uv_size = 1.0 / float(frames);
    float uv_position = horizontal ? UV.x : UV.y;
    uv_position -= frame_uv_size * floor(uv_position / frame_uv_size);
    float frame_percentage = percentage / float(frames);

    if (flip_wipe_direction) {
        uv_position = 1.0 - uv_position;
    }

    // Smoothstep for fading the edge of the wipe
    float edge0 = flip ? 1.0 - frame_percentage - smoothness : frame_percentage - smoothness;
    float edge1 = flip ? 1.0 - frame_percentage + smoothness : frame_percentage + smoothness;
    float transition = smoothstep(edge0, edge1, uv_position);

    vec4 tex_color = texture(TEXTURE, UV);

    float luminance = 1.0;
    if (luminance_based_alpha || luminance_based_colouring) {
        luminance = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    }

    // darker pixels are more transparent if luminance_based_alpha is true
    tex_color.a *= luminance_based_alpha ? luminance : 1.0;
    tex_color.a *= (hidden_alpha + transition) * desired_alpha;

    // Apply target colour to lighter sections if needed
    if (luminance_based_colouring) {
        tex_color.rgb = target_color.rgb * luminance;
        COLOR = tex_color;
    } else {
        COLOR.a = tex_color.a;
    }
}