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
package com.allurent.coverage.model
{
	import com.allurent.coverage.CoverageModelData;
	import com.allurent.coverage.model.search.ISearchable;
	
	import flexunit.framework.EventfulTestCase;
	
	import mx.events.IndexChangedEvent;

	public class CoverageModelManagerTest extends EventfulTestCase
	{
		private var model:CoverageModelManager;
		
		override public function setUp():void
		{
			model = new CoverageModelManager(CoverageModelData.createCoverageModel());
		}
		
        public function testDefaultCoverageMeasure():void
        {
            assertEquals("expected COVERAGE_MEASURE_BRANCH",  
                        CoverageModelManager.BRANCH_MEASURE, 
                        model.currentMeasureIndex);
        }
        
        public function testEventDispatchOnChangeOfCurrentCoverageMeasure():void
        {
            listenForEvent(model, IndexChangedEvent.CHANGE);      
            
            model.changeCoverageMeasure(CoverageModelManager.LINE_MEASURE);
            
            assertEvents();
        }
        
        public function testChangeOfCurrentCoverageMeasure():void
        {
            model.changeCoverageMeasure(CoverageModelManager.LINE_MEASURE);
            
            assertEquals("expected COVERAGE_MEASURE_LINE", 
                        CoverageModelManager.LINE_MEASURE, 
                        model.currentMeasureIndex);    
        }
        
        public function testInvalidCoverageMeasure():void
        {
            try
            {
                model.changeCoverageMeasure(-1);
                
                fail("expected error when invalid coverage measure given");
            }
            catch(e:Error)
            {
                
            }
        }
        
        
        public function testForBranchModel():void
        {
            assertNotNull("expected branchModel", 
                              model.branchModel);
        }

        public function testForLineModel():void
        {
            assertNotNull("expected lineModel", 
                              model.lineModel);
        }
		
		public function testForBranchSearch():void
		{
			model.changeCoverageMeasure(CoverageModelManager.BRANCH_MEASURE);
		    var search:ISearchable = model.getCurrentSearch();
		    assertNotNull("expected branchPackageSearch", search);
		    
            var search2:ISearchable = model.getCurrentSearch();
            assertEquals("expected same", search, search2);		    
		}
        	
        public function testForLineSearch():void
        {
            model.changeCoverageMeasure(CoverageModelManager.LINE_MEASURE);
            var search:ISearchable = model.getCurrentSearch();
            assertNotNull("expected linePackageSearch", search);
            
            var search2:ISearchable = model.getCurrentSearch();
            assertEquals("expected same", search, search2);
        }
	}
}