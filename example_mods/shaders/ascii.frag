// Bitmap to ASCII (not really) fragment shader by movAX13h, September 2013
// This is the original shader that is now used in PixiJs, FL Studio and various other products.

// Here's a little tool for new characters: thrill-project.com/archiv/coding/bitmap/

// update 2018-12-14: values for characters are integer now (were float)
//                    since bit operations are available now, making use of them
//                    instead of int(mod(n/exp2(p.x + 5.0*p.y), 2.0))
// update 2023-04-21: added characters A-Z and 0-9 and some others
//                    black/white mode does not use gray value anymore

#pragma header

uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main

uniform bool active;

float character(int n, vec2 p)
{
	p = floor(p*vec2(-4.0, 4.0) + 2.5);
    if (clamp(p.x, 0.0, 4.0) == p.x)
	{
        if (clamp(p.y, 0.0, 4.0) == p.y)	
		{
        	int a = int(floor(p.x+0.5) + 5.0 * floor(p.y+0.5));
			if ((n > a)) return 1.0;
		}	
    }
	return 0.0;
}

void mainImage()
{
    vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
	vec2 pix = fragCoord.xy;
	vec3 col = texture(iChannel0, floor(pix/8.0)*8.0/iResolution.xy).rgb;	
	
	float gray = 0.3 * col.r + 0.59 * col.g + 0.11 * col.b;
	    
	int n =  4096;
    
    // limited character set
    if (gray > 0.2) n = 65600;    // :
	if (gray > 0.3) n = 163153;   // *
	if (gray > 0.4) n = 15255086; // o 
	if (gray > 0.5) n = 13121101; // &
	if (gray > 0.6) n = 15252014; // 8
	if (gray > 0.7) n = 13195790; // @
	if (gray > 0.8) n = 11512810; // #
    
	vec2 p = mod(pix/4.0, 2.0) - vec2(1.0);
    
	col = col*character(n, p);
	
	if (active) fragColor = vec4(col, flixel_texture2D(bitmap, uv).a);
	else fragColor = flixel_texture2D(bitmap, uv);
}
