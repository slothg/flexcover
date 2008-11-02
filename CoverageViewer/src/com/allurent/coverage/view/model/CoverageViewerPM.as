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
	import com.adobe.ac.util.service.FileBrowser;
	import com.allurent.coverage.IController;
	import com.allurent.coverage.event.CoverageEvent;
	import com.allurent.coverage.event.HeavyOperationEvent;
	import com.allurent.coverage.model.CoverageModelFactory;
	import com.allurent.coverage.model.ICoverageModel;
	import com.allurent.coverage.model.application.CoverageModelManager;
	import com.allurent.coverage.model.application.CoverageModelManagerFactory;
	import com.allurent.coverage.model.application.RecorderFactory;
	import com.allurent.coverage.service.CoverageCommunicatorFactory;
	
	import flash.desktop.ClipboardFormats;
	import flash.events.InvokeEvent;
	import flash.events.NativeDragEvent;
	
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
        public var controller:IController;
        [Bindable]
        public var coverageModels:CoverageModelManager;        
        
        private var _coverageModel:ICoverageModel;
        [Bindable]
        public function get coverageModel():ICoverageModel
        {
        	return _coverageModel;
        }
        public function set coverageModel(value:ICoverageModel):void
        {
    		if(value == null) return;    		
            if(value.isEmpty()) return;
            
            enabled = true;           
            
            _coverageModel = value;
            CoverageModelFactory.instance = value;
            
            CoverageModelManagerFactory.instance = null;
            coverageModels = CoverageModelManagerFactory.instance;
            
            browserPM.setup(coverageModels);
            headerPM.searchPM.setup(coverageModels);
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
        
		public function CoverageViewerPM(controller:IController, 
		                                 timer:IOneTimeInterval)
		{
			this.controller = controller;
			this.timer = timer;
		}
		
		public function setup():void
		{
            controller.setup(CoverageModelFactory.instance, 
                             RecorderFactory.instance, 
                             CoverageCommunicatorFactory.instance);			
            controller.addEventListener(CoverageEvent.COVERAGE_MODEL_CHANGE, 
                                      handleCoverageModelChange);           
            controller.addEventListener(CoverageEvent.RECORDING_END, 
                                        handleRecordingEnd);
            
            headerPM = new HeaderPM(controller, new FileBrowser());
            headerPM.addEventListener(HeavyOperationEvent.EVENT_NAME, 
                                      handleHeavyOperationEvent);
            
            browserPM = new BrowserPM();        
            contentPM = new ContentPM(controller.project);			
		}
	    
        public function handleDragDrop(files:Array):void
        {
	        performHeavyOperation(controller.processFileArgument, [files]);
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
            controller.processCommandLineArguments(event.arguments);
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
        	trace("CoverageViewerPM.parseCoverageData ");
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