package modcharting;

import flixel.FlxStrip;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import flixel.math.FlxMath;
import lime.math.Vector2;
import objects.Note;
import openfl.geom.Vector3D;
#if LEATHER
import game.Note;
#end

class SustainStrip extends FlxStrip
{
	private static final noteUV:Array<Float> = [
		0,     0, // top left
		1,     0, // top right
		0,     0.5, // half left
		1,     0.5, // half right
		0,     1, // bottom left
		1,     1, // bottom right
	];
	private static final noteIndices:Array<Int> = [
		0,
		1,
		2,
		1,
		3,
		2,
		2,
		3,
		4,
		3,
		4,
		5 // makes 4 triangles
	];

	private var daNote:Note;

	override public function new(daNote:Note)
	{
		this.daNote = daNote;
		daNote.alpha = 1;
		super(0, 0);
		loadGraphic(daNote.updateFramePixels());
		shader = daNote.shader;
		for (uv in noteUV)
		{
			uvtData.push(uv);
			vertices.push(0);
		}
		for (ind in noteIndices)
			indices.push(ind);
	}

	// Set this to true for spiral holds!
	// Note, they might cause some visual gaps. Maybe fix later?
	public var spiralHolds:Bool = false; // for now false cuz yeah

	// for spiral holds
	// ported from FunkinModchart
	public function getPointsNormal(pos:NotePositionData, nextFramePos:NotePositionData, holdSize:Float)
	{
		var unitX = nextFramePos.x - pos.x;
		var unitY = nextFramePos.y - pos.y;
		// normalizing
		var length = Math.sqrt(unitX * unitX + unitY * unitY);
		unitX /= length;
		unitY /= length;
		holdSize *= .5 * (1 / -pos.z) * pos.scaleX - FlxMath.fastCos(pos.angleY * (Math.PI / 180));

		return [
			//  left
			pos.x + -unitY * holdSize,
			pos.y + unitX * holdSize,
			// right
			pos.x + unitY * holdSize,
			pos.y + -unitX * holdSize,
		];
	}

	public function applyPerspective(noteData:NotePositionData, pos:Vector3D, rotatePivot:Vector2):Array<Float>
	{
		var vect3D:Vector3D = new Vector3D(pos.x, pos.y, pos.z);
		var vect2:Vector2 = new Vector2(vect3D.x, vect3D.z);
		var rotModPivot:Vector2 = new Vector2(rotatePivot.x, vect3D.z);

		vect2 = ModchartUtil.rotateAround(rotModPivot, vect2, noteData.angleY);
		vect3D.x = vect2.x;
		vect3D.z = vect2.y;

		var thisNotePos:Vector3D = ModchartUtil.calculatePerspective(vect3D, ModchartUtil.defaultFOV * (Math.PI / 180), 0, 0);

		var returnFloat:Array<Float> = [];
		returnFloat.push(thisNotePos.x);
		returnFloat.push(thisNotePos.y);
		return returnFloat;
	}

