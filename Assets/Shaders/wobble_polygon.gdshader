shader_type canvas_item;

// The higher, the smoother it becomes.
uniform float snapping = 2.0;
// The higher, the faster it becomes.
uniform float speed = 12.0;
// Couldn't find a better name for this one lmao.
uniform float value = 4.0;
uniform float offset = 0.0;

void vertex() {
    VERTEX.x += cos(VERTEX.y);
    VERTEX += vec2(sin((TIME + offset) * speed + VERTEX.y), cos(TIME + VERTEX.y) + sin((TIME + offset) * speed + VERTEX.x)) * value;
}