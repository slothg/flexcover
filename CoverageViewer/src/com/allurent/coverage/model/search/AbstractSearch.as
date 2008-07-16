package com.allurent.coverage.model.search
{
	import com.allurent.coverage.model.CoverageData;
	import com.allurent.coverage.model.CoverageModel;
	import com.allurent.coverage.model.PackageModel;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.HierarchicalCollectionView;
	import mx.collections.ICollectionView;
	import mx.collections.IHierarchicalCollectionView;
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	
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
			this.content = createCoverageModel(coverageModel);
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
		
		private function createCoverageModel(coverageModel:CoverageModel):IHierarchicalCollectionView
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