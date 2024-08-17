shader_type canvas_item;
const float TWO_PI = 6.28318530718;

vec4 polygon(vec2 uv, float width, int sides)
{
    uv = uv * 2.0 - 1.0;

    float angle = atan(uv.x, uv.y);
    float radius = TWO_PI / float(sides);

    float dist = cos(floor(0.5 + angle / radius) * radius - angle) * length(uv);
    float poly = step(width, dist);

    return poly > 0.0 ? vec4(0.0) : vec4(1.0);
}

void fragment() {
    // generate a polygon with 6 sides
    vec4 color = polygon(UV, 0.5, 6);
    COLOR = color;
}