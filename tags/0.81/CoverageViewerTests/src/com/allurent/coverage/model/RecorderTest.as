package com.allurent.coverage.model
{
	import com.adobe.ac.util.EmptyOneTimeIntervalStub;
	import com.adobe.ac.util.OneTimeIntervalStub;
	import com.allurent.coverage.event.CoverageEvent;
	import com.allurent.coverage.model.application.Recorder;
	
	import flexunit.framework.EventfulTestCase;

	public class RecorderTest extends EventfulTestCase
	{
        private var model:Recorder;
        
        override public function setUp():void
        {
        	createFixtureWithEmptyOneTimeInterval();
        }
        
        private function createFixtureWithEmptyOneTimeInterval():void
        {
        	//this fixture will prevent a timeout.
            model = new Recorder(new CoverageModel(), new EmptyOneTimeIntervalStub());           
        }
        
        private function createFixtureWithOneTimeInterval():void
        {
        	//this fixture will force a timeout.
            model = new Recorder( new CoverageModel(), new OneTimeIntervalStub());           
        }                
        
        public function testNoRecordingAtStartUp():void
        {
            assertFalse(model.isRecording);
            assertEquals("recording status", "", model.currentRecording);
        }
        
        public function testStartRecording():void
        {
            listenForEvent(model, CoverageEvent.RECORDING_START);
            
            model.record(createCoverageKeyMap());
            
            assertEvents();
            assertTrue("expected recording to start", model.isRecording);
        }
        
        public function testStopRecordingOnTimeout():void
        {
        	createFixtureWithOneTimeInterval();
        	        	
        	listenForEvent(model, CoverageEvent.RECORDING_END);
            
            model.record(createCoverageKeyMap());
            
            assertEvents();
            assertFalse("expected recording to have stopped", model.isRecording);
        }
        
        public function testStopAndResumeRecording():void
        {
            testStopRecordingOnTimeout();            
            createFixtureWithEmptyOneTimeInterval();
            testStartRecording();
        }
        
        public function testComputeStatusMessage():void
        {
            testStopRecordingOnTimeout();
            
            assertEquals("3 elements. ~1.0 seconds.", model.currentStatusMessage);
        }   
        
        public function testApplyCoverageData():void
        {
        	model.currentStatusMessage = "some status";
        	
        	listenForEvent(model, CoverageEvent.PARSING_START);
        	listenForEvent(model, CoverageEvent.PARSING_END);
        	
        	model.applyCoverageData();
        	
        	assertEvents();
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