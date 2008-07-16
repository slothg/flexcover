package com.allurent.coverage.model.search
{
	import com.allurent.coverage.model.ClassModel;
	import com.allurent.coverage.model.CoverageModel;
	import com.allurent.coverage.model.PackageModel;
	
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	
	public class ClassSearch extends AbstractSearch
	{
		public function ClassSearch(coverageModel:CoverageModel)
		{
			super(coverageModel);
			showDetail = false;
		}
		
		override protected function find(packageModel:PackageModel):Boolean
		{
			return findClass(packageModel);
		}
		
		private function findClass(packageModel:PackageModel) : Boolean
		{
			var keepPackage:Boolean = false;
			var classChildren:ICollectionView = content.getChildren(packageModel);
			var cursor:IViewCursor = classChildren.createCursor();
			while(cursor.current)
			{
				var isClassFound:Boolean;
				var classModel:ClassModel = ClassModel(cursor.current);
				isClassFound = findString(classModel.displayName);
				
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
			return findString(classModel.displayName);
		}
	}
}