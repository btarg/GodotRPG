shader_type canvas_item;

// Wipe an image horizontally or vertically using a custom alpha.
// Supports wiping sprites that have multiple frames.
// Taken from https://godotshaders.com/shader/multi-frame-wipe/.

uniform float percentage: hint_range(0, 1) = 1;
uniform float hidden_alpha: hint_range(0, 1) = 0;
uniform bool flip = false;
uniform bool horizontal = false;
uniform int frames = 1;
uniform float smoothness: hint_range(0.0, 0.1) = 0.01; // Controls the smoothness of the transition
uniform float original_alpha: hint_range(0, 1) = 0.6;

void fragment() {
    float frame_uv_size = 1.0 / float(frames);
    float uv_position = horizontal ? UV.x : UV.y;

    // Reduce the uv_position in all frames to the same relative position in the
    // first frame. For example: with 2 frames, a uv_position of 0.75 is 0.25
    // away from the second frame's start of 0.5, so it will be reduced to 0.25.
    uv_position -= frame_uv_size * floor(uv_position / frame_uv_size);

    float frame_percentage = percentage / float(frames);

    // Use smoothstep for anti-aliasing
    float edge0 = flip ? 1.0 - frame_percentage - smoothness : frame_percentage - smoothness;
    float edge1 = flip ? 1.0 - frame_percentage + smoothness : frame_percentage + smoothness;
    float transition = smoothstep(edge0, edge1, uv_position);

    COLOR.a = texture(TEXTURE, UV).a * (hidden_alpha + transition) * original_alpha;
}
