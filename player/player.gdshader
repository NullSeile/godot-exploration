shader_type spatial;
uniform sampler2D current_frame : source_color, filter_nearest;
uniform vec3[6] colors : source_color;
render_mode depth_draw_opaque, cull_disabled;
// render_mode unshaded;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex = texture(current_frame, UV);
	if (tex.rgb == vec3(0,0,0)) {
		ALBEDO = colors[0];
	} else if (tex.rgb == vec3(0,0,1)) {
		ALBEDO = colors[1];
	} else if (tex.rgb == vec3(0,1,0)) {
		ALBEDO = colors[2];
	} else if (tex.rgb == vec3(0,1,1)) {
		ALBEDO = colors[3];
	} else if (tex.rgb == vec3(1,0,0)) {
		ALBEDO = colors[4];
	} else if (tex.rgb == vec3(1,0,1)) {
		ALBEDO = colors[5];
	} else {
		ALBEDO = tex.rgb;
	}
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
