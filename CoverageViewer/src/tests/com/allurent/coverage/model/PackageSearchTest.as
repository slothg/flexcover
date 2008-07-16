package tests.com.allurent.coverage.model
{
	import com.allurent.coverage.model.CoverageModel;
	import com.allurent.coverage.model.search.PackageSearch;
	
	import flexunit.framework.TestCase;
	
	import tests.com.allurent.coverage.CoverageModelData;
	
	public class PackageSearchTest extends TestCase
	{
		private var model:PackageSearch;
		
		override public function setUp():void
		{
			var coverageModel:CoverageModel = CoverageModelData.createCoverageModel();
			model = new PackageSearch(coverageModel);
		}
		
		public function testSearchForUniquePackageName():void
		{
			model.search("com.adobe.ac.util");
			assertEquals("expected 1 top level item, 1 package, 1 class", 
										3, model.content.length);
		}
		
		public function testSearchForNonUniquePackageName():void
		{
			model.search("c");
			assertEquals("expected 1 top level, 2 packages which both include one class", 
								5, model.content.length);
		}
		
		public function testIfOnlyPackagesCanBeShown():void
		{
			model.showDetail = false;
			model.search("c");
			assertEquals("expected 1 top level, 2 packages", 
								3, model.content.length);
		}
		
		public function testIfPackagesAndClassesCanBeShown():void
		{
			model.showDetail = true;
			model.search("c");
			assertEquals("expected 1 top level, 2 packages which both include one class", 
								5, model.content.length);
		}
	}
}