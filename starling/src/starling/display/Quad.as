// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.display
{
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    
    import starling.core.RenderSupport;
    import starling.core.starling_internal;
    import starling.utils.VertexData;
    
    use namespace starling_internal;

    /** A Quad represents a rectangle with a uniform color or a color gradient.
     *  
     *  <p>You can set one color per vertex. The colors will smoothly fade into each other over the area
     *  of the quad. To display a simple linear color gradient, assign one color to vertices 0 and 1 and 
     *  another color to vertices 2 and 3. </p> 
     *
     *  <p>The indices of the vertices are arranged like this:</p>
     *  
     *  <pre>
     *  0 - 1
     *  | / |
     *  2 - 3
     *  </pre>
     * 
     *  @see Image
     */
    public class Quad extends DisplayObject
    {
        private var mTinted:Boolean;
        
        /** The raw vertex data of the quad. */
        protected var mVertexData:VertexData;
        
        /** Helper objects. */
        private static var sHelperVector:Vector3D = new Vector3D();
        private static var sHelperMatrix:Matrix = new Matrix();
        
        /** Creates a quad with a certain size and color. The last parameter controls if the 
         *  alpha value should be premultiplied into the color values on rendering, which can
         *  influence blending output. You can use the default value in most cases.  */
        public function Quad(width:Number, height:Number, color:uint=0xffffff,
                             premultipliedAlpha:Boolean=true)
        {
            mTinted = color != 0xffffff;
            mVertexData = new VertexData(4, premultipliedAlpha);
            updateVertexData(width, height, color, premultipliedAlpha);    
        }
        
        /** Updates the vertex data with specific values for dimensions and color. */
        protected function updateVertexData(width:Number, height:Number, color:uint,
                                            premultipliedAlpha:Boolean):void
        {
            mVertexData.setPremultipliedAlpha(premultipliedAlpha);
            mVertexData.setPosition(0, 0.0, 0.0);
            mVertexData.setPosition(1, width, 0.0);
            mVertexData.setPosition(2, 0.0, height);
            mVertexData.setPosition(3, width, height);            
            mVertexData.setUniformColor(color);
        }
        
        /** @inheritDoc */
        public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
        {
            if (resultRect == null) resultRect = new Rectangle();
            
            if (targetSpace == this) // optimization
            {
                mVertexData.getPosition(3, sHelperVector);
                resultRect.setTo(0.0, 0.0, sHelperVector.x, sHelperVector.y);
            }
            else if (targetSpace == parent && rotation == 0.0) // optimization
            {
                var scaleX:Number = this.scaleX;
                var scaleY:Number = this.scaleY;
                mVertexData.getPosition(3, sHelperVector);
                resultRect.setTo(x - pivotX * scaleX, y - pivotY * scaleY,
                                 sHelperVector.x * scaleX, sHelperVector.y * scaleY);
                if (scaleX < 0) { resultRect.width  *= -1; resultRect.x -= resultRect.width;  }
                if (scaleY < 0) { resultRect.height *= -1; resultRect.y -= resultRect.height; }
            }
            else
            {
                getTransformationMatrix(targetSpace, sHelperMatrix);
                mVertexData.getBounds(sHelperMatrix, 0, 4, resultRect);
            }
            
            return resultRect;
        }
        
        /** Returns the color of a vertex at a certain index. */
        public function getVertexColor(vertexID:int):uint
        {
            return mVertexData.getColor(vertexID);
        }
        
        /** Sets the color of a vertex at a certain index. */
        public function setVertexColor(vertexID:int, color:uint):void
        {
            mVertexData.setColor(vertexID, color);
            
            if (color != 0xffffff) mTinted = true;
            else mTinted = mVertexData.tinted;
        }
        
        /** Returns the alpha value of a vertex at a certain index. */
        public function getVertexAlpha(vertexID:int):Number
        {
            return mVertexData.getAlpha(vertexID);
        }
        
        /** Sets the alpha value of a vertex at a certain index. */
        public function setVertexAlpha(vertexID:int, alpha:Number):void
        {
            mVertexData.setAlpha(vertexID, alpha);
            
            if (alpha != 1.0) mTinted = true;
            else mTinted = mVertexData.tinted;
        }
        
        /** Returns the color of the quad, or of vertex 0 if vertices have different colors. */
        public function get color():uint 
        { 
            return mVertexData.getColor(0); 
        }
        
        /** Sets the colors of all vertices to a certain value. */
        public function set color(value:uint):void 
        {
            for (var i:int=0; i<4; ++i)
                setVertexColor(i, value);
            
            if (color != 0xffffff) mTinted = true;
            else mTinted = mVertexData.tinted;
        }
        
        /** @inheritDoc **/
        public override function set alpha(value:Number):void
        {
            super.alpha = value;
            
            if (alpha != 1.0) mTinted = true;
            else mTinted = mVertexData.tinted;
        }
        
        /** Copies the raw vertex data to a VertexData instance. */
        public function copyVertexDataTo(targetData:VertexData, targetVertexID:int=0):void
        {
            mVertexData.copyTo(targetData, targetVertexID);
        }
        
        /** @inheritDoc */
        public override function render(support:RenderSupport, parentAlpha:Number):void
        {
            support.batchQuad(this, parentAlpha);
        }
        
        /** @private 
         *  Returns true if the quad (or any of its vertices) is non-white or non-opaque. */
        starling_internal function get tinted():Boolean { return mTinted; }
    }
}