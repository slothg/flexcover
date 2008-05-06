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
package com.allurent.coverage.model
{
    import flash.events.Event;

    /** This event is dispatched if the execution count changes. */    
    [Event(name="executionCountChange",type="flash.events.Event")]
    
    /**
     * Model for a single executable element within the application. 
     */
    [Bindable]
    public class ElementModel extends SegmentModel
    {
        /** Number of times that this line has been executed. */
        public var executionCount:uint = 0;
        
        public static const EXECUTION_COUNT_CHANGE:String = "executionCountChange";
        
        /**
         * Construct a new ElementModel. 
         */
        public function ElementModel()
        {
        }
        
        /**
         * A unique string ID for this element suitable for use in DOMs. 
         */
        public function get elementId():String
        {
            return null;
        }

        override public function initialize():void
        {
            super.initialize();
            classModel.addElementModel(this);
        }
        
        public function get classModel():ClassModel
        {
            var m:SegmentModel = this;
            do
            {
                if (m is ClassModel)
                {
                    return m as ClassModel;
                }
                m = m.parent;
            } while (m != null);
            
            return null;
        }

        /**
         * Increment the execution count for this line, and also set its coverage
         * to 1 if the execution count goes from zero to nonzero, which will ripple
         * that coverage increment up through all the ancestors of this line.
         */
        public function addExecutionCount(n:uint):void
        {
            if (n > 0 && executionCount == 0)
            {
                addCoverage(1);
            }
            executionCount += n;
            dispatchEvent(new Event("executionCountChange"));
        }
        
        protected function addCoverage(n:uint):void
        {
            throw new Error("addCoverage() not overridden");
        }
        
        override public function createChild(element:CoverageElement):SegmentModel
        {
            // Leaf model, don't permit more kids!
            throw new Error("Should never happen!");
        }
        
        override protected function parseXmlElement(xml:XML):void
        {
            addExecutionCount(xml.@count);
        }

        override protected function populateXmlElement(xml:XML):void
        {
            // We don't call super here because a ElementModel is a leaf node and looks different
            xml.@name = name;
            xml.@count = executionCount;
        }
    }
}
