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
	import com.allurent.coverage.CoverageModelData;
	import com.allurent.coverage.event.BrowserItemEvent;
	import com.allurent.coverage.model.ClassModel;
	import com.allurent.coverage.model.CoverageModel;
	import com.allurent.coverage.model.FunctionModel;
	import com.allurent.coverage.model.PackageModel;
	import com.allurent.coverage.model.application.ProjectModel;
	
	import flexunit.framework.TestCase;
	
	import mx.collections.IHierarchicalCollectionView;

	public class ContentPMTest extends TestCase
	{
		private var model:ContentPM;
		
		override public function setUp():void
		{
			model = new ContentPM(new ProjectModel());
		}
		
		public function testDisplayEmtpyViewByDefault():void
		{
			assertEquals("expected empty view", 
							ContentPM.EMPTY_VIEW, 
							model.currentIndex );
		}
		
        public function testDoNothingOnCoverageModelEvent():void
        {
            var segmentModel:CoverageModel = new CoverageModel();
            var event:BrowserItemEvent = new BrowserItemEvent(segmentModel);
            
            model.handleContentChange(event);
            
            //expected initial state
            testDisplayEmtpyViewByDefault();
        }
        
        public function testDisplayNothingOnCoverageModelEvent():void
        {
        	testDisplaySourceCodeViewOnClassModelEvent();        	
            testDoNothingOnCoverageModelEvent();
        }
		
		public function testDisplaySourceCodeViewOnClassModelEvent():void
		{
			var segmentModel:ClassModel = new ClassModel();
			var event:BrowserItemEvent = new BrowserItemEvent(segmentModel);
			
			model.handleContentChange(event);
				
			assertEquals("expected SOURCE_CODE_VIEW", 
							ContentPM.SOURCE_CODE_VIEW, 
							model.currentIndex );
		}
		
		public function testDisplaySourceCodeViewOnFunctionModelEvent():void
		{
			var segmentModel:FunctionModel = new FunctionModel();
			segmentModel.parent = new ClassModel();
			var event:BrowserItemEvent = new BrowserItemEvent(segmentModel);
			
			model.handleContentChange(event);
			
			assertEquals("expected SOURCE_CODE_VIEW", 
							ContentPM.SOURCE_CODE_VIEW, 
							model.currentIndex );
		}
						
		public function testDisplayPackageViewOnPackageModelEvent():void
		{
			var segmentModel:PackageModel = CoverageModelData.createPackageModel();
			var event:BrowserItemEvent = new BrowserItemEvent(segmentModel);
			
			model.handleContentChange(event);
			
			assertEquals("expected PACKAGE_VIEW", 
							ContentPM.PACKAGE_VIEW, 
							model.currentIndex );
							
			assertTrue("expected dataProvider compatible to ADG", 
							model.dataProvider is IHierarchicalCollectionView );							
		}
	}
}