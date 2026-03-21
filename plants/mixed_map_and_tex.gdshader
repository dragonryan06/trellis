/*
https://forum.godotengine.org/t/multiple-uv-distinct-maps-for-the-same-mesh/70897

Basically, the idea here is that if the mesh has multiple UV maps and multiple
textures, you can use this shader to switch the mappings smoothly between them.

Maybe one day in the future multiple UV maps will be more directly supported
by the engine, oh well!
*/
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

// Scenes are specified by index, so like 0 is the first UV map and the first texture, etc.
instance uniform int scene_x : hint_range(0, 9) = 0;
instance uniform int scene_y : hint_range(0, 9) = 1;

// Fades the texture and interpolates the UV map between scenes X & Y
instance uniform float crossfader : hint_range(0.0f, 1.0f) = 0.0f;

// The textures to use, in scene order.
group_uniforms Textures;
uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;
uniform sampler2D texture4;
uniform sampler2D texture5;
uniform sampler2D texture6;
uniform sampler2D texture7;
uniform sampler2D texture8;
uniform sampler2D texture9;

void vertex() {
	vec2 uv_x;
	switch (scene_x) {
		case 0:
			uv_x = UV;
			break;
		case 1:
			uv_x = UV2;
			break;
		case 2:
			uv_x = CUSTOM0.xy;
			break;
		case 3:
			uv_x = CUSTOM0.wz;
			break;
		case 4:
			uv_x = CUSTOM1.xy;
			break;
		case 5:
			uv_x = CUSTOM1.wz;
			break;
		case 6:
			uv_x = CUSTOM2.xy;
			break;
		case 7:
			uv_x = CUSTOM2.wz;
			break;
		case 8:
			uv_x = CUSTOM3.xy;
			break;
		case 9:
			uv_x = CUSTOM3.wz;
			break;
	}
	switch (scene_y) {
		case 0:
			UV = mix(uv_x, UV, crossfader);
			break;
		case 1:
			UV = mix(uv_x, UV2, crossfader);
			break;
		case 2:
			UV = mix(uv_x, CUSTOM0.xy, crossfader);
			break;
		case 3:
			UV = mix(uv_x, CUSTOM0.wz, crossfader);
			break;
		case 4:
			UV = mix(uv_x, CUSTOM1.xy, crossfader);
			break;
		case 5:
			UV = mix(uv_x, CUSTOM1.wz, crossfader);
			break;
		case 6:
			UV = mix(uv_x, CUSTOM2.xy, crossfader);
			break;
		case 7:
			UV = mix(uv_x, CUSTOM2.wz, crossfader);
			break;
		case 8:
			UV = mix(uv_x, CUSTOM3.xy, crossfader);
			break;
		case 9:
			UV = mix(uv_x, CUSTOM3.wz, crossfader);
			break;
	}
}

void fragment() {
	vec3 color_x;
	switch (scene_x) {
		case 0:
			color_x = texture(texture0, UV).rgb;
			break;
		case 1:
			color_x = texture(texture1, UV).rgb;
			break;
		case 2:
			color_x = texture(texture2, UV).rgb;
			break;
		case 3:
			color_x = texture(texture3, UV).rgb;
			break;
		case 4:
			color_x = texture(texture4, UV).rgb;
			break;
		case 5:
			color_x = texture(texture5, UV).rgb;
			break;
		case 6:
			color_x = texture(texture6, UV).rgb;
			break;
		case 7:
			color_x = texture(texture7, UV).rgb;
			break;
		case 8:
			color_x = texture(texture8, UV).rgb;
			break;
		case 9:
			color_x = texture(texture9, UV).rgb;
			break;
	}
	switch (scene_y) {
		case 0:
			ALBEDO = mix(color_x, texture(texture0, UV).rgb, crossfader);
			break;
		case 1:
			ALBEDO = mix(color_x, texture(texture1, UV).rgb, crossfader);
			break;
		case 2:
			ALBEDO = mix(color_x, texture(texture2, UV).rgb, crossfader);
			break;
		case 3:
			ALBEDO = mix(color_x, texture(texture3, UV).rgb, crossfader);
			break;
		case 4:
			ALBEDO = mix(color_x, texture(texture4, UV).rgb, crossfader);
			break;
		case 5:
			ALBEDO = mix(color_x, texture(texture5, UV).rgb, crossfader);
			break;
		case 6:
			ALBEDO = mix(color_x, texture(texture6, UV).rgb, crossfader);
			break;
		case 7:
			ALBEDO = mix(color_x, texture(texture7, UV).rgb, crossfader);
			break;
		case 8:
			ALBEDO = mix(color_x, texture(texture8, UV).rgb, crossfader);
			break;
		case 9:
			ALBEDO = mix(color_x, texture(texture9, UV).rgb, crossfader);
			break;
	}
	
	// For some reason the color is looking way too white? No clue!
	ALBEDO -= 0.333f;
}
