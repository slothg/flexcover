package com.allurent.coverage.view.model
{
	import com.allurent.coverage.model.ClassModel;
	import com.allurent.coverage.model.PackageModel;
	import com.allurent.coverage.model.SegmentModel;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IHierarchicalCollectionView;
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	
	public class SearchPM
	{
		private static const SEARCH_BY_PACKAGE:String = "Package";
		private static const SEARCH_BY_CLASS:String = "Class";	
			
		public var currentCoverageModel:IHierarchicalCollectionView;	
		
		[Bindable] 
		public var searchByProvider:IList;
		[Bindable]
		public var currentSearchInput:String;
		private var searchForPackage:Boolean;		
		
		public function SearchPM()
		{
			createSearchByProvider();
			searchForPackage = true;
		}
		
		public function changeSearchBy(searchByInput:Object):void
		{
			var searchBy : String = String(searchByInput);
			searchForPackage = (searchBy == SearchPM.SEARCH_BY_PACKAGE) ? true : false;
			currentSearchInput = "";
			search("");
			closeClassNodes();		
		}
		
		public function search(searchInput:String):void
		{
			currentSearchInput = searchInput;
			currentCoverageModel.filterFunction = filterBySearchInput;
			currentCoverageModel.refresh();
		}
		
		private function isTopLevel(displayName:String):Boolean
		{
			return (displayName == "[top level]");
		}
		
		private function filterBySearchInput(item:Object):Boolean
		{
			var found:Boolean = true;
			if(item is PackageModel)
			{
				var packageModel:PackageModel = PackageModel(item);
				if(isTopLevel(packageModel.displayName)) return true;
				found = (searchForPackage) ? findPackage(packageModel) : findClass(packageModel);				
			}
			
			return found;
		}
		
		private function findPackage(packageModel:PackageModel):Boolean
		{
			var found:Boolean = findString(packageModel.displayName);
			if(found)
			{
				currentCoverageModel.openNode(packageModel);
			}
			return found;		
		}
		
		private function findClass(packageModel:PackageModel) : Boolean
		{
			var found:Boolean;
			var collection:IHierarchicalCollectionView = currentCoverageModel;
			var classChildren:ICollectionView = collection.getChildren(packageModel);
			var cursor:IViewCursor = classChildren.createCursor();
			while(cursor.current)
			{
				if(cursor.current is ClassModel)
				{
					var classModel:ClassModel = ClassModel(cursor.current);
					found = findString(classModel.displayName);
					if(found)
					{
						collection.openNode(packageModel);
						collection.openNode(classModel);
					}
				}
				cursor.moveNext();
			}
			return found;
		}
		
		//TODO: Duplication of findClass behaviour, needs work.
		private function closeClassNodes() : void
		{
			var collection:IHierarchicalCollectionView = currentCoverageModel;
			var collectionCursor:IViewCursor = collection.createCursor();
			while(collectionCursor.current)
			{
				if(collectionCursor.current is PackageModel)
				{
					var classChildren:ICollectionView = collection.getChildren(collectionCursor.current);
					var cursor:IViewCursor = classChildren.createCursor();
					while(cursor.current)
					{
						var model:SegmentModel = SegmentModel(cursor.current);
						
						if(!isTopLevel(model.displayName))
						{
							var classModel:ClassModel = ClassModel(cursor.current);
							//collection.openNode(packageModel);
							collection.closeNode(classModel);							
						}
						cursor.moveNext();
					}					
				}
				collectionCursor.moveNext();
			}		
		}
		
		private function findString(name:String):Boolean
		{
			var compareLength : int = currentSearchInput.length;
			var searchAgainst : String = name.toLowerCase();
			var compareString : String = searchAgainst.substring(0, compareLength);
			var searchInput : String = currentSearchInput.toLowerCase();
			var isMatching : Boolean = (compareString == searchInput) ? true : false;
			return isMatching;
		}
		
		private function createSearchByProvider() : void
		{
			searchByProvider = new ArrayCollection();
			searchByProvider.addItem(SearchPM.SEARCH_BY_PACKAGE);
			searchByProvider.addItem(SearchPM.SEARCH_BY_CLASS);
		}
	}
}