	public function constructVertices(noteData:NotePositionData, topPositions:Array<NotePositionData>, middlePositions:Array<NotePositionData>,
			bottomPositions:Array<NotePositionData>, flipGraphic:Bool, reverseClip:Bool)
	{
		var holdWidth = daNote.frameWidth;
		// var xOffset = daNote.frameWidth/6.5; //FUCK YOU, MAGIC NUMBER GO! MAKE THEM HOLDS CENTERED DAMNIT!

		daNote.rgbShader.stealthGlow = noteData.stealthGlow; // make sure at the moment we render sustains they get shader changes? (OMG THIS FIXED SUDDEN HIDDEN AND ETC LMAO)
		daNote.rgbShader.stealthGlowRed = noteData.glowRed;
		daNote.rgbShader.stealthGlowGreen = noteData.glowGreen;
		daNote.rgbShader.stealthGlowBlue = noteData.glowBlue;

		var yOffset = -1; // fix small gaps
		if (reverseClip)
			yOffset *= -1;

		var verts:Array<Float> = [];

		var top = [];
		var mid = [];
		var bottom = [];

		if (!flipGraphic)
		{
			if (spiralHolds)
			{
				top = getPointsNormal(topPositions[0], topPositions[1], holdWidth);
				mid = getPointsNormal(middlePositions[0], middlePositions[1], holdWidth);
				bottom = getPointsNormal(bottomPositions[0], bottomPositions[1], holdWidth);
			}
			else
			{
				var zScaleTop = 1 / -topPositions[0].z;
				var zScaleMid = 1 / -middlePositions[0].z;
				var zScaleBottom = 1 / -bottomPositions[0].z;
				
				var angleYTop = FlxMath.fastCos(topPositions[0].angleY * (Math.PI / 180)) * 15;
				var angleYMid = FlxMath.fastCos(middlePositions[0].angleY * (Math.PI / 180)) * 15;
				var angleYBottom = FlxMath.fastCos(bottomPositions[0].angleY * (Math.PI / 180)) * 15;

				//topPositions[0].x + holdWidth * .5 * zScaleTop * topPositions[0].scaleX, topPositions[0].y
				top = [
					topPositions[0].x - holdWidth * .5 * zScaleTop * topPositions[0].scaleX - angleYTop, topPositions[0].y,
					topPositions[0].x + holdWidth * .5 * zScaleTop * topPositions[0].scaleX + angleYTop, topPositions[0].y
				];
				//middlePositions[0].x + holdWidth * .5 * zScaleMid * middlePositions[0].scaleX, middlePositions[0].y
				mid = [
					middlePositions[0].x - holdWidth * .5 * zScaleMid * middlePositions[0].scaleX - angleYMid, middlePositions[0].y,
					middlePositions[0].x + holdWidth * .5 * zScaleMid * middlePositions[0].scaleX + angleYMid, middlePositions[0].y
				];
				//bottomPositions[0].x + holdWidth * .5 * zScaleBottom * bottomPositions[0].scaleX, bottomPositions[0].y
				bottom = [
					bottomPositions[0].x - holdWidth * .5 * zScaleBottom * bottomPositions[0].scaleX - angleYBottom, bottomPositions[0].y,
					bottomPositions[0].x + holdWidth * .5 * zScaleBottom * bottomPositions[0].scaleX + angleYBottom, bottomPositions[0].y
				];
			}
		}
		else
		{
			if (spiralHolds)
			{
				top = getPointsNormal(bottomPositions[0], bottomPositions[1], holdWidth);
				mid = getPointsNormal(middlePositions[0], middlePositions[1], holdWidth);
				bottom = getPointsNormal(topPositions[0], topPositions[1], holdWidth);
			}
			else
			{
				var zScaleTop = 1 / -bottomPositions[0].z;
				var zScaleMid = 1 / -middlePositions[0].z;
				var zScaleBottom = 1 / -topPositions[0].z;

				var angleYTop = FlxMath.fastCos(topPositions[0].angleY * (Math.PI / 180)) * 15;
				var angleYMid = FlxMath.fastCos(middlePositions[0].angleY * (Math.PI / 180)) * 15;
				var angleYBottom = FlxMath.fastCos(bottomPositions[0].angleY * (Math.PI / 180)) * 15;

				top = [
					bottomPositions[0].x - holdWidth * .5 * zScaleTop * bottomPositions[0].scaleX - angleYBottom, bottomPositions[0].y,
					bottomPositions[0].x + holdWidth * .5 * zScaleTop * bottomPositions[0].scaleX + angleYBottom, bottomPositions[0].y
				];
				mid = [
					middlePositions[0].x - holdWidth * .5 * zScaleMid * middlePositions[0].scaleX - angleYMid, middlePositions[0].y,
					middlePositions[0].x + holdWidth * .5 * zScaleMid * middlePositions[0].scaleX + angleYMid, middlePositions[0].y
				];
				bottom = [
					topPositions[0].x - holdWidth * .5 * zScaleBottom * topPositions[0].scaleX - angleYTop, topPositions[0].y,
					topPositions[0].x + holdWidth * .5 * zScaleBottom * topPositions[0].scaleX + angleYTop, topPositions[0].y
				];
			}
		}

		for (vector in [top, mid, bottom])
		{
			for (i in vector)
				verts.push(i);
		}

		vertices = new DrawData(12, true, verts);
	}
}
