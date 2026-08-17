package massive.util;
import massive.animation.Animation;
import massive.animation.AnimationFrame;
import massive.data.Frame;
import massive.data.VertexColorData;
import massive.data.VertexPositionData;
import massive.display.Img;
#if flash
import openfl.Vector;
#end
import starling.animation.Transitions;

/**
 * ...
 * @author Matse
 */
class AnimUtils 
{
	
	#if flash
	static public function createAnimation(frames:Vector<Frame>, frameRate:Float = 60):Animation
	#else
	static public function createAnimation(frames:Array<Frame>, frameRate:Float = 60):Animation
	#end
	{
		var anim:Animation = Animation.fromPool();
		var timeStep:Float = 1.0 / frameRate;
		var frameTime:Float = 0.0;
		var count:Int = frames.length;
		
		for (i in 0...count)
		{
			frameTime += timeStep;
			anim.addFrame(AnimationFrame.fromPool(frames[i], frameTime));
		}
		anim.ready();
		return anim;
	}
	
	#if flash
	static public function createVertexAnimation(frames:Vector<Frame>, frameRate:Float = 60, positions:Vector<VertexPositionData> = null,
												 colors:Vector<VertexColorData> = null, colorOffsets:Vector<VertexColorData> = null,
												 events:Vector<String> = null, eventParams:Vector<Dynamic> = null, animation:Animation = null):Animation
	#else
	static public function createVertexAnimation(frames:Array<Frame>, frameRate:Float = 60, positions:Array<VertexPositionData> = null,
												 colors:Array<VertexColorData> = null, colorOffsets:Array<VertexColorData> = null,
												 events:Array<String> = null, eventParams:Array<Dynamic> = null, animation:Animation = null):Animation
	#end
	{
		if (animation == null) animation = Animation.fromPool();
		
		var numFrames:Int = frames.length;
		var numPositions:Int = 0;
		var numColors:Int = 0;
		var numColorOffsets:Int = 0;
		var numEvents:Int = 0;
		
		var usePositions:Bool = positions != null && positions.length != 0;
		var useColors:Bool = colors != null && colors.length != 0;
		var useColorOffsets:Bool = colorOffsets != null && colorOffsets.length != 0;
		var useEvents:Bool = events != null && events.length != 0;
		var useEventParams:Bool = useEvents && eventParams != null && eventParams.length != 0;
		
		if (usePositions) numPositions = positions.length;
		if (useColors) numColors = colors.length;
		if (useColorOffsets) numColorOffsets = colorOffsets.length;
		if (useEvents) numEvents = events.length;
		
		var numSteps:Int;
		var time:Float = 0.0;
		var frameTime:Float;
		var frameTimeStep:Float;
		var positionTime:Float;
		var positionTimeStep:Float;
		var colorTime:Float;
		var colorTimeStep:Float;
		var colorOffsetTime:Float;
		var colorOffsetTimeStep:Float;
		var eventTime:Float;
		var eventTimeStep:Float;
		var timeStep:Float = 1.0 / frameRate;
		
		var frameIndex:Int = 0;
		var positionIndex:Int = 0;
		var colorIndex:Int = 0;
		var colorOffsetIndex:Int = 0;
		var eventIndex:Int = 0;
		
		var animFrame:AnimationFrame;
		
		if (numFrames >= numPositions && numFrames >= numColors && numFrames >= numColorOffsets && numFrames >= numEvents)
		{
			numSteps = numFrames;
		}
		else if (usePositions && (numPositions >= numFrames && numPositions >= numColors && numPositions >= numColorOffsets && numPositions >= numEvents))
		{
			numSteps = numPositions;
		}
		else if (useColors && (numColors >= numFrames && numColors >= numPositions && numColors >= numColorOffsets && numColors >= numEvents))
		{
			numSteps = numColors;
		}
		else if (useColorOffsets && (numColorOffsets >= numFrames && numColorOffsets >= numPositions && numColorOffsets >= numColors && numColorOffsets >= numEvents))
		{
			numSteps = numColorOffsets;
		}
		else
		{
			numSteps = numEvents;
		}
		
		if (numSteps == 0) return animation;
		
		frameTime = frameTimeStep = timeStep / (numFrames / numSteps);
		positionTime = positionTimeStep = timeStep / (numPositions / numSteps);
		colorTime = colorTimeStep = timeStep / (numColors / numSteps);
		colorOffsetTime = colorOffsetTimeStep = timeStep / (numColorOffsets / numSteps);
		eventTime = eventTimeStep = timeStep / (numEvents / numSteps);
		
		for (i in 0...numSteps)
		{
			time += timeStep;
			animFrame = AnimationFrame.fromPool(frames[frameIndex], time);
			if (usePositions) animFrame.vertexPosition = positions[positionIndex];
			if (useColors) animFrame.vertexColor = colors[colorIndex];
			if (useColorOffsets) animFrame.vertexColorOffset = colorOffsets[colorOffsetIndex];
			if (useEvents) animFrame.event = events[eventIndex];
			if (useEventParams) animFrame.eventParams = eventParams[eventIndex];
			
			animation.addFrame(animFrame);
			
			if (time >= frameTime)
			{
				frameTime += frameTimeStep;
				++frameIndex;
			}
			if (usePositions && time >= positionTime)
			{
				positionTime += positionTimeStep;
				++positionIndex;
			}
			if (useColors && time >= colorTime)
			{
				colorTime += colorTimeStep;
				++colorIndex;
			}
			if (useColorOffsets && time >= colorOffsetTime)
			{
				colorOffsetTime += colorOffsetTimeStep;
				++colorOffsetIndex;
			}
			if (useEvents && time >= eventTime)
			{
				eventTime += eventTimeStep;
				++eventIndex;
			}
		}
		
		animation.ready();
		return animation;
	}
	
