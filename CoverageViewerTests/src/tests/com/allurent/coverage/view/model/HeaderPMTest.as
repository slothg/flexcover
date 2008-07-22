package tests.com.allurent.coverage.view.model
{
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.event.HeavyOperationEvent;
	import com.allurent.coverage.view.model.HeaderPM;
	
	import flash.filesystem.File;
	
	import flexunit.framework.EventfulTestCase;
	
	import tests.com.adobe.ac.util.OneTimeIntervalStub;

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
			model.inputFileSelected(new File());
			assertExpectedEventsOccurred();
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