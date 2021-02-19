
/// Racing Spheres by F3R0 @ 2021

///////////////////////////////////////////////////////////////
///                                                         ///
///     I have remade this Ray Marching algoritm with       ///
///     BLENDER's Shader editor nodes. If you are curious   ///
///     about it, check my artstation.                      ///
///                                                         ///
///     https://www.artstation.com/ferotan                  ///
///                                                         ///
///////////////////////////////////////////////////////////////


/// SDF - Sphere

float sdSphere(vec3 p, float r) {
    float d = length(p)-r;
    return d;
}

/// SDF - Plane

float sdPlane(vec3 p) {
    float planeDist = p.y;
    return planeDist;
}

/// Scene

float sceneDist(vec3 p) {
    
    float speed = 1.0;
    vec3 sp1 = vec3(2,1,5);
    vec3 sp2 = vec3(-2,1,5);
    sp1.y = 1.0 + cos(iTime)*speed;
    sp1.x = 2.0 + sin(iTime)*speed;
    sp2.y = 1.0 + sin(iTime)*speed;
    sp2.x = -2.0 + cos(iTime)*speed;
    float sphere1 = sdSphere(p-sp1+sin(iTime),0.8);
    float sphere2 = sdSphere(p-sp2+cos(iTime),0.8);
    float planeDist = sdPlane(p-0.0);
    
/// Smooth Minimum
    float smDist = 1.4;
    float h = max( smDist-abs(sphere1-planeDist), 0.0 )/smDist;
    float h1 = max( smDist-abs(sphere2-planeDist), 0.0 )/smDist;
    float c = min( sphere1, planeDist ) - h*h*smDist*(1.0/4.0);
    float d = min( sphere2, planeDist ) - h1*h1*smDist*(1.0/4.0);
    
    return min(c,d);
    //return sin(c*d)/planeDist; // strange effect :)
 
    
}

/// Ray Marching


float RayMarch(vec3 ro, vec3 rd) {
	float dO=0.;
    
    for(int i=0; i<64; i++) {
    	vec3 p = ro + rd*dO;
        float dS = sceneDist(p);
        dO += dS;
        if(dO>64.0 || dS<0.1) break;
    }
    
    return dO;
}

/// Calculate Normals (Forward differences)

vec3 clcNormal(vec3 p) {
    float eps = 0.0001;
    vec2 h = vec2(eps,0);
    return normalize( vec3(sceneDist(p+h.xyy) - sceneDist(p),
                           sceneDist(p+h.yxy) - sceneDist(p),
                           sceneDist(p+h.yyx) - sceneDist(p)));
}

/// Calculate Light

float clcLight(vec3 p) {
    vec3 lightPos = vec3(0,5,0);
    lightPos.x = sin(25.+iTime)*5.;
    
    vec3 vL = normalize(lightPos-p);
    vec3 normal = clcNormal(p);
    
    float light = clamp(dot(normal,vL),0.0,1.0);
    float d = RayMarch(p+normal*0.2,vL);
    if(d<length(lightPos-p)) light*=0.5;
    
    return light;

}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
    uv.y -= 0.05+sin(iTime*3.0)*0.05;
    
    vec3 ro = vec3(0, 1, 0);
    vec3 rd = normalize(vec3(uv,1.0));

    float d = RayMarch(ro, rd);
    
    vec3 p = ro + rd * d;
    
    vec3 col = vec3(0);
    
    float light = clcLight(p);
    
    col = vec3(light*0.6,light*0.6, light*1.5);
    
   
    fragColor = vec4(col,1.0);
}

