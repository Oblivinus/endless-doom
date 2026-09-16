shader_type canvas_item;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = tex_color * COLOR;
	if (COLOR.a < 0.5) {
		discard;
	} else {
		COLOR.a = 1.0;
	}
}