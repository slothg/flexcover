package tests.com.allurent.coverage.view.model
{
	import flexunit.framework.TestCase;
	import flexunit.framework.TestSuite;
	
	public class AllPresentationModelTests extends TestSuite
	{
		public function AllPresentationModelTests()
		{
			addTest(new TestSuite(CoverageViewerPMTest));
			addTest(new TestSuite(SearchPMTest));
		}
	}
}