	#if flash
	static public function animateVertexPosition(position1:VertexPositionData, position2:VertexPositionData, duration:Float, transition:Float->Float = null, frameRate:Float = 60, positions:Vector<VertexPositionData> = null):Vector<VertexPositionData>
	#else
	static public function animateVertexPosition(position1:VertexPositionData, position2:VertexPositionData, duration:Float, transition:Float->Float = null, frameRate:Float = 60, positions:Array<VertexPositionData> = null):Array<VertexPositionData>
	#end
	{
		#if flash
		if (positions == null) positions = new Vector<VertexPositionData>();
		#else
		if (positions == null) positions = new Array<VertexPositionData>();
		#end
		
		if (transition == null) transition = Transitions.getTransition(Transitions.LINEAR);
		
		var timeStep:Float = 1.0 / frameRate;
		var time:Float = 0.0;
		var numSteps:Int = Math.ceil(duration / timeStep);
		var ratio:Float;
		var position:VertexPositionData;
		
		for (i in 0...numSteps)
		{
			ratio = time / duration;
			position = VertexPositionData.fromPool(interpolate(position1.pivotX, position2.pivotX, transition, ratio),
												   interpolate(position1.pivotY, position2.pivotY, transition, ratio),
												   position1.canInvertX && position2.canInvertX,
												   position1.canInvertY && position2.canInvertY,
												   true,
												   interpolate(position1.x1, position2.x1, transition, ratio), interpolate(position1.x2, position2.x2, transition, ratio),
												   interpolate(position1.x3, position2.x3, transition, ratio), interpolate(position1.x4, position2.x4, transition, ratio),
												   interpolate(position1.y1, position2.y1, transition, ratio), interpolate(position1.y2, position2.y2, transition, ratio),
												   interpolate(position1.y3, position2.y3, transition, ratio), interpolate(position1.y4, position2.y4, transition, ratio));
			
			positions[positions.length] = position;
			time += timeStep;
			if (time > duration) time = duration;
		}
		
		return positions;
	}
	
	#if flash
	static public function animateVertexPositionWithTransitionID(position1:VertexPositionData, position2:VertexPositionData, duration:Float, transitionID:String = null, frameRate:Float = 60, positions:Vector<VertexPositionData> = null):Vector<VertexPositionData>
	#else
	static public function animateVertexPositionWithTransitionID(position1:VertexPositionData, position2:VertexPositionData, duration:Float, transitionID:String = null, frameRate:Float = 60, positions:Array<VertexPositionData> = null):Array<VertexPositionData>
	#end
	{
		if (transitionID == null) transitionID = Transitions.LINEAR;
		return animateVertexPosition(position1, position2, duration, Transitions.getTransition(transitionID), frameRate, positions);
	}
	
