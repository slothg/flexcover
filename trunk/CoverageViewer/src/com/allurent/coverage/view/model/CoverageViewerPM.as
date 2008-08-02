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
	import com.allurent.coverage.event.HeavyOperationEvent;
	import com.allurent.coverage.model.CoverageModel;
	import com.allurent.coverage.model.CoverageModelManager;
	import com.allurent.coverage.parse.CommandLineOptionsParser;
	
	import flash.desktop.ClipboardFormats;
	import flash.events.InvokeEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	
	import mx.events.IndexChangedEvent;
	
	public class CoverageViewerPM
	{	    
	    [Bindable]
        public var headerPM:HeaderPM;
        [Bindable]
        public var browserPM:BrowserPM;        
        [Bindable]
        public var contentPM:ContentPM;
        
        // Top level Controller for the CoverageViewer application
        [Bindable]
        public var controller:Controller;
        [Bindable]
        public var coverageModels:CoverageModelManager;        
        
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
            
            coverageModels = new CoverageModelManager(coverageModel);            
            browserPM.initialize(coverageModels);
            headerPM.searchPM.initialize(coverageModels);
        }
        
        private var _enabled:Boolean;
        [Bindable]
        public function get enabled():Boolean
        {
            return _enabled;
        }
        public function set enabled(value:Boolean):void
        {
        	_enabled = value;
            headerPM.enabled = value;
            browserPM.enabled = value;
        }
        
		[Bindable]
		public var showMessageOverlay:Boolean = false;		
		
		private var timer:IOneTimeInterval;

		public function CoverageViewerPM(controller:Controller, 
		                                 timer:IOneTimeInterval)
		{
			this.controller = controller;
            controller.addEventListener(CoverageEvent.RECORDING_END, 
                                        handleRecordingEnd);			
			this.timer = timer;			
			
            headerPM = new HeaderPM(controller);
            headerPM.addEventListener(HeavyOperationEvent.EVENT_NAME, 
                                      handleHeavyOperationEvent);
            headerPM.addEventListener(CoverageEvent.COVERAGE_MODEL_CHANGE, 
                                      handleCoverageModelChange);
			
			browserPM = new BrowserPM();        
			contentPM = new ContentPM(controller.project);
		}
	    
        public function handleDragDrop(files:Array):void
        {
	        performHeavyOperation(headerPM.processFileArgument, [files]);
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
            performHeavyOperation(performInvokeEvent, [event]);  
        }
        
        public function performInvokeEvent(event:InvokeEvent):void
        {
            var parser:CommandLineOptionsParser = new CommandLineOptionsParser(controller);
            
            parser.addEventListener(
                CoverageEvent.COVERAGE_MODEL_CHANGE, 
                handleCoverageModelChange);
            
            parser.parse(event.arguments);        	
        }
		
        private function performHeavyOperation(callback:Function, 
                                               parameters:Array = null):void
        {
	        handleHeavyOperationEvent(new HeavyOperationEvent( 
	                                          callback, 
	                                          parameters));
        }
        
        private function handleHeavyOperationEvent(event:HeavyOperationEvent):void
        {
            showMessageOverlay = true;
            timer.delay(500, event.execute);
        }
		
        private function handleRecordingEnd(event:CoverageEvent):void
        {
        	performHeavyOperation(parseCoverageData);
        }
        
        private function parseCoverageData():void
        {
            controller.applyCoverageData();
            showMessageOverlay = false;
        }	
        
        private function handleCoverageModelChange(event:CoverageEvent):void
		{
			coverageModel = event.coverageModel;
			showMessageOverlay = false;
		}	
	}
}