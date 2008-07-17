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
	import com.allurent.coverage.model.CoverageData;
	import com.allurent.coverage.model.CoverageModel;
	import com.allurent.coverage.model.PackageModel;
	
	import mx.collections.HierarchicalCollectionView;
	import mx.collections.IHierarchicalCollectionView;
	
	public class AbstractSearch implements ISearchable
	{
		[Bindable]
		public var content:IHierarchicalCollectionView;		
		[Bindable]
		public var currentSearchInput:String;
		[Bindable]
		public var showDetail:Boolean;
		public var coverageModel:CoverageModel;		
		
		protected var openNodes:Array;

		public function AbstractSearch(coverageModel:CoverageModel)
		{
			this.coverageModel = coverageModel;
			currentSearchInput = "";
			this.content = createContentModel(coverageModel);
			content.filterFunction = filterBySearchInput;
			resetOpenNodes();
		}
		
		public function search(searchInput:String):String
		{
			//CLUNKY: au: I have to null the search, otherwise the filter logic 
			//isn't working as expected. To see for yourself, comment out 
			//and run the unit tests.
			performSearch(null);
			performSearch(searchInput);
			return currentSearchInput;
		}
		
		private function performSearch(searchInput:String):void
		{
			resetOpenNodes();
			currentSearchInput = searchInput;					
			content.refresh();
			content.openNodes = openNodes;
		}
		
		protected function find(packageModel:PackageModel):Boolean
		{
			throw new Error("Abstract");
		}
		
		protected function findString(name:String):Boolean
		{
			var pattern:RegExp = new RegExp("^" + currentSearchInput, "i");
			return pattern.test(name);
		}
		
		protected function isTopLevel(displayName:String):Boolean
		{
			return (displayName == "[top level]");
		}

		private function filterBySearchInput(item:Object):Boolean
		{
			var found:Boolean = true;
			//au: we sometimes get ClassModels filtered in. Why?
			if(item is PackageModel)
			{
				var packageModel:PackageModel = PackageModel(item);
				if(isTopLevel(packageModel.displayName)) return true;
				found = find(packageModel);
			}
			
			return found;
		}
		
		private function createContentModel(coverageModel:CoverageModel):IHierarchicalCollectionView
		{
			var hierarchicalData:CoverageData = new CoverageData(coverageModel);
			var model:IHierarchicalCollectionView = new HierarchicalCollectionView(hierarchicalData);
			model.showRoot = false;
			return model;	
		}
		
		private function resetOpenNodes():void
		{
			openNodes = new Array();
			openNodes.push(coverageModel);			
		}
	}
}