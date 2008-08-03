package com.allurent.coverage.model
{
	import com.adobe.ac.util.EmptyOneTimeIntervalStub;
	import com.adobe.ac.util.OneTimeIntervalStub;
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.event.CoverageEvent;
	
	import flexunit.framework.EventfulTestCase;

	public class RecorderTest extends EventfulTestCase
	{
        private var model:Recorder;
        
        override public function setUp():void
        {
        	var controller:Controller = new Controller();
            model = new Recorder(controller, new CoverageModel(), new OneTimeIntervalStub());
        }
        
        public function testNoRecordingAtStartUp():void
        {
            assertFalse(model.isRecording);
            assertEquals("recording status", "", model.currentRecording);
        }
        
        public function testStartRecording():void
        {
            expectEvent(model, CoverageEvent.RECORDING_START);
                  
            model.record(createCoverageKeyMap());
            
            assertExpectedEventsOccurred();
            assertTrue("expected recording to start", model.isRecording);
        }
        
        public function testStartAndStopRecordingWhenEmptyKeyMapIsReceived():void
        {
            testStartRecording();
            
            expectEvent(model, CoverageEvent.RECORDING_END);
            
            var keyMap:Object = new Object();            
            model.record(keyMap);
            
            assertExpectedEventsOccurred();
            assertFalse("expected recording to have stopped", model.isRecording);
        }
        
        public function testStopAndResumeRecording():void
        {
            var controller:Controller = new Controller();
            model = new Recorder(controller, new CoverageModel(), new EmptyOneTimeIntervalStub());            
            
            testStartAndStopRecordingWhenEmptyKeyMapIsReceived();
            testStartRecording();
        }
        
        public function testComputeStatusMessage():void
        {
            testStartAndStopRecordingWhenEmptyKeyMapIsReceived();
            
            assertEquals("3 elements. ~1.0 seconds.", model.currentStatusMessage);
        }   
        
        public function testApplyCoverageData():void
        {
        	model.currentStatusMessage = "some status";
        	
        	expectEvents(model, CoverageEvent.PARSING_START, CoverageEvent.PARSING_END);
        	
        	model.applyCoverageData();
        	
        	assertExpectedEventsOccurred();
        	assertEquals("expected currentStatusMessage to be cleared", "", model.currentStatusMessage);
        }
        
        private function createCoverageKeyMap():Object
        {
            var keyMap:Object = new Object();
            keyMap["com.adobe.net:URI/getQueryByMap@+1130.20"] = 8;
            keyMap["com.adobe.net:URI/setQueryByMap@1204"] = 2;
            keyMap["com.adobe.utils:DateUtil/toW3CDTF@+614.27"] = 4;
            return keyMap;
        }
	}
}