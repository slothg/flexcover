package com.allurent.coverage.view.model
{
	import com.adobe.ac.util.OneTimeIntervalStub;
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.event.HeavyOperationEvent;
	
	import flash.filesystem.File;
	
	import flexunit.framework.EventfulTestCase;

	public class HeaderPMTest extends EventfulTestCase
	{
		private var model:HeaderPM;
		
		override public function setUp():void
		{
			model = new HeaderPM(new Controller(new OneTimeIntervalStub()));
		}
		
		public function testInputFileSelected():void
		{
			expectEvent(model, HeavyOperationEvent.EVENT_NAME);
			model.inputFilesSelected([new File(), new File()]);
			assertExpectedEventsOccurred();
		}
		
        public function testClearCoverageData():void
        {
            model.controller.isCoverageDataCleared = false;
            model.clearCoverageData();
            assertTrue("expected controller to be cleared", model.controller.isCoverageDataCleared);
        }
		
		public function testCanClearCoverageData():void
		{
			assertFalse("0", model.canClearCoverageData(false, false));
			assertFalse("1", model.canClearCoverageData(false, true));
            assertTrue("2", model.canClearCoverageData(true, false));
            assertFalse("3", model.canClearCoverageData(true, true));			
		}
	}
}