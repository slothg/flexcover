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
package com.allurent.coverage.view.model
{
	import com.adobe.ac.util.IOneTimeInterval;
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.event.CoverageEvent;
	import com.allurent.coverage.model.CoverageModel;
	import com.allurent.coverage.parse.CommandLineOptionsParser;
	import com.allurent.coverage.parse.FileParser;
	
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	
	public class CoverageViewerPM
	{
		public static const COVERAGE_MEASURE_BRANCH:int = 0;
		public static const COVERAGE_MEASURE_LINE:int = 1;		
				
        [Bindable]
        public var searchPM:SearchPM;
        [Bindable]
        public var contentPM:ContentPM;        
                
        // Top level Controller for the CoverageViewer application
        [Bindable]
        public var controller:Controller;        
         
        private var _coverageModel:CoverageModel;
        [Bindable]
        public function get coverageModel():CoverageModel
        {
        	return _coverageModel;
        }
        public function set coverageModel(value:CoverageModel):void
        {
    		if(value == null) return;
            if(value.isEmpty()) return;
            enabled = true;
            _coverageModel = value;
                   
            searchPM.initialize(coverageModel);
        }
                
        [Bindable]
        public var enabled:Boolean;		
		[Bindable]
		public var showMessageOverlay:Boolean = false;		
		
		private var timer:IOneTimeInterval;		
		private var currentCoverageMeasureIndex:int;		
        
		public function CoverageViewerPM(controller:Controller, 
		                                 timer:IOneTimeInterval)
		{
			this.timer = timer;
			this.controller = controller;
			contentPM = new ContentPM(controller.project);
			searchPM = new SearchPM();
            currentCoverageMeasureIndex = CoverageViewerPM.COVERAGE_MEASURE_BRANCH;   
            controller.addEventListener(CoverageEvent.RECORDING_END, handleRecordingEnd);
		}
		
        public function clearCoverageData():void
        {
            controller.clearCoverageData();
        }
        
        public function canClearCoverageData(enabled:Boolean, 
                                            isCoverageDataCleared:Boolean):Boolean
        {
        	return (enabled && !isCoverageDataCleared);
        }
        
        public function inputFileSelected(e:Event):void
        {
            startProcessFileArgument(File(e.target));
        }
        
        public function outputFileSelected(e:Event):void
        {
            var file:File = File(e.target);
            controller.writeReport(file);
        }
        		
        public function handleDragDrop(files:Array):void
        {
            for each (var f:File in files)
	        {
	        	startProcessFileArgument(f);
	        }
        }
        
        public function hasValidDragInFormat(e:NativeDragEvent):Boolean
        {
        	return e.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT);
        }
        
        /**
         * When the main app window closes, exit the application after first cleaning up.
         *  
         */
        public function onClose():void
        {
            controller.close();
        }
		
        /**
         * When we get our invoke event, process options.  Only then can we attach
         * the LocalConnection (since this is option-dependent). 
         */
        public function handleInvoke(event:InvokeEvent):void
        {
        	showMessageOverlay = true;
            timer.delay(250, performInvokeEvent, event);      
        }
        
        public function performInvokeEvent(event:InvokeEvent):void
        {
            var parser:CommandLineOptionsParser = new CommandLineOptionsParser(controller);
            
            parser.addEventListener(
                CoverageEvent.COVERAGE_MODEL_CHANGE, 
                handleCoverageModelChange);
            
            parser.parse(event.arguments);        	
        }
				
		public function changeCoverageMeasure(index:int):void
		{
			if(isValidCoverageMeasureIndex(index))
			{
				currentCoverageMeasureIndex = index;
				searchPM.currentCoverageMeasureIndex = index;
			}
			else
			{
				throw new Error("Invalid Coverage Measure");
			}
		}
		
        private function handleRecordingEnd(event:CoverageEvent):void
        {
            showMessageOverlay = true;
            timer.delay(500, parseCoverageData);
        }
        
        private function parseCoverageData():void
        {
            controller.applyCoverageData();
            showMessageOverlay = false;
        }		
		
		private function isValidCoverageMeasureIndex(index:int):Boolean
		{
			return (currentCoverageMeasureIndex == CoverageViewerPM.COVERAGE_MEASURE_BRANCH
					|| currentCoverageMeasureIndex == CoverageViewerPM.COVERAGE_MEASURE_LINE);
		}
		
        private function startProcessFileArgument(file:File):void
        {
        	showMessageOverlay = true;
        	timer.delay(250, processFileArgument, file);	
        }
        
        private function processFileArgument(file:File):void
        {
            var parser:FileParser = new FileParser(controller);
            parser.addEventListener(
                            CoverageEvent.COVERAGE_MODEL_CHANGE, 
                            handleCoverageModelChange);
            parser.parse(file);            	
        }
        
        private function handleCoverageModelChange(event:CoverageEvent):void
		{
			coverageModel = event.coverageModel;
			showMessageOverlay = false;
		}	
	}
}