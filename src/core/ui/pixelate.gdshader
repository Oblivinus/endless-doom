shader_type canvas_item;

uniform float pixel_size = 2.0;

varying vec4 v_color;

void vertex() {
	v_color = COLOR;
}

void fragment() {
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
	vec2 uv = (floor(UV * tex_size / pixel_size) + 0.5) * pixel_size / tex_size;
	COLOR = v_color * texture(TEXTURE, uv);
}