	/**
	   
	   @param	positions1
	   @param	positions2
	   @param	fromIndex
	   @param	toIndex	(not included)
	   @param	transition
	   @param	positions
	   @return
	**/
	#if flash
	static public function animateVertexPositionSequence(positions1:Vector<VertexPositionData>, positions2:Vector<VertexPositionData>, fromIndex:Int = -1, toIndex:Int = -1, transition:Float->Float = null, positions:Vector<VertexPositionData> = null):Vector<VertexPositionData>
	#else
	static public function animateVertexPositionSequence(positions1:Array<VertexPositionData>, positions2:Array<VertexPositionData>, fromIndex:Int = -1, toIndex:Int = -1, transition:Float->Float = null, positions:Array<VertexPositionData> = null):Array<VertexPositionData>
	#end
	{
		#if flash
		if (positions == null) positions = new Vector<VertexPositionData>();
		#else
		if (positions == null) positions = new Array<VertexPositionData>();
		#end
		
		if (fromIndex == -1) fromIndex = 0;
		if (toIndex == -1) toIndex = positions2.length;
		
		if (transition == null) transition = Transitions.getTransition(Transitions.LINEAR);
		
		var numSteps:Int = toIndex - fromIndex -1;
		var step:Int = 0;
		var ratio:Float;
		var position:VertexPositionData;
		var position1:VertexPositionData;
		var position2:VertexPositionData;
		
		for (i in fromIndex...toIndex)
		{
			ratio = step / numSteps;
			position1 = positions1[i];
			position2 = positions2[i];
			position = VertexPositionData.fromPool(interpolate(position1.pivotX, position2.pivotX, transition, ratio),
												   interpolate(position1.pivotY, position2.pivotY, transition, ratio),
												   position1.canInvertX && position2.canInvertX,
												   position1.canInvertY && position2.canInvertY,
												   true,
												   interpolate(position1.x1, position2.x1, transition, ratio), interpolate(position1.x2, position2.x2, transition, ratio),
												   interpolate(position1.x3, position2.x3, transition, ratio), interpolate(position1.x4, position2.x4, transition, ratio),
												   interpolate(position1.y1, position2.y1, transition, ratio), interpolate(position1.y2, position2.y2, transition, ratio),
												   interpolate(position1.y3, position2.y3, transition, ratio), interpolate(position1.y4, position2.y4, transition, ratio));
			
			positions[positions.length] = position;
			++step;
		}
		
		return positions;
	}
	
	/**
	   
	   @param	positions1
	   @param	positions2
	   @param	fromIndex
	   @param	toIndex	(not included)
	   @param	transitionID
	   @param	positions
	   @return
	**/
	#if flash
	static public function animateVertexPositionSequenceWithTransitionID(positions1:Vector<VertexPositionData>, positions2:Vector<VertexPositionData>, fromIndex:Int = -1, toIndex:Int = -1, transitionID:String = null, positions:Vector<VertexPositionData> = null):Vector<VertexPositionData>
	#else
	static public function animateVertexPositionSequenceWithTransitionID(positions1:Array<VertexPositionData>, positions2:Array<VertexPositionData>, fromIndex:Int = -1, toIndex:Int = -1, transitionID:String = null, positions:Array<VertexPositionData> = null):Array<VertexPositionData>
	#end
	{
		if (transitionID == null) transitionID = Transitions.LINEAR;
		return animateVertexPositionSequence(positions1, positions2, fromIndex, toIndex, Transitions.getTransition(transitionID), positions);
	}
	
	#if flash
	static public function animateVertexColor(color1:VertexColorData, color2:VertexColorData, duration:Float, transition:Float->Float = null, frameRate:Float = 60, colors:Vector<VertexColorData> = null):Vector<VertexColorData>
	#else
	static public function animateVertexColor(color1:VertexColorData, color2:VertexColorData, duration:Float, transition:Float->Float = null, frameRate:Float = 60, colors:Array<VertexColorData> = null):Array<VertexColorData>
	#end
	{
		#if flash
		if (colors == null) colors = new Vector<VertexColorData>();
		#else
		if (colors == null) colors = new Array<VertexColorData>();
		#end
		
		if (transition == null) transition = Transitions.getTransition(Transitions.LINEAR);
		
		var timeStep:Float = 1.0 / frameRate;
		var time:Float = 0.0;
		var numSteps:Int = Math.ceil(duration / timeStep);
		var ratio:Float;
		var color:VertexColorData;
		
		for (i in 0...numSteps)
		{
			ratio = time / duration;
			color = VertexColorData.fromPool();
			color.red1 = interpolate(color1.red1, color2.red1, transition, ratio);
			color.red2 = interpolate(color1.red2, color2.red2, transition, ratio);
			color.red3 = interpolate(color1.red3, color2.red3, transition, ratio);
			color.red4 = interpolate(color1.red4, color2.red4, transition, ratio);
			color.green1 = interpolate(color1.green1, color2.green1, transition, ratio);
			color.green2 = interpolate(color1.green2, color2.green2, transition, ratio);
			color.green3 = interpolate(color1.green3, color2.green3, transition, ratio);
			color.green4 = interpolate(color1.green4, color2.green4, transition, ratio);
			color.blue1 = interpolate(color1.blue1, color2.blue1, transition, ratio);
			color.blue2 = interpolate(color1.blue2, color2.blue2, transition, ratio);
			color.blue3 = interpolate(color1.blue3, color2.blue3, transition, ratio);
			color.blue4 = interpolate(color1.blue4, color2.blue4, transition, ratio);
			color.alpha1 = interpolate(color1.alpha1, color2.alpha1, transition, ratio);
			color.alpha2 = interpolate(color1.alpha2, color2.alpha2, transition, ratio);
			color.alpha3 = interpolate(color1.alpha3, color2.alpha3, transition, ratio);
			color.alpha4 = interpolate(color1.alpha4, color2.alpha4, transition, ratio);
			
			colors[colors.length] = color;
			time += timeStep;
			if (time > duration) time = duration;
		}
		
		return colors;
	}
	
