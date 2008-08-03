package com.allurent.coverage.view.model
{
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.event.CoverageEvent;
	import com.allurent.coverage.event.HeavyOperationEvent;
	import com.allurent.coverage.parse.FileParser;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
    /** This event is dispatched when the coverage model is updated with new metadata. */
    [Event(name="coverageModelChange",
            type="com.allurent.coverage.event.CoverageEvent")]
    /** Parsing of coverage data (i.e. cvm, cvr files) starts */
    [Event(name="heavyOperationEvent",
            type="com.allurent.coverage.event.HeavyOperationEvent")]            
	public class HeaderPM extends EventDispatcher
	{
        [Bindable]
        public var controller:Controller;
        [Bindable]
        public var searchPM:SearchPM;
        
        [Bindable]
        public var enabled:Boolean;          
		
		public function HeaderPM(controller:Controller)
		{
			this.controller = controller;			
			searchPM = new SearchPM();			
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
        
        public function inputFilesSelected(files:Array):void
        {
            dispatchEvent(new HeavyOperationEvent(controller.processFileArgument, 
						                          [files]));
        }
        
        public function outputFileSelected(file:File):void
        {
            controller.writeReport(file);
        }
	}
}