shader_type canvas_item;

uniform vec4 target_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform bool invert_luminance = false;

uniform bool gradient_enabled = false;
uniform sampler2D gradient_texture;

void fragment() {
    float luminance = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
    if (invert_luminance) {
        luminance = 1.0 - luminance;
    }
    // Apply gradient instead of solid colour
    if (gradient_enabled) {
        vec4 gradient_color = texture(gradient_texture, SCREEN_UV);
        COLOR.rgb = mix(COLOR.rgb, gradient_color.rgb, luminance);
    } else {
        COLOR.rgb = target_color.rgb * luminance;
    }
}