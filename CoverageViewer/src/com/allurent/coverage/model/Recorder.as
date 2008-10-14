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
	import com.adobe.ac.util.IOneTimeInterval;
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.event.CoverageEvent;
	
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
        public var currentStatusMessage:String;
        
        /**
         * Flag indicating that coverage data should only be recorded internally for
         * coverage elements possessing loaded metadata from compilation.
         */
        public var constrainToModel:Boolean;
		
		private var recordingTimeout:Number;
		private var controller:Controller;
        private var coverageModel:CoverageModel;		
        private var coverageElementsContainer:Array;		
		private var timer:IOneTimeInterval;
		
		public function Recorder(controller:Controller, 
		                          coverageModel:CoverageModel, 
		                          timer:IOneTimeInterval)
		{
			this.controller = controller;
			this.coverageModel = coverageModel;
            constrainToModel = true;		
			this.timer = timer;
			currentRecording = "";
			coverageElementsContainer = new Array();
			recordingTimeout = 2000;
		}

		public function record(keyMap:Object):void	
		{
            var isEmpty:Boolean = true;
            
            for (var key:String in keyMap)
            {
                isEmpty = false;
                var element:CoverageElement = CoverageElement.fromString(key);
                if (element != null)
                {
                    var count:uint = keyMap[key];
                    currentRecording = element.packageName + "." + element.className;
                    
                    coverageElementsContainer.push(
                        new CoverageElementContainer(
                            ElementModel(coverageModel.resolveCoverageElement(element, !constrainToModel)), 
                            count));                     
                }
            }
            
            var hasReceivedDataAndHasNotStartedYet : Boolean = (!isEmpty && !isRecording);
            if(hasReceivedDataAndHasNotStartedYet)
            {
                startCoverageRecording();
            }
            
            if(!isEmpty)
            {
            	timer.delay(recordingTimeout, handleRecordingTimeout);
            }          
		}
		
        public function applyCoverageData():void
        {
            dispatchEvent(new CoverageEvent(CoverageEvent.PARSING_START));          
            var container:Array = coverageElementsContainer;
            var numberOfContainers:int = container.length;
            for(var i:int; i < numberOfContainers; i++)
            {
                var item:CoverageElementContainer = CoverageElementContainer(container[i]);
                coverageModel.addExecutionCount(item.element, item.count);
            }
            
            if(numberOfContainers > 0)
            {
                controller.isCoverageDataCleared = false;
            }
            
            coverageElementsContainer = new Array();
            currentStatusMessage = "";
            dispatchEvent(new CoverageEvent(CoverageEvent.PARSING_END));
        }
		
        private function startCoverageRecording():void
        {
            dispatchEvent(new CoverageEvent(CoverageEvent.RECORDING_START));
            this.isRecording = true;            
        }
        
        private function endCoverageRecording():void
        {
            this.isRecording = false;
            currentRecording = "";
            timer.clear();
            createStatusMessage();
            dispatchEvent(new CoverageEvent(CoverageEvent.RECORDING_END));
        }
        
        private function createStatusMessage():void
        {
            var numberOfElements:int = coverageElementsContainer.length;
            var formatter:NumberFormatter = new NumberFormatter();
            var formattedNumber:String = formatter.format(numberOfElements);
            
            var timeMessage:String;
            var expectedSeconds:Number = (numberOfElements / 220000 * 15) + 1;
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