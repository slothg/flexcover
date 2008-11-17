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
package com.allurent.coverage.event
{
    import com.allurent.coverage.model.ICoverageModel;
    
    import flash.events.Event;

    public class CoverageEvent extends Event
    {
        public static const COVERAGE_MODEL_CHANGE:String = "coverageModelChange";
        public static const RECORDING_START:String = "recordingStart";
        public static const RECORDING_END:String = "recordingEnd";
        public static const PARSING_START:String = "parsingStart";
        public static const PARSING_END:String = "parsingEnd";
        
        public var coverageModel:ICoverageModel;
        public var hasParsed:Boolean;
        
        public function CoverageEvent(type:String, 
                                      coverageModel:ICoverageModel=null, 
                                      hasParsed:Boolean=false)
        {
            super(type, true);
            this.coverageModel = coverageModel;
            this.hasParsed = hasParsed;
        }
        
        override public function clone():Event
        {
            return new CoverageEvent(type, coverageModel);
        }
    }
}