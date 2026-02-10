// LCD drop shadow + ghosting
// Mimics the offset shadow and slow pixel response of Tiger Electronics LCD segments
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 texel = 1.0 / iResolution.xy;

    // Sample the current pixel
    vec4 current = texture(iChannel0, uv);
    float cur_lum = dot(current.rgb, vec3(0.299, 0.587, 0.114));

    // --- Drop shadow (diagonal offset) ---
    float shadow = 0.0;
    for (float i = 1.0; i <= 3.0; i += 1.0) {
        vec4 src = texture(iChannel0, uv - texel * i);
        float src_lum = dot(src.rgb, vec3(0.299, 0.587, 0.114));

        float mask = smoothstep(0.5, 0.3, src_lum) * smoothstep(0.4, 0.6, cur_lum);
        float weight = 1.0 - (i - 1.0) / 3.0;
        shadow = max(shadow, mask * weight);
    }

    // --- LCD ghosting (omnidirectional bleed from dark pixels into light) ---
    float ghost = 0.0;
    const float GHOST_RADIUS = 2.0;
    for (float dx = -GHOST_RADIUS; dx <= GHOST_RADIUS; dx += 1.0) {
        for (float dy = -GHOST_RADIUS; dy <= GHOST_RADIUS; dy += 1.0) {
            if (dx == 0.0 && dy == 0.0) continue;

            vec4 neighbor = texture(iChannel0, uv + texel * vec2(dx, dy));
            float n_lum = dot(neighbor.rgb, vec3(0.299, 0.587, 0.114));

            // Ghost where neighbor is dark (text) and current is light (background)
            float mask = smoothstep(0.5, 0.3, n_lum) * smoothstep(0.4, 0.6, cur_lum);

            // Fade with distance
            float dist = length(vec2(dx, dy)) / GHOST_RADIUS;
            float falloff = 1.0 - dist;
            ghost = max(ghost, mask * falloff);
        }
    }

    vec3 shadow_color = vec3(0.165, 0.169, 0.149); // #2A2B26
    vec3 result = current.rgb;
    result = mix(result, shadow_color, ghost * 0.35);  // LCD ghosting bleed
    result = mix(result, shadow_color, shadow * 0.85);  // strong drop shadow

    fragColor = vec4(result, current.a);
}
