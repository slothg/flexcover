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
	import com.adobe.ac.util.EmptyOneTimeIntervalStub;
	import com.adobe.ac.util.IOneTimeInterval;
	import com.adobe.ac.util.service.IReceivingLocalConnection;
	import com.adobe.ac.util.service.ISendingLocalConnection;
	import com.allurent.coverage.runtime.LocalConnectionCoverageAgent;

	public class LocalConnectionCoverageAgentTestSubclass extends LocalConnectionCoverageAgent
	{
        public var coverageDataConnection:ISendingLocalConnection;
        public var ackConnection:IReceivingLocalConnection;
        public var flushTimer:IOneTimeInterval;
        
        public function LocalConnectionCoverageAgentTestSubclass(connectionName:String = null)
        {
        	flushTimer = new EmptyOneTimeIntervalStub();
            super(connectionName);            
        }
        
        override protected function createFlushTimer():IOneTimeInterval
        {
            return flushTimer;
        }
        
        override protected function createCoverageDataConnection():ISendingLocalConnection
        {
            return coverageDataConnection;
        }
        
        override protected function createAckConnection():IReceivingLocalConnection
        {
            return ackConnection;
        }		
		
	}
}