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
package allurent.coverage.runtime
{
	import com.adobe.ac.util.service.LocalConnectionMock;
	
	import flexunit.framework.TestCase;
	
	public class LocalConnectionCoverageAgentTest extends TestCase
	{
		private var agent:LocalConnectionCoverageAgentTestSubclass;
		
		override public function setUp():void
		{
			agent = new LocalConnectionCoverageAgentTestSubclass("_flexcover");
		}
		
        public function testRecordCoverageKeys():void
        {
            //setup mock
            var lc:LocalConnectionMock = new LocalConnectionMock("coverageDataConnection");
            lc.expectedConnectionName = "_flexcover";
            lc.expectedMethodName = "coverageData";
            agent.coverageDataConnection = lc;        	
            var ackLc:LocalConnectionMock = new LocalConnectionMock("ackConnection");
            ackLc.expectedConnectionName = "_flexcover_ack1";
            agent.ackConnection = ackLc;        	
        	
        	agent.recordCoverage("com.adobe.net:URI/getQueryByMap@+1130.20");
        	agent.recordCoverage("com.adobe.net:URI/setQueryByMap@1204");
        	agent.recordCoverage("com.adobe.net:URI/getQueryByMap@+1130.20");
        	
        	agent.flushCoverageData();
        	
        	//currently we don't test the lc payload.
        	lc.expectedParameter1 = lc.actualParameter1; 
        	
        	lc.verify();
        }
        				
        public function testRegistration():void
        {
        	var coverageData:Object = createCoverageKeyMap();
        	//setup mock
        	var lc:LocalConnectionMock = new LocalConnectionMock("coverageDataConnection");
        	lc.expectedConnectionName = "_flexcover";
        	lc.expectedMethodName = "coverageData";
        	lc.expectedParameter1 = null;
        	agent.coverageDataConnection = lc;
        	
            var ackLc:LocalConnectionMock = new LocalConnectionMock("ackConnection");
            ackLc.expectedConnectionName = "_flexcover_ack1";
            agent.ackConnection = ackLc;
            
        	//exersice
        	agent.initializeAgent();
            
            lc.verify();
            ackLc.verify();
        }
        
        public function testSendCoverageDataOnAck():void
        {
            var coverageData:Object = createCoverageKeyMap();
            //setup mock
            var lc:LocalConnectionMock = new LocalConnectionMock("coverageDataConnection");
            lc.expectedConnectionName = "_flexcover";
            lc.expectedMethodName = "coverageData";
            agent.coverageDataConnection = lc;
            
            var ackLc:LocalConnectionMock = new LocalConnectionMock("ackConnection");
            ackLc.expectedConnectionName = "_flexcover_ack1";
            agent.ackConnection = ackLc;
            
            //exersice
            agent.initializeAgent();
            agent.sendCoverageMap(coverageData);
            
            //currently we don't test the lc payload.
            lc.expectedParameter1 = lc.actualParameter1; 
            
            lc.verify();
            ackLc.verify();
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