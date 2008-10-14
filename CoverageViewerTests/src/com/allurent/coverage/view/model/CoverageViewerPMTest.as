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
	import com.allurent.coverage.model.CoverageModel;
	
	import flash.events.InvokeEvent;
	import flash.filesystem.File;
	
	import flexunit.framework.EventfulTestCase;

	public class CoverageViewerPMTest extends EventfulTestCase
	{
		private var model:CoverageViewerPM;
        
		override public function setUp():void
		{
			model = new CoverageViewerPM(new Controller(), 
			                             new OneTimeIntervalStub());
			model.setup();                             
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



        public function testHandleCoverageModelChange():void
        {
        	assertNull("expected no coverageModels", model.coverageModels);
        	var event:CoverageEvent = new CoverageEvent(
        	                               CoverageEvent.COVERAGE_MODEL_CHANGE, 
        	                               CoverageModelData.createCoverageModel()
        	                               );
        	
        	model.controller.dispatchEvent(event);
        	assertNotNull("expected coverageModels", model.coverageModels);
        }
        
        public function testHandleCoverageModelChangeWithEmptyModel():void
        {
        	var empty:CoverageModel = CoverageModelData.createCoverageModel();
        	empty.clear();
            assertNull("expected no coverageModels", model.coverageModels);
            var event:CoverageEvent = new CoverageEvent(
                                           CoverageEvent.COVERAGE_MODEL_CHANGE, 
                                           empty
                                           );
            
            model.controller.dispatchEvent(event);
            assertNull("expected coverageModels", model.coverageModels);
        }
        
        public function testHandleCoverageModelChangeWithoutModel():void
        {
            assertNull("expected no coverageModels", model.coverageModels);
            var event:CoverageEvent = new CoverageEvent(
                                           CoverageEvent.COVERAGE_MODEL_CHANGE, 
                                           null
                                           );
            
            model.controller.dispatchEvent(event);
            assertNull("expected coverageModels", model.coverageModels);
        }  
        
        
        public function testNoMessageOverlayAtStartup():void
        {
            assertFalse("expected no showMessageOverlay", model.showMessageOverlay);            
        }
                
        public function testShowMessageOverlayOnHandlingRecordingEnd():void
        {
            model = new CoverageViewerPM(new Controller(), 
                                         new EmptyOneTimeIntervalStub());        	
        	
            model.setup();
            
            var event:CoverageEvent = new CoverageEvent(
                                           CoverageEvent.RECORDING_END
                                           );
            
            model.controller.dispatchEvent(event);
            
            assertTrue("expected showMessageOverlay", model.showMessageOverlay);
        }	
        
        public function testBlockScreenWhileCommandlineOptionsAreProcessed():void
        {
            model = new CoverageViewerPM(new Controller(),
                                         new EmptyOneTimeIntervalStub());        	

        	//The entry level MXML will dispatch this event.
        	var event:InvokeEvent = new InvokeEvent(InvokeEvent.INVOKE);
        	model.handleInvoke(event);
        	assertTrue("expected showMessageOverlay", model.showMessageOverlay);
        }
        
        public function testIfMessageOverlayIsShownOnFileDragDrop():void
        {
            model = new CoverageViewerPM(new Controller(), 
                                         new EmptyOneTimeIntervalStub());         	
        	
            var event:InvokeEvent = new InvokeEvent(InvokeEvent.INVOKE);
            model.handleDragDrop(new Array(new File()));
            assertTrue("expected showMessageOverlay", model.showMessageOverlay);
        }
        
        public function testIfParsingStartsOnFileDragDrop():void
        {
            model = new CoverageViewerPM(new Controller(), 
                                         new OneTimeIntervalStub());           
            
            var event:InvokeEvent = new InvokeEvent(InvokeEvent.INVOKE);
            
            //in the real world we would drop one or more File types.
            //Here, we test if the expected error has been thrown on the 
            //underlying parser. This tells us that the parser has been invoked.          
            var dropSource:Array = new Array(null);
            try
            {
            	model.handleDragDrop(dropSource);
            	fail("parser is expected to throw a runtime for a null argument");
            }
            catch(error:ArgumentError)
            {
            	
            }    
        }
      
	}
}