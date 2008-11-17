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
	import com.adobe.ac.util.service.LocalConnectionMock;
	
	import flash.events.SecurityErrorEvent;
	
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
            var lc:LocalConnectionMock = new LocalConnectionMock(false);
            lc.mock.method("addEventListener").withAnyArgs.times(3);
            lc.mock.method("send").withArgs("_flexcover", "coverageData", null, 0).once;
            lc.mock.method("send").withAnyArgs.once;
            agent.coverageDataConnection = lc;
            
            var ackLc:LocalConnectionMock = new LocalConnectionMock(true);
            ackLc.mock.method("allowDomain").withArgs("*").once;
            ackLc.mock.property("client").withArgs(agent).once;
            ackLc.mock.method("connect").withArgs("_flexcover_ack1").once;
            agent.ackConnection = ackLc;
            
            agent.recordCoverage("com.adobe.net:URI/getQueryByMap@+1130.20");
            agent.recordCoverage("com.adobe.net:URI/setQueryByMap@1204");
            agent.recordCoverage("com.adobe.net:URI/getQueryByMap@+1130.20");
            
            agent.flushCoverageData();
            
            lc.mock.verify();
            ackLc.mock.verify();
        }
        
        public function testRegistration():void
        {
            var coverageData:Object = createCoverageKeyMap();
            //setup mock
            var lc:LocalConnectionMock = new LocalConnectionMock(false);
            lc.mock.method("addEventListener").withAnyArgs.times(3);
            lc.mock.method("send").withArgs("_flexcover", "coverageData", null, 0).once;
            agent.coverageDataConnection = lc;            
            
            var ackLc:LocalConnectionMock = new LocalConnectionMock();
            ackLc.mock.method("connect").withArgs("_flexcover_ack1").once;
            agent.ackConnection = ackLc;
            
            //exersice
            agent.initializeAgent();
            
            lc.mock.verify();
            ackLc.mock.verify();
        }
        
        public function testSendCoverageDataOnAck():void
        {
            var coverageData:Object = createCoverageKeyMap();
            //setup mock
            var lc:LocalConnectionMock = new LocalConnectionMock();
            lc.mock.method("send").withAnyArgs.once;
            agent.coverageDataConnection = lc;
            
            var ackLc:LocalConnectionMock = new LocalConnectionMock();
            ackLc.mock.method("connect").withArgs("_flexcover_ack1").once;
            agent.ackConnection = ackLc;
            
            //exersice
            agent.initializeAgent();
            agent.sendCoverageMap(coverageData);
            
            lc.mock.verify();
            ackLc.mock.verify();
        }
        
        public function testCannotSendWithoutViewerPermission():void
        {
            var coverageData:Object = createCoverageKeyMap();
            //setup mock
            var lc:LocalConnectionMock = new LocalConnectionMock();
            agent.coverageDataConnection = lc;
            
            var ackLc:LocalConnectionMock = new LocalConnectionMock();
            agent.ackConnection = ackLc;
            
            //exersice
            agent.initializeAgent();
            agent.sendCoverageMap(coverageData);
            
            lc.mock.method("send").withAnyArgs.never;
            
            agent.sendCoverageMap(coverageData);
            
            lc.mock.verify();
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