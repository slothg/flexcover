package com.allurent.coverage.parse
{
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.event.CoverageModelEvent;
	import com.allurent.coverage.model.CoverageModel;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;

	[Event(name="coverageModelChange",
			type="com.allurent.coverage.event.CoverageModelEvent")]
	public class FileParser extends EventDispatcher
	{
		private var controller:Controller;

		public function FileParser(controller:Controller)
		{
			this.controller = controller;
		}		
		
        public function parse(f:File):void
        {
            if (f.name.match(/\.cvm$/))
            {
                controller.loadMetadata(f);
                dispatchCoverageModelChange(controller.coverageModel);
            }
            else if (f.name.match(/\.cvr/))
            {
                controller.loadCoverageReport(f);
                dispatchCoverageModelChange(controller.coverageModel);
            }
        }
        
        private function dispatchCoverageModelChange(model:CoverageModel):void
        {
            dispatchEvent(new CoverageModelEvent(
            						CoverageModelEvent.COVERAGE_MODEL_CHANGE, 
            						model));        	
        }
	}
}