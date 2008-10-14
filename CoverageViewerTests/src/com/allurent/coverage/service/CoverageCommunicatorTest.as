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
package com.allurent.coverage.service
{
	import com.adobe.ac.util.service.LocalConnectionMock;
	import com.allurent.coverage.event.CoverageEvent;
	import com.allurent.coverage.model.IRecorder;
	import com.allurent.coverage.model.RecorderMock;
	
	import flexunit.framework.TestCase;

	public class CoverageCommunicatorTest extends TestCase
	{
		private var model:CoverageCommunicatorTestSubclass;
		
		override public function setUp():void
		{
            var recorder:IRecorder = new RecorderMock();
            model = new CoverageCommunicatorTestSubclass(recorder);
		}
		
		public function testAttachConnectionWithDefaultConnectionName():void
		{
            //setup mock
            var lc:LocalConnectionMock = new LocalConnectionMock("coverageDataConnection");
            lc.expectedConnectionName = "_flexcover";
			model.coverageDataConnection = lc;
            
			//exercise
			model.attachConnection();
			
			lc.verify();
		}
		
        public function testAttachConnectionWithCustomConnectionName():void
        {
            //setup mock
            var lc:LocalConnectionMock = new LocalConnectionMock("coverageDataConnection");
            lc.expectedConnectionName = "foo";
            model.coverageDataConnection = lc;
            
            //exercise
            model.coverageDataConnectionName = "foo";
            model.attachConnection();
            
            lc.verify();
        }
        
        public function testRegistrationOfSingleAgent():void
        {
            var recorder:RecorderMock = new RecorderMock();            
            model = new CoverageCommunicatorTestSubclass(recorder);        	

        	//setup mock
        	var lc:LocalConnectionMock = new LocalConnectionMock("ackConnection");
        	lc.expectedConnectionName = "_flexcover_ack1";
        	lc.expectedMethodName = "coverageReceived";
        	model.ackConnection = lc;        	
        	model.coverageDataConnection = new LocalConnectionMock();
        	
        	//exercise
        	model.attachConnection();
        	model.coverageData(null);
        	
        	lc.verify();
        	assertFalse("isRecordCalled", recorder.isRecordCalled);
        }
        
        public function testRecordCoverageDataFromSingleAgent():void
        {
        	var coverageData:Object = createCoverageKeyMap();        	
            var recorder:RecorderMock = new RecorderMock();
            
            recorder.expectedKeyMap = coverageData;         
            
            model = new CoverageCommunicatorTestSubclass(recorder);         
            
            //setup mock
            var lc:LocalConnectionMock = new LocalConnectionMock("ackConnection");
            lc.expectedConnectionName = "_flexcover_ack1";
            lc.expectedMethodName = "coverageReceived";
            model.ackConnection = lc;
            
            var lc2:LocalConnectionMock = new LocalConnectionMock("coverageDataConnection");
            lc2.expectedConnectionName = "_flexcover";
            model.coverageDataConnection = lc2;
            
            //exercise
            model.attachConnection();
            model.coverageData(null);
            model.coverageData(coverageData);
            
            lc.verify();
            lc2.verify();
            assertTrue("isRecordCalled", recorder.isRecordCalled);
            recorder.verify();
        }
        
        public function testRegistrationOfSecondAgent():void
        {
            var recorder:RecorderMock = new RecorderMock();            
            model = new CoverageCommunicatorTestSubclass(recorder);         

            //setup mock
            var lc:LocalConnectionMock = new LocalConnectionMock("ackConnection");
            lc.expectedConnectionName = "_flexcover_ack2";
            lc.expectedMethodName = "coverageReceived";
            model.ackConnection = lc;
            model.coverageDataConnection = new LocalConnectionMock();
            
            //exercise
            model.attachConnection();
            model.coverageData(null);
            model.coverageData(null);
            
            lc.verify();
            assertFalse("isRecordCalled", recorder.isRecordCalled);
        } 
        
        public function testRecordCoverageDataFromSecondAgent():void
        {
            var coverageData:Object = createCoverageKeyMap();           
            var recorder:RecorderMock = new RecorderMock();
            
            recorder.expectedKeyMap = coverageData;         
            
            model = new CoverageCommunicatorTestSubclass(recorder);         
            
            //setup mock
            var lc:LocalConnectionMock = new LocalConnectionMock("ackConnection");
            lc.expectedConnectionName = "_flexcover_ack2";
            lc.expectedMethodName = "coverageReceived";
            model.ackConnection = lc;
            
            var lc2:LocalConnectionMock = new LocalConnectionMock("coverageDataConnection");
            lc2.expectedConnectionName = "_flexcover";
            model.coverageDataConnection = lc2;
            
            //exercise
            model.attachConnection();
            model.coverageData(null);
            model.coverageData(null);
            model.coverageData(coverageData);
            model.coverageData(coverageData);
            
            lc.verify();
            lc2.verify();            
            assertTrue("isRecordCalled", recorder.isRecordCalled);
            recorder.verify();
        }  
        
        public function testStopRecordingWhenRecorderStartsParsing():void
        {
            var coverageData:Object = createCoverageKeyMap();           
            var recorder:RecorderMock = new RecorderMock();
            
            recorder.expectedKeyMap = coverageData;         
            
            model = new CoverageCommunicatorTestSubclass(recorder);         
            
            //setup mock
            var lc:LocalConnectionMock = new LocalConnectionMock("ackConnection");
            model.ackConnection = lc;
           
            model.coverageDataConnection = new LocalConnectionMock("coverageDataConnection");
            
            //exercise
            model.attachConnection();
            recorder.dispatchEvent(new CoverageEvent(CoverageEvent.RECORDING_END));
            model.coverageData(coverageData);
            
            lc.verify();
            assertTrue("isRecordCalled", recorder.isRecordCalled);
        }
        
        public function testResumeRecordingWhenRecorderStopsParsing():void
        {
            var coverageData:Object = createCoverageKeyMap();           
            var recorder:RecorderMock = new RecorderMock();
            
            recorder.expectedKeyMap = coverageData;         
            
            model = new CoverageCommunicatorTestSubclass(recorder);         
            
            //setup mock
            var lc:LocalConnectionMock = new LocalConnectionMock("ackConnection");
            lc.expectedConnectionName = "_flexcover_ack1";
            lc.expectedMethodName = "coverageReceived";            
            model.ackConnection = lc;
            
            model.coverageDataConnection = new LocalConnectionMock("coverageDataConnection");
            
            //exercise
            model.attachConnection();
            model.coverageData(null);
            recorder.dispatchEvent(new CoverageEvent(CoverageEvent.RECORDING_END));
            model.coverageData(coverageData);     
            recorder.dispatchEvent(new CoverageEvent(CoverageEvent.PARSING_END));

            lc.verify();
            assertTrue("isRecordCalled", recorder.isRecordCalled);   	
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