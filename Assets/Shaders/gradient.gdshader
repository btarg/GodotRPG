shader_type canvas_item;
uniform sampler2D gradient_texture;


void fragment() {
    vec2 my_uv = SCREEN_UV;
    float luminance = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
    vec4 gradient_color = texture(gradient_texture, my_uv);
    COLOR.rgb = gradient_color.rgb;
}