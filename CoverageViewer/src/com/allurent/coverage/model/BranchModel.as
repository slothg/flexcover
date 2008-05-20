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
    public class BranchModel extends ElementModel
    {
        /** Type of branch: "+" or "-" */
        public var symbol:String;
        
        /** Line number -- if a transformed file, this will be the original line. */
        public var line:int;
        
        /** Column number -- if a transformed file, this will always be -1. */
        public var column:int;
        
        /** sort key for sorting branches that occur at the same column. */
        public var sortKey:Number;
        
        /**
         * Construct a new BranchModel. 
         */
        public function BranchModel()
        {
        }

        override public function initialize():void
        {
            symbol = name.charAt(0);

            var hashIndex:int = name.indexOf("#");
            var transformedLine:int = -1;
            var lineColumn:String;
            if (hashIndex >= 0)
            {
                transformedLine = parseInt(name.substring(1, hashIndex));
                lineColumn = name.substring(hashIndex + 1);
            }
            else
            {
                lineColumn = name;
            }
            
            var dotIndex:int = lineColumn.indexOf(".");
            line = parseInt(lineColumn.substring(1, dotIndex));
            column = parseInt(lineColumn.substring(dotIndex + 1));
            
            var symbolValue:Number = (symbol == "+") ? 0 : 0.5;
            if (transformedLine >= 0)
            {
                // In a transformed file, the column appears to be 1, while the sortKey
                // reflects the line and column in the original file. 
                sortKey = (line * 1000) + column + symbolValue;
                line = transformedLine;
                column = -1;
            }
            else
            {
                sortKey = column + symbolValue;
            }

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
