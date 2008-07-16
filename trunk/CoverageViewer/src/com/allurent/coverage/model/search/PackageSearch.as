package com.allurent.coverage.model.search
{
	import com.allurent.coverage.model.CoverageModel;
	import com.allurent.coverage.model.PackageModel;
	
	import flash.utils.setTimeout;
	
	public class PackageSearch extends AbstractSearch
	{
		public function PackageSearch(coverageModel:CoverageModel)
		{
			super(coverageModel);
			showDetail = true;
		}
		
		override protected function find(packageModel:PackageModel):Boolean
		{
			return findPackage(packageModel);
		}
		
		private function findPackage(packageModel:PackageModel):Boolean
		{
			var found:Boolean = findString(packageModel.displayName);
			if(found)
			{
				if(showDetail)
				{
					openNodes.push(packageModel);
				}			 	
			}
			return found;		
		}
	}
}