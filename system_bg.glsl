/** @resolution */
uniform vec2 u_resolution;
/** @time */
uniform float u_time;

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    
    // Base dark system color
    vec3 color = vec3(0.02, 0.04, 0.08); 
    
    // Dynamic grid lines moving downwards
    float gridX = step(0.98, fract(uv.x * 30.0));
    float gridY = step(0.98, fract(uv.y * 30.0 - u_time * 0.5));
    float grid = max(gridX, gridY);
    
    // Add pulsing neon blue effect
    float pulse = (sin(u_time * 2.0) * 0.5 + 0.5) * 0.5 + 0.5;
    vec3 neonBlue = vec3(0.0, 0.6, 1.0) * pulse;
    
    // Add a vignette to darken the edges
    float vignette = length(uv - 0.5);
    color *= 1.0 - vignette * 0.8;
    
    color += grid * neonBlue * (1.0 - vignette * 1.5) * 0.3;
    
    gl_FragColor = vec4(color, 1.0);
}
