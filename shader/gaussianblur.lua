blurShader = love.graphics.newShader([[
        extern number radius;
        vec4 effect(vec4 color, Image tex, vec2 texCoords, vec2 screenCoords) {
            vec4 sum = vec4(0.0);
            number sigma = radius * 0.5;
            number numSamples = radius * 2.0 + 1.0;
            number weightSum = 0.0;

            for (number i = -radius; i <= radius; i++) {
                number weight = exp(-0.5 * (i * i) / (sigma * sigma));
                sum += Texel(tex, texCoords + vec2(i / love_ScreenSize.x, 0.0)) * weight;
                weightSum += weight;
            }
            return sum / weightSum;
        }
    ]])