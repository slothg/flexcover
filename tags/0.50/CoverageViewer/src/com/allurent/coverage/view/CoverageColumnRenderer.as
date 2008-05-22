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
    import com.allurent.coverage.model.SegmentModel;
    
    import mx.containers.Canvas;
    import mx.controls.Label;
    import mx.formatters.NumberFormatter;
    
    public class CoverageColumnRenderer extends Canvas
    {
        [Bindable]
        public var greenBar:Canvas;
        
        [Bindable]
        public var coverageLabel:Label;

        private static var percentFormatter:NumberFormatter = createPercentFormatter();
        private static var formatter:NumberFormatter = new NumberFormatter();
        
        private static function createPercentFormatter():NumberFormatter
        {
            var f:NumberFormatter = new NumberFormatter();
            f.precision = 2;
            return f;
        }

        protected function getCoverage(value:Object):Number
        {
            throw new Error("getCoverage() not overridden");
        }        
        
        protected function getCount(value:Object):int
        {
            throw new Error("getCount() not overridden");
        }
        
        protected function getTotal(value:Object):int
        {
            throw new Error("getTotal() not overridden");
        }

        override public function set data(value:Object):void
        {
            var coverage:Number = getCoverage(value);
            var happyColor:uint = 0x33FF33 + ((1- coverage) * 0xCC) + (uint((1 - coverage) * 0xCC) << 16);
            var warningColor:uint = 0xFF0000 + (coverage * 0xFF) + (uint(coverage * 0xFF) << 8)
            greenBar.setStyle("backgroundColor", happyColor);
            setStyle("backgroundColor", warningColor);
            coverageLabel.text = percentFormatter.format(coverage * 100) + "% ("
                + formatter.format(getCount(value)) + "/" + formatter.format(getTotal(value)) + ")";
            greenBar.percentWidth = coverage * 100;
        }
        
        public function set model(s:SegmentModel):void
        {
            data = s;
        }
    }
}