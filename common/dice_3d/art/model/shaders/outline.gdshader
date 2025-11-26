shader_type spatial;
render_mode cull_front; // important so outline isn't invisible

uniform float outline_size : hint_range(0.0, 0.2) = 0.03;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void vertex() {
    VERTEX += NORMAL * outline_size;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;
}
