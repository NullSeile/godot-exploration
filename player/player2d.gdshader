shader_type canvas_item;
uniform sampler2D current_atlas : source_color, filter_nearest;
uniform vec3[6] colors : source_color;
//render_mode unshaded;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex = texture(current_atlas, UV);
	if (tex.rgb == vec3(0,0,0)) {
		COLOR.rgb = colors[0];
	} else if (tex.rgb == vec3(0,0,1)) {
		COLOR.rgb = colors[1];
	} else if (tex.rgb == vec3(0,1,0)) {
		COLOR.rgb = colors[2];
	} else if (tex.rgb == vec3(0,1,1)) {
		COLOR.rgb = colors[3];
	} else if (tex.rgb == vec3(1,0,0)) {
		COLOR.rgb = colors[4];
	} else if (tex.rgb == vec3(1,0,1)) {
		COLOR.rgb = colors[5];
	} else {
		COLOR.rgb = tex.rgb;
	}
	COLOR.a = tex.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
