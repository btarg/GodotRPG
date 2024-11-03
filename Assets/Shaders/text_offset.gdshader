shader_type canvas_item;
uniform float offset_variance = 5.0;

void vertex() {
    float random_offset = (fract(cos(VERTEX.y) * UV.x) - 0.5) * offset_variance;
    VERTEX.y -= random_offset;
}
