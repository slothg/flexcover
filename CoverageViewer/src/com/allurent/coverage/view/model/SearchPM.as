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
	import com.allurent.coverage.model.CoverageModel;
	import com.allurent.coverage.model.search.ClassSearch;
	import com.allurent.coverage.model.search.ISearchable;
	import com.allurent.coverage.model.search.PackageSearch;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IHierarchicalCollectionView;
	import mx.collections.IList;
	
	public class SearchPM implements ISearchable
	{
		public static const SEARCH_BY_PACKAGE:String = "Package";
		public static const SEARCH_BY_CLASS:String = "Class";	
		
        private var _currentCoverageMeasureIndex:int;
        [Bindable]
        public function get currentCoverageMeasureIndex():int
        {
        	return _currentCoverageMeasureIndex;
        }
        public function set currentCoverageMeasureIndex(value:int):void
        {
        	_currentCoverageMeasureIndex = value;
        	setLastSearch();
        }
        
        public function get content():IHierarchicalCollectionView
        {
        	return currentSearch.content;
        }
        public function set content(value:IHierarchicalCollectionView):void
        {
        	currentSearch.content = value;
        }        
		
        public function get showDetail():Boolean
        {
        	return currentSearch.showDetail;
        }
        public function set showDetail(value:Boolean):void
        {
        	currentSearch.showDetail = value;
        }
		
		[Bindable]
		public var branchPackageSearch:ISearchable;
		[Bindable]
		public var branchClassSearch:ISearchable;
		[Bindable]
		public var linePackageSearch:ISearchable;
		[Bindable]
		public var lineClassSearch:ISearchable;		
		
		[Bindable]
		public var searchByProvider:IList;
		[Bindable]
		public var currentSearchInput:String;
		[Bindable]
		public var searchForPackage:Boolean;
		public var currentSearch:ISearchable;
		
		private var initialized:Boolean;
		
		public function SearchPM()
		{
			currentCoverageMeasureIndex = CoverageViewerPM.COVERAGE_MEASURE_BRANCH;
			createSearchByProvider();
		}
		
		public function initialize(coverageModel:CoverageModel):void
		{
            branchPackageSearch = new PackageSearch(coverageModel);
            branchClassSearch = new ClassSearch(coverageModel);
            linePackageSearch = new PackageSearch(coverageModel);
            lineClassSearch = new ClassSearch(coverageModel);
            
            initialized = true;

            changeSearchBy(SEARCH_BY_PACKAGE);
            search("");
		}
		
		public function setLastSearch():void
		{
			if(!initialized) return;
			setCurrentSearch();
			getCurrentSearchInput();
		}
		
		public function changeSearchBy(searchByInput:Object):void
		{
			var searchBy : String = String(searchByInput);
			searchForPackage = (searchBy == SearchPM.SEARCH_BY_PACKAGE) ? true : false;
			setLastSearch();
		}
		
		public function search(searchInput:String):String
		{
			currentSearchInput = currentSearch.search(searchInput);
			return currentSearchInput;
		}

		private function setCurrentSearch():void
		{
			if(currentCoverageMeasureIndex == CoverageViewerPM.COVERAGE_MEASURE_BRANCH)
			{
				currentSearch = (searchForPackage) ? branchPackageSearch : branchClassSearch;
			}
			else if(currentCoverageMeasureIndex == CoverageViewerPM.COVERAGE_MEASURE_LINE)
			{
				currentSearch = (searchForPackage) ? linePackageSearch : lineClassSearch;
			}
		}
		
		private function createSearchByProvider():void
		{
			searchByProvider = new ArrayCollection();
			searchByProvider.addItem(SearchPM.SEARCH_BY_PACKAGE);
			searchByProvider.addItem(SearchPM.SEARCH_BY_CLASS);
		}
		
		private function getCurrentSearchInput():void
		{
			currentSearchInput = currentSearch.currentSearchInput;
		}
	}
}