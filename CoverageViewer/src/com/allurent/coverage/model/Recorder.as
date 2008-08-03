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
	public class Recorder extends EventDispatcher
	{
        [Bindable]
        public var isRecording:Boolean;		
        [Bindable]
        public var currentRecording:String;	   
        /**
         * Flag indicating that coverage data should only be recorded internally for
         * coverage elements possessing loaded metadata from compilation.
         */
        public var constrainToModel:Boolean;             
		public var currentStatusMessage:String;
		
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
		}

		public function record(keyMap:Object):void	
		{
            var isRecording:Boolean = false;
            
            for (var key:String in keyMap)
            {
                isRecording = true;
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
                timer.delay(4000, handleRecordingTimeout);
            }
            
            if(isRecording && !this.isRecording)
            {
                startCoverageRecording();
            }
            else if(!isRecording && this.isRecording)
            {
                endCoverageRecording();
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