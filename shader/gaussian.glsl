// blur.glsl (Love2D compatible)

extern float resolution;
extern float radius;
extern vec2 dir;

vec4 effect(vec4 vcolor, Image tex, vec2 tc, vec2 sc) {
    vec4 sum = vec4(0.0);

    float blur = radius / resolution;
    float hstep = dir.x;
    float vstep = dir.y;

    // Gaussian weights (9-tap)
    sum += Texel(tex, vec2(tc.x - 4.0*blur*hstep, tc.y - 4.0*blur*vstep)) * 0.0162162162;
    sum += Texel(tex, vec2(tc.x - 3.0*blur*hstep, tc.y - 3.0*blur*vstep)) * 0.0540540541;
    sum += Texel(tex, vec2(tc.x - 2.0*blur*hstep, tc.y - 2.0*blur*vstep)) * 0.1216216216;
    sum += Texel(tex, vec2(tc.x - 1.0*blur*hstep, tc.y - 1.0*blur*vstep)) * 0.1945945946;

    sum += Texel(tex, tc) * 0.2270270270;

    sum += Texel(tex, vec2(tc.x + 1.0*blur*hstep, tc.y + 1.0*blur*vstep)) * 0.1945945946;
    sum += Texel(tex, vec2(tc.x + 2.0*blur*hstep, tc.y + 2.0*blur*vstep)) * 0.1216216216;
    sum += Texel(tex, vec2(tc.x + 3.0*blur*hstep, tc.y + 3.0*blur*vstep)) * 0.0540540541;
    sum += Texel(tex, vec2(tc.x + 4.0*blur*hstep, tc.y + 4.0*blur*vstep)) * 0.0162162162;

    return vcolor * sum;
}
