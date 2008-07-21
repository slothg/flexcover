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
	import com.allurent.coverage.model.search.ClassSearch;
	import com.allurent.coverage.model.search.ISearchable;
	import com.allurent.coverage.model.search.PackageSearch;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.HierarchicalCollectionView;
	import mx.collections.IHierarchicalCollectionView;
	import mx.events.IndexChangedEvent;
	
	[Event(name="change",type="mx.events.IndexChangedEvent")]
	public class CoverageModelManager extends EventDispatcher
	{
        public static const BRANCH_MEASURE:int = 0;
        public static const LINE_MEASURE:int = 1;      		
		
        [Bindable]
        public var coverageModel:CoverageModel;  
		
        [Bindable]
        public var branchPackageModel:IHierarchicalCollectionView;
        [Bindable]
        public var branchClassModel:IHierarchicalCollectionView;
        [Bindable]
        public var linePackageModel:IHierarchicalCollectionView;
        [Bindable]
        public var lineClassModel:IHierarchicalCollectionView;	
        	    
        private var _currentMeasureIndex:int;
        [Bindable("currentMeasureIndexChange")]
        public function get currentMeasureIndex():int
        {
            return _currentMeasureIndex;
        }
		
		[Bindable]
		public var searchForPackage:Boolean;
		
        private var _branchPackageSearch:ISearchable;
        private function get branchPackageSearch():ISearchable
        {
            if(_branchPackageSearch == null)
            {
                _branchPackageSearch = new PackageSearch(branchPackageModel) 
            }
            return _branchPackageSearch;
        }
        
        private var _branchClassSearch:ISearchable;
        private function get branchClassSearch():ISearchable
        {
            if(_branchClassSearch == null)
            {
                _branchClassSearch = new ClassSearch(branchClassModel) 
            }                       
            return _branchClassSearch;       
        }
        
        private var _linePackageSearch:ISearchable;
        private function get linePackageSearch():ISearchable
        {
            if(_linePackageSearch == null)
            {
                _linePackageSearch = new PackageSearch(linePackageModel) 
            }                 
            return _linePackageSearch;   
        }
        
        private var _lineClassSearch:ISearchable;
        private function get lineClassSearch():ISearchable
        {
            if(_lineClassSearch == null)
            {
                _lineClassSearch = new ClassSearch(lineClassModel) 
            }                               
            return _lineClassSearch;        
        }		
		
        public static function createContentModel(segmentModel:SegmentModel):IHierarchicalCollectionView
        {
            var hierarchicalData:CoverageData = new CoverageData(segmentModel);
            var model:IHierarchicalCollectionView = new HierarchicalCollectionView(hierarchicalData);
            model.showRoot = false;
            return model;
        }	
        
		public function CoverageModelManager(coverageModel:CoverageModel)
		{
			this.coverageModel = coverageModel;
            
            branchPackageModel = createContentModel(coverageModel);
            branchClassModel = createContentModel(coverageModel);         
            linePackageModel = createContentModel(coverageModel);
            lineClassModel = createContentModel(coverageModel);
		}
		
        public function changeCoverageMeasure(index:int):void
        {
            if(isValidCoverageMeasureIndex(index))
            {
                _currentMeasureIndex = index;                
                dispatchEvent(new Event("currentMeasureIndexChange"));
                
                var event:IndexChangedEvent = new IndexChangedEvent(IndexChangedEvent.CHANGE);
                event.newIndex = index;
                dispatchEvent(event);
            }
            else
            {
                throw new Error("Invalid Coverage Measure");
            }
        }   
        
        public function getCurrentSearch(searchForPackage:Boolean):ISearchable
        {
        	var currentSearch:ISearchable;
            if(currentMeasureIndex == BRANCH_MEASURE)
            {
            	currentSearch = (searchForPackage) ? branchPackageSearch : branchClassSearch;
            }
            else if(currentMeasureIndex == LINE_MEASURE)
            {
            	currentSearch = (searchForPackage) ? linePackageSearch : lineClassSearch;
            }
            return currentSearch;
        }
        
        private function isValidCoverageMeasureIndex(index:int):Boolean
        {
            return (currentMeasureIndex == BRANCH_MEASURE
                    || currentMeasureIndex == LINE_MEASURE);       
        }            
	}
}