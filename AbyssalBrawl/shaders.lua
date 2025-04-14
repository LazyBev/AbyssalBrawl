-- shaders.lua

shaders = {}

shaders = {
    swirl = love.graphics.newShader[[
        #define PI 3.14159265359
        #define BLUE1 1.0
        #define BLUE2 0.7
        #define BLUE3 0.4
        #define SINE1 1.0
        #define SINE2 1.2
        #define SINE3 0.5
        #define MOD1 0.1
        #define MOD2 0.3
        #define MOD3 0.2
        extern number iTime;
        extern number dayOfWeek;
        vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
            vec2 screenSize = love_ScreenSize.xy;
            vec2 uv = (screen_coords - 0.5 * screenSize) / length(screenSize);
            float uv_len = length(uv);
            
            float day = mod(dayOfWeek, 7.0);
            
            if(day < 1.0) {
                float speed = mod(iTime * 0.4, PI * 2.0);
                // Negate the speed term to reverse rotation direction
                float new_pixel_angle = atan(uv.y, uv.x) - speed - 20.0 * (0.25 * uv_len + 0.75);
                vec2 mid = (screenSize / length(screenSize)) / 2.0;
                uv = (vec2(uv_len * cos(new_pixel_angle) + mid.x, uv_len * sin(new_pixel_angle) + mid.y) - mid);
            }
            else if(day < 2.0) {
                float angle = iTime + uv_len * 5.0;
                // Swap and negate terms in rotation matrix to reverse direction
                uv = vec2(uv.x * cos(-angle) + uv.y * sin(-angle),
                        -uv.x * sin(-angle) + uv.y * cos(-angle));
                uv += 0.1 * vec2(sin(uv.y * 15.0 + iTime),
                                cos(uv.x * 15.0 + iTime));
            }
            else if(day < 3.0) {
                uv += 0.05 * vec2(sin(uv.y * 20.0 + iTime),
                                cos(uv.x * 20.0 + iTime));
            }
            else if(day < 4.0) {
                vec2 originalUV = uv;
                for (int i = 0; i < 7; i++) {
                    uv += 0.1 * vec2(sin(uv.y * 10.0 + iTime * 0.5 + float(i)),
                                    cos(uv.x * 10.0 + iTime * 0.5 + float(i)));
                    uv *= 1.1;
                }
                uv = mix(uv, originalUV, 0.5);
            }
            else if(day < 5.0) {
                float jitter = 0.2 * sin(uv_len * 20.0 - iTime);
                float a = atan(uv.y, uv.x);
                // Negate jitter direction
                uv -= jitter * vec2(cos(a), sin(a)); // Changed from += to -=
            }
            else if(day < 6.0) {
                float n = sin(dot(uv, vec2(12.9898, 78.233)) + iTime * 3.0);
                uv += 0.03 * vec2(n, cos(dot(uv, vec2(12.9898, 78.233)) + iTime * 3.0));
            }
            else {
                // Negate time term to reverse fractal spin
                uv = fract(uv * 2.0 * (sin(-iTime * 0.7 + 0.2) + 2.0) + (-iTime * 0.25)) - 0.5;
                uv *= 1.5;
            }
            
            vec2 uv_loop = uv * 30.0;
            float speed = iTime * 7.0;
            vec2 uv2 = vec2(uv_loop.x + uv_loop.y);
            for (int i = 0; i < 5; i++) {
                uv2 += sin(max(uv_loop.x, uv_loop.y)) + uv_loop;
                uv_loop += 0.5 * vec2(
                    cos(5.1123314 + 0.353 * uv2.y - speed * 0.131121), // Negate speed term
                    sin(uv2.x + 0.113 * speed) // Negate speed term
                );
                uv_loop -= cos(uv_loop.x + uv_loop.y) - sin(uv_loop.x * 0.711 - uv_loop.y);
            }
            float paint_res = min(2.0, max(0.0, length(uv_loop) * 0.077));
            float c1p = max(0.0, 1.0 - 2.2 * abs(1.0 - paint_res));
            float c2p = max(0.0, 1.0 - 2.2 * abs(paint_res));
            float c3p = 1.0 - min(1.0, c1p + c2p);
            float light = 0.2 * max(c1p * 5.0 - 4.0, 0.0) + 0.4 * max(c2p * 5.0 - 4.0, 0.0);
            
            vec4 blue1 = vec4(0.0, 0.0, BLUE1 + MOD1 * sin(iTime + SINE1), 1.0);
            vec4 blue2 = vec4(0.0, 0.0, BLUE2 + MOD2 * sin(iTime + SINE2), 1.0);
            vec4 blue3 = vec4(0.0, 0.0, BLUE3 + MOD3 * sin(iTime + SINE3), 1.0);
            
            return (0.3 / 3.5) * blue1
                + (1.0 - 0.3 / 3.5) * (blue1 * c1p + blue2 * c2p + vec4(0.0, 0.0, c3p * blue3.b, c3p * blue1.a))
                + vec4(0.0, 0.0, light, 0.0);
        }
    ]],

    titleShader = love.graphics.newShader[[
        float random(in vec2 st) {
            return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
        }

        float noise(in vec2 st) {
            vec2 i = floor(st);
            vec2 f = fract(st);

            float a = random(i);
            float b = random(i + vec2(1.0, 0.0));
            float c = random(i + vec2(0.0, 1.0));
            float d = random(i + vec2(1.0, 1.0));

            vec2 u = f * f * (3.0 - 2.0 * f);

            return mix(a, b, u.x) +
                (c - a) * u.y * (1.0 - u.x) +
                (d - b) * u.x * u.y;
        }

        extern float love_Time;

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            float t = love_Time / 10.;
            
            vec2 p = 100. * screen_coords / love_ScreenSize.xy;
            float y = p.y / 100.;
            p.y += sin(2. * t);
            p.x += cos(5. * t);
            p *= mat2(sin(t / 2.), -cos(t / 2.), cos(t / 2.), sin(t / 2.)) / 8.;

            vec4 fragColor = vec4(0.0);
            for (float i = 0.; i < 8.; i++) {
                fragColor = cos(p.xxxx * .3) * .5 + .5;
                float n = noise(p / 5.);
                fragColor *= n;
                p.x += sin(p.y + love_Time * .3 + i);
                p *= mat2(6, -8, 8, 6) / 8.;
            }

            fragColor *= 1. - smoothstep(0., .91, y);
            fragColor *= vec4(0.2, 0.23, 0.54, 1.0);
            return fragColor * color;
        }
    ]],

    background = love.graphics.newShader[[
        #define SPIN_ROTATION -2.0
        #define SPIN_SPEED 7.0
        #define OFFSET vec2(0.0)
        #define COLOUR_1 vec4(0.2, 0.5, 0.9, 1.0)    // Medium vibrant blue
        #define COLOUR_2 vec4(0.3, 0.7, 1.0, 1.0)    // Lighter cyan-blue
        #define COLOUR_3 vec4(0.1, 0.3, 0.7, 1.0)    // Darker rich blue
        #define CONTRAST 3.5
        #define LIGTHING 0.4
        #define SPIN_AMOUNT 0.25
        #define PIXEL_FILTER 745.0
        #define SPIN_EASE 1.0
        #define PI 3.14159265359
        #define IS_ROTATE false
        extern number iTime;
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec2 screenSize = love_ScreenSize.xy;
            float pixel_size = length(screenSize.xy) / PIXEL_FILTER;
            vec2 uv = (floor(screen_coords.xy * (1.0 / pixel_size)) * pixel_size - 0.5 * screenSize.xy) / length(screenSize.xy) - OFFSET;
            float uv_len = length(uv);
            
            float speed = (SPIN_ROTATION * SPIN_EASE * 0.2);
            if (IS_ROTATE) {
                speed = iTime * speed;
            }
            speed += 302.2;
            float new_pixel_angle = atan(uv.y, uv.x) + speed - SPIN_EASE * 20.0 * (1.0 * SPIN_AMOUNT * uv_len + (1.0 - 1.0 * SPIN_AMOUNT));
            vec2 mid = (screenSize.xy / length(screenSize.xy)) / 2.0;
            uv = (vec2((uv_len * cos(new_pixel_angle) + mid.x), (uv_len * sin(new_pixel_angle) + mid.y)) - mid);
            
            uv *= 30.0;
            speed = iTime * (SPIN_SPEED);
            vec2 uv2 = vec2(uv.x + uv.y);
            
            for (int i = 0; i < 5; i++) {
                uv2 += sin(max(uv.x, uv.y)) + uv;
                uv += 0.5 * vec2(cos(5.1123314 + 0.353 * uv2.y + speed * 0.131121), sin(uv2.x - 0.113 * speed));
                uv -= 1.0 * cos(uv.x + uv.y) - 1.0 * sin(uv.x * 0.711 - uv.y);
            }
            
            float contrast_mod = (0.25 * CONTRAST + 0.5 * SPIN_AMOUNT + 1.2);
            float paint_res = min(2.0, max(0.0, length(uv) * (0.035) * contrast_mod));
            float c1p = max(0.0, 1.0 - contrast_mod * abs(1.0 - paint_res));
            float c2p = max(0.0, 1.0 - contrast_mod * abs(paint_res));
            float c3p = 1.0 - min(1.0, c1p + c2p);
            float light = (LIGTHING - 0.2) * max(c1p * 5.0 - 4.0, 0.0) + LIGTHING * max(c2p * 5.0 - 4.0, 0.0);
            return (0.3 / CONTRAST) * COLOUR_1 + (1.0 - 0.3 / CONTRAST) * (COLOUR_1 * c1p + COLOUR_2 * c2p + vec4(c3p * COLOUR_3.rgb, c3p * COLOUR_1.a)) + light;
        }
    ]],
    fight = love.graphics.newShader[[
        #define SPIN_ROTATION -2.0
        #define SPIN_SPEED 7.0
        #define OFFSET vec2(0.0)
        #define COLOUR_1 vec4(0.05, 0.15, 0.35, 1.0)  // Dark deep ocean blue
        #define COLOUR_2 vec4(0.1, 0.25, 0.5, 1.0)    // Slightly lighter deep blue
        #define COLOUR_3 vec4(0.03, 0.1, 0.25, 1.0)   // Even darker blue for depth
        #define CONTRAST 3.5
        #define LIGHTING 0.4
        #define SPIN_AMOUNT 0.25
        #define PIXEL_FILTER 745.0
        #define SPIN_EASE 1.0
        #define PI 3.14159265359
        #define IS_ROTATE true
        extern float iTime;
        float hash1D(vec2 x)
        {
            vec2 q = floor(x * 65536.0);
            vec2 q_shifted = floor(q / 2.0);
            vec2 q_mixed = mod(q_shifted + q.yx, 65536.0);
            q = mod(1103515245.0 * q_mixed, 65536.0);
            float n = mod(1103515245.0 * (q.x + floor(q.y / 8.0)), 65536.0);
            return n / 65536.0;
        }
        float noise(vec2 uv)
        {
            vec2 i = floor(uv);
            vec2 f = fract(uv);
            float a = hash1D(i);
            float b = hash1D(i + vec2(1.0, 0.0));
            float c = hash1D(i + vec2(0.0, 1.0));
            float d = hash1D(i + vec2(1.0, 1.0));
            vec2 u = f * f * (3.0 - 2.0 * f);
            return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
        }
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
        {
            vec2 screenSize = love_ScreenSize.xy;
            float pixel_size = length(screenSize.xy) / PIXEL_FILTER;
            vec2 uv = (floor(screen_coords.xy * (1.0 / pixel_size)) * pixel_size - 0.5 * screenSize.xy) / length(screenSize.xy) - OFFSET;
            float uv_len = length(uv);
            
            float speed = (SPIN_ROTATION * SPIN_EASE * 0.2);
            if (IS_ROTATE) {
                speed = iTime * speed;
            }
            speed += 302.2;
            float new_pixel_angle = atan(uv.y, uv.x) + speed - SPIN_EASE * 20.0 * (1.0 * SPIN_AMOUNT * uv_len + (1.0 - 1.0 * SPIN_AMOUNT));
            vec2 mid = (screenSize.xy / length(screenSize.xy)) / 2.0;
            uv = vec2(uv_len * cos(new_pixel_angle) + mid.x, uv_len * sin(new_pixel_angle) + mid.y) - mid;
            
            uv *= 30.0;
            speed = iTime * SPIN_SPEED;
            vec2 uv2 = vec2(uv.x + uv.y);
            
            for (int i = 0; i < 5; i++) {
                uv2 += sin(max(uv.x, uv.y)) + uv;
                uv += 0.5 * vec2(cos(5.1123314 + 0.353 * uv2.y + speed * 0.131121), sin(uv2.x - 0.113 * speed));
                uv -= 1.0 * cos(uv.x + uv.y) - 1.0 * sin(uv.x * 0.711 - uv.y);
            }
            
            float contrast_mod = (0.25 * CONTRAST + 0.5 * SPIN_AMOUNT + 1.2);
            float paint_res = min(2.0, max(0.0, length(uv) * 0.035 * contrast_mod));
            float c1p = max(0.0, 1.0 - contrast_mod * abs(1.0 - paint_res));
            float c2p = max(0.0, 1.0 - contrast_mod * abs(paint_res));
            float c3p = 1.0 - min(1.0, c1p + c2p);
            float light = (LIGHTING - 0.2) * max(c1p * 5.0 - 4.0, 0.0) + LIGHTING * max(c2p * 5.0 - 4.0, 0.0);
            
            vec4 fragColor = (0.3 / CONTRAST) * COLOUR_1 + (1.0 - 0.3 / CONTRAST) * (COLOUR_1 * c1p + COLOUR_2 * c2p + vec4(c3p * COLOUR_3.rgb, c3p * COLOUR_1.a)) + light;
            
            // Add subtle noise overlay for texture
            float noise_val = noise(uv * 10.0 + iTime * 0.1);
            fragColor.rgb += vec3(0.02, 0.04, 0.06) * noise_val;
            
            return fragColor * color;
        }
    ]],
    crt = love.graphics.newShader[[
        extern number time; // For flicker and noise animation
        extern vec2 resolution; // Screen resolution
        // Noise function for subtle interference
        float noise(vec2 p) {
            return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
        }
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec2 uv = screen_coords / resolution;
            // Screen curvature (barrel distortion)
            vec2 center = vec2(0.5, 0.5);
            vec2 offset = uv - center;
            float dist = length(offset);
            float curvature = 0.0075; // Adjust curvature strength
            uv = center + offset * (1.0 + curvature * dist * dist);
            // Clamp UVs to avoid sampling outside texture
            if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
                return vec4(0.0, 0.0, 0.0, 1.0); // Black outside screen
            }
            // Sample texture with slight RGB separation
            vec4 texColor;
            float offsetAmount = 0.001; // Adjust for phosphor separation
            texColor.r = Texel(texture, uv + vec2(offsetAmount, 0.0)).r;
            texColor.g = Texel(texture, uv).g;
            texColor.b = Texel(texture, uv - vec2(offsetAmount, 0.0)).b;
            texColor.a = 1.0;
            // Scanlines
            float scanline = sin(uv.y * resolution.y * 1.5) * 0.05; // Adjust frequency and intensity
            texColor.rgb -= scanline;
            // Noise/flicker
            float noiseVal = noise(screen_coords + vec2(time * 10.0, 0.0)) * 0.03; // Subtle noise
            texColor.rgb += noiseVal;
            // Vignette effect
            float vignette = smoothstep(1, 0.1, dist);
            texColor.rgb *= vignette;
            return texColor * color;
        }
    ]],
    lost = love.graphics.newShader[[
        extern number time;
        extern vec2 resolution;
        float random (in vec2 st) {
            return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
        }
        float noise (in vec2 st) {
            vec2 i = floor(st);
            vec2 f = fract(st);
            float a = random(i);
            float b = random(i + vec2(1.0, 0.0));
            float c = random(i + vec2(0.0, 1.0));
            float d = random(i + vec2(1.0, 1.0));
            vec2 u = f * f * (3.0 - 2.0 * f);
            return mix(a, b, u.x) +
                   (c - a) * u.y * (1.0 - u.x) +
                   (d - b) * u.x * u.y;
        }
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            float t = time / 10.0;
            vec2 p = 100.0 * screen_coords / resolution;
            float y = p.y / 100.0;
            p.y += sin(2.0 * t);
            p.x += cos(5.0 * t);
            p *= mat2(sin(t / 2.0), -cos(t / 2.0), cos(t / 2.0), sin(t / 2.0)) / 8.0;
            vec4 fragColor = vec4(0.0);
            for (float i = 0.0; i < 8.0; i += 1.0) {
                fragColor = cos(p.xxxx * 0.3) * 0.5 + 0.5;
                float n = noise(p / 5.0);
                fragColor *= n;
                p.x += sin(p.y + time * 0.3 + i);
                p *= mat2(6.0, -8.0, 8.0, 6.0) / 8.0;
            }
            fragColor *= 1.0 - smoothstep(0.0, 0.91, y);
            fragColor *= vec4(0.2, 0.23, 0.54, 1.0);
            return fragColor * color;
        }
    ]]
}

return shaders