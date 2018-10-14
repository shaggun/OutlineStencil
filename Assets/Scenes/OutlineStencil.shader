Shader "Custom/OutlineStencil"
{
	Properties
	{
		_OutlineColor ("Outline color", Color) = (0,0,0,1)
		_OutlineWidth ("Outlines width", Range (0.0, 2.0)) = 1.1
		_OutlineClearWidth("Outlines Clear width", Range (0.0, 2.0)) = 1.1
		_Stencil("Stencil ID", Int) = 16
		
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata{
		half4 vertex : POSITION;
		half2 texcoord : TEXCOORD0;
	};

	struct v2f {
		half4 vertex : SV_POSITION;
		half2 texcoord : TEXCOORD0;
		UNITY_FOG_COORDS(1)
		UNITY_VERTEX_OUTPUT_STEREO
	};

	ENDCG

	SubShader
	{
		Tags { 
			"RenderTye" = "Opaque"
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
		}

		Pass //Stencil
		{
			Name "Stencil"
			
			ZWrite Off
			Cull Back
			//ZTest Always
			//Blend SrcAlpha OneMinusSrcAlpha
			ColorMask 0

			Stencil
			{
				Ref [_Stencil]
				Comp Always
				Pass Replace
				ZFail Replace
			
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			half _OutlineClearWidth;
			fixed4 _OutlineColor;
		
			v2f vert(appdata v)
			{
				appdata original = v;
				v.vertex.xyz += _OutlineClearWidth * normalize(v.vertex.xyz);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(appdata, o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;

			}

			half4 frag(v2f i) : COLOR
			{
				return _OutlineColor;
			}

			ENDCG
		}

		Pass //Outline
		{
			Name "Outline"
			
			ZWrite Off
			Cull Back
			//ZTest Always
			//Blend SrcAlpha OneMinusSrcAlpha

			Stencil
			{
				Ref [_Stencil]
				Comp NotEqual
				//Pass Keep
				//ZFail Keep
				//Pass Replace
				//ZFail Replace
			
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			half _OutlineWidth;
			fixed4 _OutlineColor;
		
			v2f vert(appdata v)
			{
				appdata original = v;
				v.vertex.xyz += _OutlineWidth * normalize(v.vertex.xyz);
				v2f o;
				UNITY_INITIALIZE_OUTPUT(appdata, o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;

			}

			half4 frag(v2f i) : COLOR
			{
				return _OutlineColor;
			}

			ENDCG
		}
	}
	Fallback "Diffuse"//If we remove this there won't be any shadows
}
