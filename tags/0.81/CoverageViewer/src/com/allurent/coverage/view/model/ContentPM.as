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
	import com.allurent.coverage.event.BrowserItemEvent;
	import com.allurent.coverage.model.ClassModel;
	import com.allurent.coverage.model.FunctionModel;
	import com.allurent.coverage.model.ICoverageModel;
	import com.allurent.coverage.model.PackageModel;
	import com.allurent.coverage.model.application.CoverageModelManager;
	import com.allurent.coverage.model.application.ProjectModel;
	
	import mx.collections.ICollectionView;
	import mx.collections.IHierarchicalCollectionView;
	import mx.collections.IViewCursor;
	
	public class ContentPM
	{	
		public static const EMPTY_VIEW:int = 0;
		public static const PACKAGE_VIEW:int = 1;
		public static const SOURCE_CODE_VIEW:int = 2;
		
		[Bindable]
		public var currentIndex:int;
		[Bindable]
		public var hasInvalidated:Boolean;		
		[Bindable]
		public var project:ProjectModel;
		[Bindable]
		public var classModel:ClassModel;
		[Bindable]
		public var packageModel:PackageModel;
		[Bindable]
		public var dataProvider:IHierarchicalCollectionView;	
		[Bindable]
		public var lineNum:uint;
		
		public function ContentPM(project:ProjectModel)
		{
			this.project = project;
			currentIndex = EMPTY_VIEW;
			reset();
		}
		
		public function handleContentChange(event:BrowserItemEvent):void
		{
        	if(event.segmentModel is ICoverageModel)
        	{
        		currentIndex = EMPTY_VIEW;
        		return;
        	}
        	
        	reset();
            if (event.segmentModel is ClassModel)
            {
                classModel = event.segmentModel as ClassModel;
            }
            else if (event.segmentModel is FunctionModel)
            {
                var functionModel:FunctionModel = event.segmentModel as FunctionModel; 
                classModel = functionModel.classModel;
                lineNum = functionModel.line;
            }

            if (classModel == null)
            {
                currentIndex = PACKAGE_VIEW;
                packageModel = PackageModel(event.segmentModel);
                dataProvider = CoverageModelManager.createContentModel(packageModel);
                openClassNodes(dataProvider, packageModel);
            }
            else 
            {
            	currentIndex = SOURCE_CODE_VIEW;
            	hasInvalidated = true;
            }
		}
		
		private function openClassNodes(dataProvider:IHierarchicalCollectionView, 
									packageModel:PackageModel) : void
		{
			var openNodes:Array = new Array();
			var classChildren:ICollectionView = dataProvider.getChildren(packageModel);
			var cursor:IViewCursor = classChildren.createCursor();
			while(cursor.current)
			{
				if(cursor.current is ClassModel)
				{
					var classModel:ClassModel = ClassModel(cursor.current);
					openNodes.push(classModel);
				}
				cursor.moveNext();
			}
			dataProvider.openNodes = openNodes;
		}

        private function reset():void
        {
         	classModel = null;
         	packageModel = null;
        	lineNum = 0;
        	hasInvalidated = false;    	
        }
	}
}