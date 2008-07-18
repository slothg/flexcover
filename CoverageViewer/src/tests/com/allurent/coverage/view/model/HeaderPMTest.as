package tests.com.allurent.coverage.view.model
{
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.event.HeavyOperationEvent;
	import com.allurent.coverage.view.model.HeaderPM;
	
	import flash.filesystem.File;
	
	import flexunit.framework.EventfulTestCase;
	import flash.events.Event;

	public class HeaderPMTest extends EventfulTestCase
	{
		private var model:HeaderPM;
		
		override public function setUp():void
		{
			model = new HeaderPM(Controller.instance);
		}
		
		public function testInputFileSelected():void
		{
			expectEvent(model, HeavyOperationEvent.EVENT_NAME);
			model.inputFileSelected(new File());
			assertExpectedEventsOccurred();
		}
	}
}