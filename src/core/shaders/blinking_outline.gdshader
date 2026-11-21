shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_opaque;

uniform sampler2D texture_albedo : source_color, filter_nearest;

uniform float outline_opacity : hint_range(0.0, 1.0) = 0.35;
uniform int hframes = 1;
uniform int vframes = 1;
uniform int billboard_mode = 1;
uniform bool outline_enabled = true;
uniform int outline_width : hint_range(1, 4) = 1;
uniform float blink_interval = 0.2;
uniform vec4 color_a : source_color = vec4(1.0, 0.9, 0.0, 1.0);
uniform vec4 color_b : source_color = vec4(0.6, 0.0, 1.0, 1.0);

void vertex() {
	if (billboard_mode == 1) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1],
			INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	} else if (billboard_mode == 2) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			INV_VIEW_MATRIX[0], MODEL_MATRIX[1],
			INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	}
	if (billboard_mode != 0) {
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
			vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
			vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
			vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
	}
}

float sample_alpha(vec2 uv, vec2 cell, vec2 grid) {
	if (any(notEqual(floor(uv * grid), cell))) {
		return 0.0;
	}
	return texture(texture_albedo, uv).a;
}

void fragment() {
	vec4 tex = texture(texture_albedo, UV);
	vec3 base = tex.rgb * COLOR.rgb;
	float alpha = tex.a * COLOR.a;

	if (outline_enabled && tex.a > 0.1) {
		vec2 grid = vec2(float(hframes), float(vframes));
		vec2 cell = floor(clamp(UV * grid, vec2(0.0001), grid - vec2(0.0001)));
		vec2 px = 1.0 / vec2(textureSize(texture_albedo, 0));
		
		float lowest = 1.0;
		for (int x = -4; x <= 4; x++) {
			for (int y = -4; y <= 4; y++) {
				if (abs(x) > outline_width || abs(y) > outline_width) continue;
				if (x == 0 && y == 0) continue;
				lowest = min(lowest, sample_alpha(UV + vec2(float(x), float(y)) * px, cell, grid));
			}
		}
		
		
		if (lowest < 0.1) {
			float phase = step(0.5, fract(TIME / (blink_interval * 2.0)));
			vec3 blink_color = mix(color_a.rgb, color_b.rgb, phase);
			
			vec3 add = base + blink_color;
			base = mix(base, add, outline_opacity);
		}
	}
	
	ALBEDO = base;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	ALPHA = alpha;
}