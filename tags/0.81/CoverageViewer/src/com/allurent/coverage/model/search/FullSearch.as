package com.allurent.coverage.model.search
{
	import com.allurent.coverage.model.ClassModel;
	import com.allurent.coverage.model.PackageModel;
	
	import mx.collections.ICollectionView;
	import mx.collections.IHierarchicalCollectionView;
	import mx.collections.IViewCursor;

	public class FullSearch extends AbstractSearch
	{
		public function FullSearch(content:IHierarchicalCollectionView)
		{
			super(content);
		}
		
        override protected function find(packageModel:PackageModel):Boolean
        {
            return findPackage(packageModel);
        }
        
        private function findPackage(packageModel:PackageModel):Boolean
        {
            var foundPackage:Boolean = findAnyStringNonCaseSensitive(packageModel.displayName);
            if(foundPackage)
            {
                if(showDetail)
                {
                    openNodes.push(packageModel);
                }
            }
            
            var foundClass:Boolean = findClass(packageModel);
            
            return (foundPackage || foundClass);       
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
                isClassFound = findAnyStringNonCaseSensitive(classModel.displayName);
                
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
            return findAnyStringNonCaseSensitive(classModel.displayName);
        }        
	}
}