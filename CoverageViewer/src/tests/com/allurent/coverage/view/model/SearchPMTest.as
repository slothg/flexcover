package tests.com.allurent.coverage.view.model
{
	import com.allurent.coverage.view.model.CoverageViewerPM;
	import com.allurent.coverage.view.model.SearchPM;
	
	import flexunit.framework.TestCase;
	
	import tests.com.allurent.coverage.CoverageModelData;

	public class SearchPMTest extends TestCase
	{
		private var model:SearchPM;
		
		override public function setUp():void
		{
			model = new SearchPM();
			model.initialize(CoverageModelData.createCoverageModel());
		}
		
		public function testInitialization():void
		{
			assertEquals("expected branch coverage model is default", 
										CoverageViewerPM.COVERAGE_MEASURE_BRANCH, 
										model.currentCoverageMeasureIndex);
			assertTrue("expected package search is default", 
										model.searchForPackage);
			assertEquals("expected branchPackageSearch is default", 
										model.branchPackageSearch, 
										model.currentSearch);													
		}
		
		public function testTogglePackageSearchAndMaintainSearchInput():void
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
		
		public function testTogglePackageSearchAndMaintainStateOfSearchContent():void
		{
			model.changeSearchBy(SearchPM.SEARCH_BY_PACKAGE);
			model.search("c");
			assertEquals("expected first list state change; " + 
					"1 top level, 2 packages which both include one class", 
											5, model.currentSearch.content.length);
			model.changeSearchBy(SearchPM.SEARCH_BY_CLASS);
			model.search("S");
			model.changeSearchBy(SearchPM.SEARCH_BY_PACKAGE);
			assertEquals("expected last search state of list to be restored; " + 
					"1 top level, 2 packages which both include one class", 
											5, model.currentSearch.content.length);
		}
		
		public function testToggleClassSearchAndMaintainSearchInput():void
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
		
		public function testToggleClassSearchAndMaintainStateOfSearchContent():void
		{
			model.changeSearchBy(SearchPM.SEARCH_BY_CLASS);
			model.showDetail = true;
			model.search("S");
			assertEquals("expected first list state change; " + 
					"expected 1 top level, 2 packages, 2 classes, 2 members", 
								7, model.currentSearch.content.length);
													
			model.changeSearchBy(SearchPM.SEARCH_BY_PACKAGE);
			model.search("com.adobe.ac.util");
			model.changeSearchBy(SearchPM.SEARCH_BY_CLASS);
			assertEquals("expected last search state of list to be restored; " + 
					"expected 1 top level, 2 packages, 2 classes, 2 members", 
								7, model.currentSearch.content.length);					
		}
		
		public function testTogglePackageSearchAndCoverageMeasureAndMaintainSearchInput():void
		{
			testTogglePackageSearchAndMaintainSearchInput();
			model.currentCoverageMeasureIndex = CoverageViewerPM.COVERAGE_MEASURE_LINE;
			assertEquals("expected empty search input", "", model.currentSearchInput);
			model.currentCoverageMeasureIndex = CoverageViewerPM.COVERAGE_MEASURE_BRANCH;
			assertEquals("expected last search input to be restored", 
												"c", model.currentSearchInput);			
		}
	}
}