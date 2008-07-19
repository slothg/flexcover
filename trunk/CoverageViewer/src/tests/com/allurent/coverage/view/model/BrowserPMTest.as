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
package tests.com.allurent.coverage.view.model
{
	import com.allurent.coverage.model.CoverageModelManager;
	import com.allurent.coverage.view.model.BrowserPM;
	
	import flexunit.framework.TestCase;
	
	import tests.com.allurent.coverage.CoverageModelData;
    
	public class BrowserPMTest extends TestCase
	{
		private var model:BrowserPM;
		
		override public function BrowserPMTest()
		{
			model = new BrowserPM();
			model.initialize(CoverageModelData.createCoverageModels());
		}
		
        public function testDefaultCoverageMeasure():void
        {
            assertEquals("expected COVERAGE_MEASURE_BRANCH",  
                        CoverageModelManager.BRANCH_MEASURE, 
                        model.coverageModels.currentMeasureIndex);   
        }
        
        public function testChangeOfCurrentCoverageMeasure():void
        {
            model.changeCoverageMeasure(CoverageModelManager.LINE_MEASURE);
            
            assertEquals("expected COVERAGE_MEASURE_LINE", 
                        CoverageModelManager.LINE_MEASURE, 
                        model.coverageModels.currentMeasureIndex);    
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
	}
}