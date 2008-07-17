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
package com.allurent.coverage.parse
{
    import com.allurent.coverage.model.CoverageElement;
    import com.allurent.coverage.model.CoverageModel;
    import com.allurent.coverage.model.ProjectModel;
   // import com.allurent.coverage.runtime.TraceCoverageAgent;
    
    /**
     * This parser processes a runtime-generated trace log file that contains
     * a single CoverageElement per line plus an execution count.
     */
    public class TraceLogParser extends Parser
    {
        public function TraceLogParser(coverageModel:CoverageModel, project:ProjectModel)
        {
            super(coverageModel, project);
        }
        
        /**
         * Parse coverage metadata. 
         */
        override public function parseContents(data:String):void
        {
        	/*
            var prefixLen:uint = TraceCoverageAgent.COVERAGE_TRACE_PREFIX.length;
            var lines:Array = data.split("\n");
            for each (var line:String in lines)
            {
                if (line.substring(0, prefixLen) == TraceCoverageAgent.COVERAGE_TRACE_PREFIX)
                {
                    line = line.substring(prefixLen);
                    var spaceIndex:int = line.indexOf(" ");
                    if (spaceIndex > 0)
                    {
                        var element:CoverageElement = CoverageElement.fromString(line.substring(0, spaceIndex));
                        var count:Number = parseInt(line.substring(spaceIndex+1));
                        if (!isNaN(count))
                        {
                            coverageModel.recordCoverageElement(element, count, true)
                        }
                    }
                }
            }
            */
        }
    }
}