	#if flash
	static public function animateVertexColorWithTransitionID(color1:VertexColorData, color2:VertexColorData, duration:Float, transitionID:String = null, frameRate:Float = 60, colors:Vector<VertexColorData> = null):Vector<VertexColorData>
	#else
	static public function animateVertexColorWithTransitionID(color1:VertexColorData, color2:VertexColorData, duration:Float, transitionID:String = null, frameRate:Float = 60, colors:Array<VertexColorData> = null):Array<VertexColorData>
	#end
	{
		if (transitionID == null) transitionID = Transitions.LINEAR;
		
		return animateVertexColor(color1, color2, duration, Transitions.getTransition(transitionID), frameRate, colors);
	}
	
	/**
	   
	   @param	frames
	   @param	fromIndex
	   @param	toIndex	(not included)
	   @param	positions
	   @return
	**/
	#if flash
	static public function createVertexPositionSequenceFromFrames(frames:Vector<Frame>, fromIndex:Int = -1, toIndex:Int = -1, positions:Vector<VertexPositionData> = null):Vector<VertexPositionData>
	#else
	static public function createVertexPositionSequenceFromFrames(frames:Array<Frame>, fromIndex:Int = -1, toIndex:Int = -1, positions:Array<VertexPositionData> = null):Array<VertexPositionData>
	#end
	{
		#if flash
		if (positions == null) positions = new Vector<VertexPositionData>();
		#else
		if (positions == null) positions = new Array<VertexPositionData>();
		#end
		
		if (fromIndex == -1) fromIndex = 0;
		if (toIndex == -1) toIndex = frames.length;
		
		var img:Img = Img.fromPool();
		var position:VertexPositionData;
		
		for (i in fromIndex...toIndex)
		{
			img.frame = frames[i];
			DisplayUtils.updateTransform(img);
			position = VertexPositionData.fromImg(img);
			positions[positions.length] = position;
		}
		
		img.pool();
		
		return positions;
	}
	
	static public inline function getDuration(numFrames:Int, frameRate:Float = 60):Float
	{
		return numFrames * (1.0 / frameRate);
	}
	
	static public inline function interpolate(value1:Float, value2:Float, transition:Float->Float, ratio:Float):Float
	{
		return value1 + (value2 - value1) * transition(ratio);
	}
	
	#if flash
	static public function repeatFrames(frames:Vector<Frame>, numRepeats:Int, newFrames:Vector<Frame> = null):Void
	#else
	static public function repeatFrames(frames:Array<Frame>, numRepeats:Int, newFrames:Array<Frame> = null):Void
	#end
	{
		if (newFrames == null) newFrames = frames;
		
		var frameCount:Int = frames.length;
		for (i in 0...numRepeats)
		{
			for (j in 0...frameCount)
			{
				newFrames[newFrames.length] = frames[j];
			}
		}
	}
	
	#if flash
	static public function repeatVertexColors(colors:Vector<VertexColorData>, numRepeats:Int, newColors:Vector<VertexColorData> = null):Void
	#else
	static public function repeatVertexColors(colors:Array<VertexColorData>, numRepeats:Int, newColors:Array<VertexColorData> = null):Void
	#end
	{
		if (newColors == null) newColors = colors;
		
		var colorCount:Int = colors.length;
		for (i in 0...numRepeats)
		{
			for (j in 0...colorCount)
			{
				newColors[newColors.length] = colors[j];
			}
		}
	}
	
}