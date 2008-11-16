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
package com.allurent.coverage.model.application
{
	import com.adobe.ac.util.IOneTimeInterval;
	import com.allurent.coverage.event.CoverageEvent;
	import com.allurent.coverage.model.CoverageElement;
	import com.allurent.coverage.model.CoverageElementContainer;
	import com.allurent.coverage.model.ElementModel;
	import com.allurent.coverage.model.ICoverageModel;
	
	import flash.events.EventDispatcher;
	
	import mx.formatters.NumberFormatter;
	
    /** Recording of coverage data started. */
    [Event(name="recordingStart",
            type="com.allurent.coverage.event.CoverageEvent")]
    /** Recording of coverage data ended. */
    [Event(name="recordingEnd",
            type="com.allurent.coverage.event.CoverageEvent")]
    /** Applying recorded coverage data to coverage model starts. */
    [Event(name="parsingStart",
            type="com.allurent.coverage.event.CoverageEvent")]
    /** Applying recorded coverage data to coverage model ends. */
    [Event(name="parsingEnd",
            type="com.allurent.coverage.event.CoverageEvent")]	
	public class Recorder extends EventDispatcher implements IRecorder
	{		
        [Bindable]
        public var isRecording:Boolean;
        [Bindable]
        public var currentRecording:String;
        [Bindable]
        public var autoUpdate:Boolean = true;
        
        public var currentStatusMessage:String;
        
        /**
         * Flag indicating that coverage data should only be recorded internally for
         * coverage elements possessing loaded metadata from compilation.
         */
        public var constrainToModel:Boolean;
		
		private var recordingTimeout:Number;
        private var coverageModel:ICoverageModel;		
        private var coverageElementsMap:Object;
        private var numCoverageElements:uint = 0;		
		private var timer:IOneTimeInterval;
		
		public function Recorder(coverageModel:ICoverageModel, 
		                          timer:IOneTimeInterval)
		{
			this.coverageModel = coverageModel;
            constrainToModel = true;		
			this.timer = timer;
			currentRecording = "";
			coverageElementsMap = {};
			recordingTimeout = 2000;
		}

		public function record(keyMap:Object):void	
		{
            var isEmpty:Boolean = true;
            var element:CoverageElement = null;
            var container:CoverageElementContainer = null;

            for (var key:String in keyMap)
            {
                isEmpty = false;
                var count:uint = keyMap[key];
                container = coverageElementsMap[key];
                if (container == null)
                {
                    element = CoverageElement.fromString(key);
                    if (element != null)
                    {
                        var model:ElementModel = ElementModel(coverageModel.resolveCoverageElement(element, !constrainToModel));
                        container = new CoverageElementContainer(model, count);
                        numCoverageElements++;
                    }
                    else
                    {
                        container = new CoverageElementContainer(null, count);
                    }
                    coverageElementsMap[key] = container;
                }
                else
                {
                    container.count += count;
                }                     
            }

            if (container != null && container.element != null)
            {
                currentRecording = container.element.classModel.name;
            } 
            
            var hasReceivedDataAndHasNotStartedYet : Boolean = (!isEmpty && !isRecording);
            if(hasReceivedDataAndHasNotStartedYet)
            {
                startCoverageRecording();
                trace("Recorder.record startCoverageRecording: ");
            }
            
            if(autoUpdate && !isEmpty)
            {
            	trace("Recorder.record recordingTimeout: " + recordingTimeout);
            	timer.delay(recordingTimeout, handleRecordingTimeout);
            }          
		}
		
        public function applyCoverageData():void
        {
            dispatchEvent(new CoverageEvent(CoverageEvent.PARSING_START));
            for each (var container:CoverageElementContainer in coverageElementsMap)
            {
                if (container.element != null)
                {
                    coverageModel.addExecutionCount(container.element, container.count);
                }
            }
            
            var hasParsed:Boolean = (numCoverageElements > 0);
            trace("Recorder.applyCoverageData ");
            coverageElementsMap = {};
            numCoverageElements = 0;
            currentStatusMessage = "";
            dispatchEvent(new CoverageEvent(CoverageEvent.PARSING_END, null, hasParsed));
        }
		
        private function startCoverageRecording():void
        {
            dispatchEvent(new CoverageEvent(CoverageEvent.RECORDING_START));
            this.isRecording = true;            
        }
        
        public function endCoverageRecording():void
        {
            if (!isRecording)
            {
                return;
            }   	
            
            this.isRecording = false;
            currentRecording = "";
            timer.clear();
            createStatusMessage();
            trace("Recorder.endCoverageRecording recordingTimeout ");
            dispatchEvent(new CoverageEvent(CoverageEvent.RECORDING_END));
        }
        
        private function createStatusMessage():void
        {
            var formatter:NumberFormatter = new NumberFormatter();
            var formattedNumber:String = formatter.format(numCoverageElements);
            
            var timeMessage:String;
            var expectedSeconds:Number = (numCoverageElements / 220000 * 15) + 1;
            if(expectedSeconds < 60)
            {
                timeMessage =  "~" + expectedSeconds.toFixed(1) + " seconds.";
            }
            else
            {
                timeMessage =  "~" + (expectedSeconds / 60).toFixed(0) + " minutes.";
            }
            currentStatusMessage = formattedNumber + " elements. " + timeMessage;
        }
        
        private function handleRecordingTimeout():void
        {
            endCoverageRecording();
        }

	}
}