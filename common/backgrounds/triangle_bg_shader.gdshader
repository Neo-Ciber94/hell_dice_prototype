shader_type canvas_item;

uniform float tri_size : hint_range(2.0, 200.0) = 32.0;
uniform float spacing : hint_range(0.0, 2.0) = 0.3; // fraction of size for spacing
uniform float speed : hint_range(0.0, 200.0) = 80.0;
uniform vec2 direction = vec2(1.0, 1.0);
uniform vec4 tri_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // red
uniform vec4 bg_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);  // black
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

const float SQRT3 = 1.7320508075688772;

float sdEquilateralTriangle(vec2 p, float r) {
	const float k = SQRT3;
	p.x = abs(p.x) - r;
	p.y = p.y + r / k;
	if (p.x + k * p.y > 0.0) {
		p = vec2(p.x - k * p.y, -k * p.x - p.y) / 2.0;
	}
	p.x -= clamp(p.x, -2.0 * r, 0.0);
	return -length(p) * sign(p.y);
}

void fragment() {
	vec2 res = vec2(textureSize(SCREEN_TEXTURE, 0));
	vec2 p = UV * res;

	// Move diagonally
	vec2 dir = normalize(direction);
	p += dir * TIME * speed;

	float s = tri_size;
	float h = SQRT3 * s * 0.5;

	// Add spacing to the grid
	float sx = s * (1.0 + spacing);
	float sy = h * (1.0 + spacing);

	vec2 grid = vec2(floor(p.x / sx), floor(p.y / sy));
	vec2 cell_origin = vec2(grid.x * sx, grid.y * sy);

	// Alternate triangles up/down
	bool up = mod(grid.x + grid.y, 2.0) == 0.0;

	vec2 local = p - cell_origin - vec2(s * 0.5, h * 0.5);
	if (!up) local.y = -local.y;

	float d = sdEquilateralTriangle(local, s * 0.5);
	float inside = step(d, 0.0);

	vec4 screen_col = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 color = mix(bg_color, tri_color, inside);
	COLOR = mix(screen_col, color, 1.0);
}
