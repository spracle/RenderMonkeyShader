float4x4 matViewProjection;
float distanceScale;
float4x4 matProjection;
float4 vViewPosition;
float fTime0_X;

struct VS_INPUT 
{
   float4 Position : POSITION0;
   float3 Normal   : NORMAL;
};

struct VS_OUTPUT 
{
   float4 Position : POSITION0;
   float3 Normal   : TEXCOORD0;
   float3 lightVec : TEXCOORD1;
   float3 viewVec  : TEXCOORD2;
   float4 shadowCrd: TEXCOORD3;
   
};

VS_OUTPUT vs_main( VS_INPUT Input )
{
   VS_OUTPUT Output;
   
   Output.Position = mul( Input.Position, matViewProjection );
   Output.Normal = Input.Normal;
   
   float3 lightPos;
   lightPos.x = cos(1.321 * fTime0_X);
   lightPos.z = sin(0.923 * fTime0_X);
   lightPos.xz = 100 * normalize(lightPos.xz);
   lightPos.y = 100;
   
   Output.lightVec = distanceScale * (lightPos - Input.Position.xyz);
   Output.viewVec = vViewPosition - Input.Position.xyz;
   
   float3 dirZ = -normalize(lightPos);
   float3 up = float3(0,0,1);
   float3 dirX = cross(up, dirZ);
   float3 dirY = cross(dirZ, dirX);

   // Transform into light's view space.
   float4 pos;
   Input.Position.xyz -= lightPos;
   pos.x = dot(dirX, Input.Position);
   pos.y = dot(dirY, Input.Position);
   pos.z = dot(dirZ, Input.Position);
   pos.w = 1;
   
   float4 sPos = mul(pos,matProjection);

   //projective texturing
   sPos.z += 10;
   Output.shadowCrd.x = 0.5 * (sPos.z + sPos.x);
   Output.shadowCrd.y = 0.5 * (sPos.z - sPos.y);
   Output.shadowCrd.z = 0;
   Output.shadowCrd.w = sPos.z;
   
   return( Output );
   
}

// ps Shader ///////////////////////////////////////////////////////


float backProjectionCut;
float Ka;
float Kd;
float Ks;
float4 modelColor;
float shadowBias;
sampler ShadowMap;
sampler SpotLight;

float4 ps_main(float3 normal: TEXCOORD0, float3 lightVec: TEXCOORD1, float3 viewVec: TEXCOORD2, float4 shadowCrd: TEXCOORD3) : COLOR {
   normal = normalize(normal);
   float depth = length(lightVec);
   lightVec /= depth;

   float diffuse = saturate(dot(lightVec, normal));
   float specular = pow(saturate(dot(reflect(-normalize(viewVec), normal), lightVec)), 16);

   float shadowMap = tex2Dproj(ShadowMap, shadowCrd).r;
 
   float spotLight = tex2Dproj(SpotLight, shadowCrd).r;
   
   float shadow = (depth < shadowMap + shadowBias);
   
   shadow *= (shadowCrd.w > backProjectionCut);
   
   shadow *= spotLight;

   // Shadow any light contribution except ambient
   return Ka * modelColor + (Kd * diffuse * modelColor + Ks * specular) * shadow;
}



