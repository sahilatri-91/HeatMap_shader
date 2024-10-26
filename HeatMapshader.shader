Shader "Unlit/HeatMapshader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        //color pickers
        _Color0("Color 0",  Color)=(0,0,0,1)
        _Color1("Color 1", Color)=(0,.9,.2,1)
        _Color2("Color 2", Color)=(.9,1,0.3,1)
        _Color3("Color 3", Color)=(.9,.7,.1,1)
        _Color4("Color 4", Color)=(1,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
              
            float4 colors[5];
            float ranges[5];
            float _Hits[3*32];
            int _hitcount=0;


            
            float4    _Color0;
            float4    _Color1;
            float4    _Color2;
            float4    _Color3;
            float4    _Color4;

           void inti(){
            colors[0]=_Color0;  //black
            colors[1]=_Color1; //Green
            colors[2]=_Color2;//yellow
            colors[3]=_Color3;// orange
            colors[4]=_Color4;//Red
        float k=4;

            for(int i=4;i>=0;i--){

                ranges[i]=k/4;
                k--;
            }
            // _hitcount=2;
            // _Hits[0]=0;
            // _Hits[1]=0;
            // _Hits[2]=4.0;


            // _Hits[3]=1;
            // _Hits[4]=1;
            // _Hits[5]=3;
         
           }
         float distsqr(float2 a ,float2 b){
            float area_effect_size=1.0f;
            float d=pow(max(0.0,1.0- distance(a,b))/area_effect_size,2);

            return d;
         }
       float3 getHeatForPixel(float weight)
       {
        if(weight<=ranges[0])
        {
            return colors[0];
        }
        if(weight>= ranges[4])
        {
            return colors[4];
        }

        for( int i=0 ;i< 5; i++){
         if(weight <ranges[i])
         {
            float distance_lowerPt=weight-ranges[i-1];
            float size_range=ranges[i]-ranges[i-1];

            float ratio=distance_lowerPt/size_range;

            float3 color_range=colors[i]-colors[i-1];
            float3 color_contribution=color_range* ratio;

            float3 new_color=colors[i-1] + color_contribution;

            return new_color;
         }
        }
        return colors[0];
       }


            fixed4 frag (v2f i) : SV_Target    //call everytime for evey pixel across the quad
            {
                // sample the texture
                inti();
                fixed4 col = tex2D(_MainTex, i.uv);
                float2 uv=i.uv;
                uv=uv*4.0-float2(2.0,2.0);//change the uv co =odinates to -2,2

                float totalweight=0;
                for( float i=0; i< _hitcount;i++){
                    float2 work_pt= float2(_Hits[i*3],_Hits[i*3 +1]);
                    float pt_intensity=_Hits[i *3 + 2];

                totalweight+= 0.5* distsqr(uv,work_pt)*pt_intensity;
                }

                float3 heat= getHeatForPixel(totalweight);
                return col + float4(heat,0.5);
            }
            ENDCG
        }
    }
}

