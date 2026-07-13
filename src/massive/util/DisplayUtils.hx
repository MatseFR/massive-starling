package massive.util;
import massive.display.Img;

/**
 * ...
 * @author Matse
 */
class DisplayUtils 
{
	@:access(massive.display.Img)
	static public function updateTransform(quad:Img):Void
	{
		var leftOffset:Float;
		var rightOffset:Float;
		var topOffset:Float;
		var bottomOffset:Float;
		
		var rotationChanged:Bool = quad._rotationChanged;
		var skewXChanged:Bool = quad._skewXChanged;
		var skewYChanged:Bool = quad._skewYChanged;
		
		if (rotationChanged)
		{
			quad._cosRotation = Math.cos(quad._rotation);
			quad._sinRotation = Math.sin(quad._rotation);
			quad._rotationChanged = false;
		}
		
		if (skewXChanged)
		{
			quad._cosSkewX = Math.cos(quad._skewX);
			quad._sinSkewX = -Math.sin(quad._skewX);
			quad._skewXChanged = false;
		}
		
		if (skewYChanged)
		{
			quad._cosSkewY = Math.cos(quad._skewY);
			quad._sinSkewY = Math.sin(quad._skewY);
			quad._skewYChanged = false;
		}
		
		if (quad._sizeXChanged)
		{
			if (quad._invertX)
			{
				quad._leftOffset = quad._frame.rightWidth * quad._scaleX;
				leftOffset = -quad._leftOffset;
				rightOffset = quad._rightOffset = quad._frame.leftWidth * quad._scaleX;
			}
			else
			{
				quad._leftOffset = quad._frame.leftWidth * quad._scaleX;
				leftOffset = -quad._leftOffset;
				rightOffset = quad._rightOffset = quad._frame.rightWidth * quad._scaleX;
			}
			quad._sizeXChanged = false;
		}
		else
		{
			leftOffset = -quad._leftOffset;
			rightOffset = quad._rightOffset;
		}
		
		if (quad._sizeYChanged)
		{
			if (quad._invertY)
			{
				quad._topOffset = quad._frame.bottomHeight * quad._scaleY;
				topOffset = -quad._topOffset;
				bottomOffset = quad._bottomOffset = quad._frame.topHeight * quad._scaleY;
			}
			else
			{
				quad._topOffset = quad._frame.topHeight * quad._scaleY;
				topOffset = -quad._topOffset;
				bottomOffset = quad._bottomOffset = quad._frame.bottomHeight * quad._scaleY;
			}
			quad._sizeYChanged = false;
		}
		else
		{
			topOffset = -quad._topOffset;
			bottomOffset = quad._bottomOffset;
		}
		
		quad._transformChanged = false;
		
		if (rotationChanged || skewXChanged || skewYChanged)
		{
			quad._a = quad._cosSkewY * quad._cosRotation - quad._sinSkewY * quad._sinRotation;
			quad._b = quad._cosSkewY * quad._sinRotation + quad._sinSkewY * quad._cosRotation;
			quad._c = quad._sinSkewX * quad._cosRotation - quad._cosSkewX * quad._sinRotation;
			quad._d = quad._sinSkewX * quad._sinRotation + quad._cosSkewX * quad._cosRotation;
		}
		
		quad._x1 = leftOffset * quad._a + topOffset * quad._c;
		quad._y1 = leftOffset * quad._b + topOffset * quad._d;
		quad._x2 = rightOffset * quad._a + topOffset * quad._c;
		quad._y2 = rightOffset * quad._b + topOffset * quad._d;
		quad._x3 = leftOffset * quad._a + bottomOffset * quad._c;
		quad._y3 = leftOffset * quad._b + bottomOffset * quad._d;
		quad._x4 = rightOffset * quad._a + bottomOffset * quad._c;
		quad._y4 = rightOffset * quad._b + bottomOffset * quad._d;
	}
	
}