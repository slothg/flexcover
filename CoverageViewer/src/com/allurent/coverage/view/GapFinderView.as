/*
 * Copyright (c) 2008 Allurent, Inc.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished
 * to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
 * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
 package com.allurent.coverage.view
 {
     import mx.core.UIComponent;
     
     /**
      * This view displays a vertical bar with colored rectangles corresponding to runs of
      * source lines with line or branch coverage gaps.  The bar is displayed to one side of a scrollbar that
      * controls the source view; hence the name "gap finder". 
      */
     public class GapFinderView extends UIComponent
     { 
        /** Array of 2-element arrays representing top/bottom Y coordinates of coverage gaps. */
        private var _gapOffsets:Array = [];
        
        /** Top inset to start of gap views -- compensates for arrow at top of V scrollbar */
        public var topInset:Number = 16;
        
        /** Bottom inset to end of gap views -- compensates for arrow and dead square at bottom of V scrollbar */
        public var bottomInset:Number = 32;
        
        /**
         * Set the gapOffsets property by stashing the offsets and requesting a redisplay. 
         */
        public function set gapOffsets(offsets:Array):void
        {
            _gapOffsets = offsets;
            invalidateDisplayList();
        }
        
        /**
         * Display rectangles from the normalized gap offsets, rescaled for our height and inset
         * with our pet insets. 
         */
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            graphics.clear();
            
            var h:Number = unscaledHeight - (topInset + bottomInset);
            
            for each (var gap:Array in _gapOffsets)
            {
                graphics.beginFill(0xFF6666);
                graphics.drawRect(0, gap[0] * h + topInset,
                                  unscaledWidth, (gap[1] - gap[0]) * h);
                graphics.endFill();
            }
        }
    }
}