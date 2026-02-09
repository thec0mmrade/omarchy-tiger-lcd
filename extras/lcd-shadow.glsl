// LCD drop shadow - multi-pixel diagonal offset
// Mimics the offset shadow of Tiger Electronics LCD segments
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 texel = 1.0 / iResolution.xy;

    // Sample the current pixel
    vec4 current = texture(iChannel0, uv);
    float cur_lum = dot(current.rgb, vec3(0.299, 0.587, 0.114));

    // Accumulate shadow from multiple offsets (up-left sources cast shadow down-right)
    float shadow = 0.0;
    for (float i = 1.0; i <= 3.0; i += 1.0) {
        vec4 src = texture(iChannel0, uv - texel * i);
        float src_lum = dot(src.rgb, vec3(0.299, 0.587, 0.114));

        // Shadow where source is dark (text) and current is light (background)
        float mask = smoothstep(0.5, 0.3, src_lum) * smoothstep(0.4, 0.6, cur_lum);

        // Closer offsets contribute more, farther offsets fade out
        float weight = 1.0 - (i - 1.0) / 3.0;
        shadow = max(shadow, mask * weight);
    }

    vec3 shadow_color = vec3(0.165, 0.169, 0.149); // #2A2B26
    vec3 result = mix(current.rgb, shadow_color, shadow * 0.6);

    fragColor = vec4(result, current.a);
}
