shader_type canvas_item;

uniform vec2 dir = vec2(1, 1);
uniform float speed: hint_range(0.0, 10, 0.001) = 0.5;

void vertex() {
	UV += dir * TIME * speed;
}

