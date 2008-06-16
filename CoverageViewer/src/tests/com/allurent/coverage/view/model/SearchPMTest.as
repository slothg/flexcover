package tests.com.allurent.coverage.view.model
{
	import com.allurent.coverage.model.ClassModel;
	import com.allurent.coverage.model.FunctionModel;
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
			assertEquals("expected different size of currentCoverageModel", 
										3, model.currentCoverageModel.length);
		}
				
		public function testSearchForUniquePackageName():void
		{
			model.changeSearchBy(SearchPM.SEARCH_BY_PACKAGE);
			model.search("com.adobe.ac.util");
			assertEquals("expected 1 top level item, 1 package, 1 class", 
										3, model.currentCoverageModel.length);
		}
		
		public function testSearchForNonUniquePackageName():void
		{
			model.changeSearchBy(SearchPM.SEARCH_BY_PACKAGE);
			model.search("c");
			assertEquals("expected 1 top level, 2 packages which both include one class", 
								5, model.currentCoverageModel.length);
		}
		
		public function testIfOnlyPackagesCanBeShownInPackageSearch():void
		{
			model.changeSearchBy(SearchPM.SEARCH_BY_PACKAGE);
			model.areOnlyPackagesShown = true;
			model.search("c");
			assertEquals("expected 1 top level, 2 packages", 
								3, model.currentCoverageModel.length);
		}
		
		public function testIfPackagesAndClassesCanBeShownInPackageSearch():void
		{
			model.changeSearchBy(SearchPM.SEARCH_BY_PACKAGE);
			model.areOnlyPackagesShown = false;
			model.search("c");
			assertEquals("expected 1 top level, 2 packages which both include one class", 
								5, model.currentCoverageModel.length);
		}
		
		public function testIfOnlyClassesCanBeShownInClassSearch():void
		{
			model.changeSearchBy(SearchPM.SEARCH_BY_CLASS);
			model.areOnlyClassesShown = true;
			model.search("S");
			assertEquals("expected 1 top level, 2 packages, 2 classes", 
								5, model.currentCoverageModel.length);
		}
		
		public function testIfClassesAndMembersCanBeShownInPackageSearch():void
		{
			model.changeSearchBy(SearchPM.SEARCH_BY_CLASS);
			model.areOnlyClassesShown = false;
			model.search("S");
			assertEquals("expected 1 top level, 2 packages, 2 classes, 2 members", 
								7, model.currentCoverageModel.length);
		}		
		
		public function testSearchForUniqueClassName():void
		{
			model.changeSearchBy(SearchPM.SEARCH_BY_CLASS);
			model.search("ShoppingCartElement");
			assertEquals("expected 1 top level, 1 package, 1 class, 1 function", 
								4, model.currentCoverageModel.length);
		}
		
		public function testSearchForNonUniqueClassName():void
		{
			model.changeSearchBy(SearchPM.SEARCH_BY_CLASS);
			model.search("S");
			assertEquals("expected 1 top level, 2 packages, 2 classes, 2 members", 
								7, model.currentCoverageModel.length);
		}
		
		public function testLastPackageSearchInputShouldBeRetainedWhenReturningFromClassSearch():void
		{
			model.changeSearchBy(SearchPM.SEARCH_BY_PACKAGE);
			model.search("c");
			assertEquals("expected current search input", "c", model.currentSearchInput);
			
			model.changeSearchBy(SearchPM.SEARCH_BY_CLASS);
			model.search("S");
			model.changeSearchBy(SearchPM.SEARCH_BY_PACKAGE);
			assertEquals("expected last search input to be restored", 
												"c", model.currentSearchInput);
		}
		
		public function testLastPackageSearchStateOfListShouldBeRetainedWhenReturningFromClassSearch():void
		{
			model.changeSearchBy(SearchPM.SEARCH_BY_PACKAGE);
			model.search("c");
			assertEquals("expected first list state change; " + 
					"1 top level, 2 packages which both include one class", 
											5, model.currentCoverageModel.length);
			model.changeSearchBy(SearchPM.SEARCH_BY_CLASS);
			model.search("S");
			model.changeSearchBy(SearchPM.SEARCH_BY_PACKAGE);
			assertEquals("expected last search state of list to be restored; " + 
					"1 top level, 2 packages which both include one class", 
											5, model.currentCoverageModel.length);
		}
		
		public function testLastClassSearchInputShouldBeRetainedWhenReturningFromPackageSearch():void
		{
			model.changeSearchBy(SearchPM.SEARCH_BY_CLASS);
			model.search("S");
			assertEquals("expected current search input", "S", model.currentSearchInput);
			
			model.changeSearchBy(SearchPM.SEARCH_BY_PACKAGE);
			model.search("c");
			model.changeSearchBy(SearchPM.SEARCH_BY_CLASS);
			assertEquals("expected last search input to be restored", 
												"S", model.currentSearchInput);
		}
		
		public function testLastClassSearchStateOfListShouldBeRetainedWhenReturningFromPackageSearch():void
		{
			model.changeSearchBy(SearchPM.SEARCH_BY_CLASS);
			model.search("S");	
			assertEquals("expected first list state change; " + 
					"expected 1 top level, 2 packages, 2 classes, 2 members", 
								7, model.currentCoverageModel.length);
													
			model.changeSearchBy(SearchPM.SEARCH_BY_PACKAGE);
			model.search("com.adobe.ac.util");
			model.changeSearchBy(SearchPM.SEARCH_BY_CLASS);
			assertEquals("expected last search state of list to be restored; " + 
					"expected 1 top level, 2 packages, 2 classes, 2 members", 
								7, model.currentCoverageModel.length);					
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
			var classModel1:ClassModel = new ClassModel();
			classModel1.name = "ShoppingCart";
			classModel1.children = new ArrayCollection([new FunctionModel()]);
			packageModel1.children = new ArrayCollection([classModel1]);
			
			var packageModel2:PackageModel = new PackageModel();
			packageModel2.name = "com.adobe.ac.controls";
			var classModel2:ClassModel = new ClassModel();
			classModel2.name = "ShoppingCartElement";
			classModel2.children = new ArrayCollection([new FunctionModel()]);
			packageModel2.children = new ArrayCollection([classModel2]);
			return new ArrayCollection([topLevel, packageModel1, packageModel2]);
		}
		
		 
	}
}