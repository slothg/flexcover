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
package com.allurent.coverage.view.model
{
	import com.adobe.ac.util.EmptyOneTimeIntervalStub;
	import com.adobe.ac.util.OneTimeIntervalStub;
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.CoverageModelData;
	import com.allurent.coverage.event.CoverageEvent;
	
	import flash.events.InvokeEvent;
	import flash.filesystem.File;
	
	import flexunit.framework.EventfulTestCase;

	public class CoverageViewerPMTest extends EventfulTestCase
	{
		private var model:CoverageViewerPM;
        
		override public function setUp():void
		{
			model = new CoverageViewerPM(new Controller(new OneTimeIntervalStub()), 
			                             new OneTimeIntervalStub());
		}

        public function testInitializeCoverageManager():void
        {
        	assertNull("expected no coverageModels", model.coverageModels);
        	var event:CoverageEvent = new CoverageEvent(
        	                               CoverageEvent.COVERAGE_MODEL_CHANGE, 
        	                               CoverageModelData.createCoverageModel()
        	                               );
        	
        	model.headerPM.dispatchEvent(event);
        	assertNotNull("expected coverageModels", model.coverageModels);
        }
		
		public function testIfHeaderGetsEnabled():void
		{
			model.enabled = true;
			assertTrue("expected enabled", model.headerPM.enabled);
		}
		
        public function testIfBrowserGetsEnabled():void
        {
            model.enabled = true;
            assertTrue("expected enabled", model.browserPM.enabled);
        }
        
        public function testNoMessageOverlayAtStartup():void
        {
            assertFalse("expected no showMessageOverlay", model.showMessageOverlay);        	
        }
        
        public function testHandleInvokeEvent():void
        {
            model = new CoverageViewerPM(new Controller(new OneTimeIntervalStub()), 
                                         new EmptyOneTimeIntervalStub());        	
        	  	
        	var event:InvokeEvent = new InvokeEvent(InvokeEvent.INVOKE);
        	model.handleInvoke(event);
        	assertTrue("expected showMessageOverlay", model.showMessageOverlay);
        }
        
        public function testHandleDragDrop():void
        {
            model = new CoverageViewerPM(new Controller(new OneTimeIntervalStub()), 
                                         new EmptyOneTimeIntervalStub());         	
        	
            var event:InvokeEvent = new InvokeEvent(InvokeEvent.INVOKE);
            model.handleDragDrop(new Array(new File()));
            assertTrue("expected showMessageOverlay", model.showMessageOverlay);
        }
	}
}