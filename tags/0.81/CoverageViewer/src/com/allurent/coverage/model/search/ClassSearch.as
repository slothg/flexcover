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
package com.allurent.coverage.model.search
{
	import com.allurent.coverage.model.ClassModel;
	import com.allurent.coverage.model.PackageModel;
	
	import mx.collections.ICollectionView;
	import mx.collections.IHierarchicalCollectionView;
	import mx.collections.IViewCursor;
	
	public class ClassSearch extends AbstractSearch
	{
		public function ClassSearch(content:IHierarchicalCollectionView)
		{
			super(content);
			showDetail = false;
		}
		
		override protected function find(packageModel:PackageModel):Boolean
		{
			return findClass(packageModel);
		}
		
		private function findClass(packageModel:PackageModel):Boolean
		{
			var keepPackage:Boolean = false;
			var classChildren:ICollectionView = content.getChildren(packageModel);
			var cursor:IViewCursor = classChildren.createCursor();
			while(cursor.current)
			{
				var isClassFound:Boolean;
				var classModel:ClassModel = ClassModel(cursor.current);
				isClassFound = findFirstStringNonCaseSensitive(classModel.displayName);
				
				if(isClassFound)
				{
					keepPackage = isClassFound;
					addToOpenNodes(packageModel);
					if(showDetail)
					{
						addToOpenNodes(classModel);
					}
				}
				cursor.moveNext();
			}
			if(keepPackage)
			{
				classChildren.filterFunction = filteroutFunction;
				classChildren.refresh();			
			}
			else
			{
				classChildren.filterFunction = null;
				classChildren.refresh();
			}
			return keepPackage;
		}
		
		private function addToOpenNodes(segmentModel:Object):void
		{
			if(openNodes.indexOf(segmentModel) < 0)
			{
				openNodes.push(segmentModel);
			}	
		}
		
		private function filteroutFunction(item:Object):Boolean
		{
			var classModel:ClassModel = ClassModel(item);
			return findFirstStringNonCaseSensitive(classModel.displayName);
		}
	}
}