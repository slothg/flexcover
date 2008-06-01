package tests.com.allurent.coverage.view.model
{
	import com.allurent.coverage.model.ClassModel;
	import com.allurent.coverage.model.PackageModel;
	import com.allurent.coverage.view.model.SearchPM;
	
	import flexunit.framework.TestCase;
	
	import mx.collections.ArrayCollection;
	import mx.collections.HierarchicalCollectionView;
	import mx.collections.HierarchicalData;
	import mx.collections.IHierarchicalCollectionView;
	import mx.collections.IList;

	public class SearchPMTest extends TestCase
	{
		private var model:SearchPM;
		
		override public function setUp():void
		{
			model = new SearchPM();
			model.currentCoverageModel = createCoverageModel();
		}
		
		public function testInitialization():void
		{
			assertEquals("expected different size of currentCoverageModel", 3, model.currentCoverageModel.length);
		}
				
		public function testSearchForUniqueName():void
		{
			model.changeSearchBy("Package");
			model.search("com.adobe.ac.util");
			assertEquals("expected 1 item to be filtered", 3, model.currentCoverageModel.length);
		}
		
		public function testSearchForNonUniqueName():void
		{
			model.changeSearchBy("Package");
			model.search("c");
			assertEquals("expected no items to be filtered", 5, model.currentCoverageModel.length);
		}
		
		private function createCoverageModel():IHierarchicalCollectionView
		{
			var flatCollection:IList = createCoverageModelChildren();
			var hierarchicalData : HierarchicalData = new HierarchicalData(flatCollection);	
			var coverageModelHierarchy:IHierarchicalCollectionView = new HierarchicalCollectionView(hierarchicalData);
			
			return coverageModelHierarchy;	
		}
		
		private function createCoverageModelChildren():ArrayCollection
		{
			var packageModel1:PackageModel = new PackageModel();
			var topLevel:PackageModel = new PackageModel();
			topLevel.name = "[top level]";
			topLevel.children = new ArrayCollection([new ClassModel()]);
			packageModel1.name = "com.adobe.ac.util";
			packageModel1.children = new ArrayCollection([new ClassModel()]);
			var packageModel2:PackageModel = new PackageModel();
			packageModel2.name = "com.adobe.ac.controls";
			packageModel2.children = new ArrayCollection([new ClassModel()]);
			return new ArrayCollection([topLevel, packageModel1, packageModel2]);
		}
	}
}