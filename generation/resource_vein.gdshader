shader_type canvas_item;

instance uniform bool mouse_hover = false;
// Highest level of the material in the resource_vein, so that 50% depletion doesn't hide a 2-leveled vein.
instance uniform int levels = 4;
// Percentage of the material that is depleted.
instance uniform float depletion = 0.0;

float snap(float what) {
	what /= float(5 - levels);
	if (what < 0.125) {
		return 0.0;
	}
	if (what < 0.375) {
		return 0.25;
	}
	if (what < 0.625) {
		return 0.5;
	}
	if (what < 0.875) {
		return 0.75;
	}
	return 1.0;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.a -= snap(depletion);
	COLOR = color;
	
	if (mouse_hover) {
		COLOR.rgb += vec3(0.25*abs(sin(TIME*4.0)));
	}
}
