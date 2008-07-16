package com.allurent.coverage.view.model
{
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.event.CoverageModelEvent;
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
        	if(value.isEmpty()) return;
        	enabled = true;
        	_coverageModel = value;
        	
        	searchPM.initialize(coverageModel);
        }
                
        [Bindable]
        public var enabled:Boolean;		
		[Bindable]
		public var showMessageOverlay:Boolean = false;
		
		private var currentCoverageMeasureIndex:int;
				
		public function CoverageViewerPM(controller:Controller)
		{
			this.controller = controller;
			contentPM = new ContentPM(controller.project);
			searchPM = new SearchPM();  
            currentCoverageMeasureIndex = CoverageViewerPM.COVERAGE_MEASURE_BRANCH;
		}
		
        public function inputFileSelected(e:Event):void
        {
            processFileArgument(File(e.target));
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
	        	processFileArgument(f);
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
        public function handleInvoke(e:InvokeEvent):void
        {
            var parser:CommandLineOptionsParser = new CommandLineOptionsParser(controller);
            
            parser.addEventListener(
				CoverageModelEvent.COVERAGE_MODEL_CHANGE, 
				handleCoverageModelChange);
			
			parser.parse(e.arguments);            
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
		
		private function isValidCoverageMeasureIndex(index:int):Boolean
		{
			return (currentCoverageMeasureIndex == CoverageViewerPM.COVERAGE_MEASURE_BRANCH
					|| currentCoverageMeasureIndex == CoverageViewerPM.COVERAGE_MEASURE_LINE);
		}
		
        private function processFileArgument(file:File):void
        {
        	var parser:FileParser = new FileParser(controller);
        	parser.addEventListener(
        					CoverageModelEvent.COVERAGE_MODEL_CHANGE, 
        					handleCoverageModelChange);
        	parser.parse(file);         	
        }
        
        private function handleCoverageModelChange(event:CoverageModelEvent):void
		{
			coverageModel = event.coverageModel;
		}	
	}
}