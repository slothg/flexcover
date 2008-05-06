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
     * Model for a single executable branch within the application. 
     */
    [Bindable]
    public class BranchModel extends ElementModel
    {
        public var symbol:String;
        public var line:int;
        public var column:int;
        
        /**
         * Construct a new BranchModel. 
         */
        public function BranchModel()
        {
        }

        override public function initialize():void
        {
            symbol = name.charAt(0);
            var dotIndex:int = name.indexOf(".");
            line = parseInt(name.substring(1, dotIndex));
            column = parseInt(name.substring(dotIndex + 1));

            super.initialize();
            addBranches(1);
        }
        
        override public function get elementId():String
        {
            return "line" + line;
        }

        override protected function addCoverage(n:uint):void
        {
            addBranchCoverage(n);
        }
        
        override protected function createXmlElement():XML
        {
            return <branch/>;
        }
    }
}
