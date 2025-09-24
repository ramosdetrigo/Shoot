shader_type canvas_item;


uniform vec4 flash_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float intensity: hint_range(0.0, 1.0) = 0.0;


void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	vec4 modulated_color = texture_color * COLOR;
	vec4 final_color = mix(modulated_color, flash_color, intensity);
	final_color.a = modulated_color.a;
	COLOR = final_color;
}

