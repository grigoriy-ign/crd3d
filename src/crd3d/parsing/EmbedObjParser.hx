package crd3d.parsing;

import crd3d.geom.*;
import crd3d.displayobjects.*;
import flash.Vector;

/**
 *
 * Wavefront *.obj parser
 */
class EmbedObjParser
{

	private static var src:String = "";
	private static var res:String = "";

	public static function parse(source:String):Object3d
	{
		src = source;
		res = "";

		vertexArr = [];
		vertexArr.push("");
		vertexArr.push("");
		vertexArr.push("");

		vertexUVArr = [];
		vertexUVArr.push("");
		vertexUVArr.push("");

		var modelVertices:Vector<V3d> = new Vector<V3d>();
		var modelUVVertices:Vector<V2d> = new Vector<V2d>();
		var modelFaces:Vector<Face> = new Vector<Face>();
		var modelUVFaces:Vector<Face> = new Vector<Face>();

		// Vertices
		var verticesSI:Int = src.indexOf("v ", 0); 				// Vertices string position start
		var verticesEI:Int = src.indexOf("vn ", verticesSI); 	// Vertices string position end

		if (verticesEI == -1) verticesEI = src.indexOf("vt ", verticesSI);
		if (verticesEI == -1) verticesEI = src.indexOf("g ", verticesSI);
		if (verticesEI == -1) verticesEI = src.indexOf("s ", verticesSI);
		if (verticesEI == -1) verticesEI = src.indexOf("f ", verticesSI);

		var verticesString:String = src.substring(verticesSI, verticesEI);		// Vertices string

		// Faces
		var facesSI:Int = src.indexOf("f ", verticesEI);	// Faces string position start
		var facesEI:Int = src.indexOf("g ", facesSI);		// Faces string position end

		if (facesEI == -1) facesEI = src.indexOf("usemtl ", verticesSI);

		var facesString:String = src.substring(facesSI, src.length);			// Faces string

		// UV vertices
		var uvVerticesSI:Int = src.indexOf("vt ", verticesEI);	// UV vertices position start
		var uvVerticesEI:Int = src.indexOf("s ", uvVerticesSI);	// UV vertices position end

		if (uvVerticesEI == -1) uvVerticesEI = src.indexOf("g ", uvVerticesSI);
		if (uvVerticesEI == -1) uvVerticesEI = src.indexOf("s ", uvVerticesSI);
		if (uvVerticesEI == -1) uvVerticesEI = src.indexOf("f ", uvVerticesSI);
		if (uvVerticesEI == -1) uvVerticesEI = src.indexOf("usemtl ", uvVerticesSI);

		var uvVerticesString:String = src.substring(uvVerticesSI, uvVerticesEI); // Vertices string

		var ci:String = "";
		var ci2:String = "";

		for (i in 0...verticesString.length)
		{
			ci = verticesString.charAt(i);
			if (ci == "v")
			{
				var nextVerticeIndex:Int = verticesString.indexOf("v ", i + 1);
				if (nextVerticeIndex == -1) nextVerticeIndex = verticesString.length;
				var curVerticeSubstr:String = verticesString.substring(i + 2, nextVerticeIndex);
				modelVertices.push( getVertex(curVerticeSubstr) );
			}
		}

		for (i in 0...uvVerticesString.length)
		{
			ci = uvVerticesString.charAt(i);
			ci2 = uvVerticesString.charAt(i+1);

			if (ci == "v" && ci2 == "t")
			{
				var nextVerticeIndex:Int = uvVerticesString.indexOf("vt ", i + 2);
				if (nextVerticeIndex == -1) nextVerticeIndex = uvVerticesString.length;
				var curVerticeSubstr:String = uvVerticesString.substring(i + 3, nextVerticeIndex);
				modelUVVertices.push( getUVVertex(curVerticeSubstr) );
			}
		}

		for (i in 0...facesString.length)
		{
			ci = facesString.charAt(i);
			if (ci == "f")
			{
				var nextFaceIndex:Int = facesString.indexOf("f ", i + 1);
				if (nextFaceIndex == -1) nextFaceIndex = facesString.length;
				var curFaceSubstring:String = facesString.substring(i + 2, nextFaceIndex);
				modelFaces.push( addFace(curFaceSubstring, 0) );
				modelUVFaces.push( addFace(curFaceSubstring, 1) );
			}
		}

		// Create 3D object
		var new3DObj:Object3d = new Object3d();
		new3DObj.vertices = modelVertices;
		new3DObj.faces = modelFaces;
		new3DObj.uvVertices = modelUVVertices;
		new3DObj.uvFaces = modelUVFaces;

		return new3DObj;
	}

	private static var vertexArr:Array<String> = new Array<String>();

	/**
	 * Converts obj vertex string to V3d
	 */
	private static function getVertex(str:String):V3d
	{
		//Debug.tracestr(str);

		var vertexInd:Int = 0;

		vertexArr[0] = "";
		vertexArr[1] = "";
		vertexArr[2] = "";

		for (i in 0...str.length)
		{
			if (isNumeric(str.charAt(i)))
			{
				vertexArr[vertexInd] += str.charAt(i);
			}
			if (str.charAt(i) == " ")
			{
				vertexInd++;
			}
		}

		var newVertex:V3d = new V3d();
		newVertex.x = Std.parseFloat(vertexArr[0]);
		newVertex.y = Std.parseFloat(vertexArr[1]);
		newVertex.z = Std.parseFloat(vertexArr[2]);

		return newVertex;
	}

	private static var vertexUVArr:Array<String> = new Array<String>();

	/**
	 * Converts obj vertex string to V2d
	 */
	private static function getUVVertex(str:String):V2d
	{
		var vertexInd:Int = 0;

		vertexArr[0] = "";
		vertexArr[1] = "";

		for (i in 0...str.length)
		{
			if (isNumeric(str.charAt(i)))
			{
				vertexArr[vertexInd] += str.charAt(i);
			}
			if (str.charAt(i) == " ")
			{
				vertexInd++;
			}
		}

		var newVertex:V2d = new V2d();
		newVertex.x = Std.parseFloat(vertexArr[0]);
		newVertex.y = Std.parseFloat(vertexArr[1]);

		newVertex.y *= -1;

		return newVertex;
	}

	/**
	 * Converts obj face string "1/13/1 4/22/4 3/23/3 2/14/2" to Face
	 */
	private static function addFace(str:String, index:Int):Face
	{

		var stringFaces:Array<String> = str.split(" ");
		var stringFaceIndices:Array<String>;
		var indices:Array<Int> = new Array<Int>();

		for (i in 0...stringFaces.length)
		{
			var curStringFace:String = stringFaces[i];
			stringFaceIndices = curStringFace.split("/");
			var stringIndex:String = stringFaceIndices[index];

			indices.push( Std.parseInt(stringIndex) );
		}

		var newFace:Face = new Face(indices);

		var dbgString:String = "Face: ["+index+"]: ";
		for (i in 0...newFace.indices.length)
		{
			dbgString += newFace.indices[i] + "; ";
		}

		return newFace;
	}

	/**
	 * Returns true if symbol numeric
	 */
	private static function isNumeric(r:String):Bool
	{
		if (r == ".") return true;
		if (r == "e") return true;
		if (r == "+") return true;
		if (r == "-") return true;

		if (Std.parseInt(r) != null)
		{
			return true;
		}

		else return false;
	}

}