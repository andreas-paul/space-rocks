shader_type canvas_item;

// By default colors the sprite's shape, because the current art is black. Turn on
// keep_art_colors for art with its own colors. Values above 1 glow on Forward+.
uniform bool keep_art_colors = false;
uniform vec4 glow_color : source_color = vec4(0.3, 1.0, 0.4, 1.0);
uniform float intensity = 2.0;

void fragment() {
	vec3 base_color = keep_art_colors ? COLOR.rgb : glow_color.rgb;
	COLOR.rgb = base_color * intensity;
}
