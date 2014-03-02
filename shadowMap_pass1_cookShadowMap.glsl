float4x4 view_proj_matrix: register(c0);
float4 lightPos: register(c4);
float distanceScale: register(c5);
float4x4 matProjection;
float fTime0_X;
struct VS_OUTPUT {
   float4 Pos: POSITION;
   float3 lightVec: TEXCOORD0;
};

VS_OUTPUT vs_main(float4 Pos: POSITION){
   VS_OUTPUT Out;

   // Animate the light position.
   float3 lightPos;
   lightPos.x = cos(1.321 * fTime0_X);
   lightPos.z = sin(0.923 * fTime0_X);
   lightPos.xz = 100 * normalize(lightPos.xz);
   lightPos.y = 100;

   // Create view vectors
   float3 dirZ = -normalize(lightPos);
   float3 up = float3(0,0,1);
   float3 dirX = cross(up, dirZ);
   float3 dirY = cross(dirZ, dirX);

   // Transform into light's view space.
   float4 pos;
   Pos.xyz -= lightPos;
   pos.x = dot(dirX, Pos);
   pos.y = dot(dirY, Pos);
   pos.z = dot(dirZ, Pos);
   pos.w = 1;

   // Project it.
   Out.Pos = mul(pos,matProjection);
   Out.lightVec = distanceScale * pos;

   return Out;
}

float4 ps_main(float3 lightDis: TEXCOORD0) : COLOR0
{   
   return length(lightDis);
}