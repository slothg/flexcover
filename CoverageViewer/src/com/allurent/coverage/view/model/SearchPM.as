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
	import com.allurent.coverage.model.application.CoverageModelManager;
	import com.allurent.coverage.model.search.ISearchable;
	
	import mx.collections.IHierarchicalCollectionView;
	import mx.events.IndexChangedEvent;
	
	public class SearchPM implements ISearchable
	{
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

		private var coverageModels:CoverageModelManager	

		[Bindable]
		public var currentSearchInput:String;
		[Bindable]
		public var searchForPackage:Boolean;
		[Bindable]
		public var currentSearch:ISearchable;
		
		private var initialized:Boolean;

        public function handleCoverageMeasureChange(event:IndexChangedEvent):void
        {
        	updateSearchType();
        }
		
		public function setup(coverageModels:CoverageModelManager):void
		{
            this.coverageModels = coverageModels;
            coverageModels.addEventListener(IndexChangedEvent.CHANGE, 
                                       handleCoverageMeasureChange);
            
            initialized = true;
            
            updateSearchType();
            search(currentSearchInput);
		}
		
		public function toggleDetail():void
		{
	       currentSearch.showDetail = (currentSearch.showDetail) ? false : true;
	       currentSearch.search(currentSearchInput);
		}
		
		public function search(searchInput:String):String
		{
			currentSearchInput = currentSearch.search(searchInput);
			return currentSearchInput;
		}
		
        private function updateSearchType():void
        {
            if(!initialized) return;
            currentSearch = coverageModels.getCurrentSearch();          
            getCurrentSearchInput();
        }		
		
		private function getCurrentSearchInput():void
		{
			currentSearchInput = currentSearch.currentSearchInput;
		}
	}
}