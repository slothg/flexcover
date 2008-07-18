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
package tests.com.allurent.coverage
{
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.event.CoverageEvent;
	
	import flexunit.framework.EventfulTestCase;
	
	import tests.com.adobe.ac.util.EmptyOneTimeIntervalStub;
	import tests.com.adobe.ac.util.OneTimeIntervalStub;
	
	public class ControllerTest extends EventfulTestCase
	{
		private var controller:Controller;
		
		override public function setUp():void
		{
			controller = Controller.instance;
			controller.timer = new OneTimeIntervalStub();
		}
		
        override public function tearDown():void
        {
        	Controller.resetForTesting();        	
        }	
		
        public function testNoRecordingOnStartup():void
        {
        	assertFalse("expected no recording", controller.isRecording);
        }
        
        public function testStartRecording():void
        {
        	expectEvent(controller, CoverageEvent.RECORDING_START);
        	
        	var keyMap:Object = new Object();
        	keyMap[1] = new Object();
        	keyMap[2] = new Object();        	
        	controller.coverageData(keyMap);
        	
        	assertExpectedEventsOccurred();
        	assertTrue("expected recording to start", controller.isRecording);
        }
        
        public function testStopRecording():void
        {
            testStartRecording();
            
            expectEvent(controller, CoverageEvent.RECORDING_END);
            
            var keyMap:Object = new Object();            
            controller.coverageData(keyMap);
            
            assertExpectedEventsOccurred();
            assertFalse("expected recording to have stopped", controller.isRecording);
        }
        
        public function testStartAndResumeRecording():void
        {
        	controller.timer = new EmptyOneTimeIntervalStub();
            testStopRecording();
            testStartRecording();
        }        
	}
}