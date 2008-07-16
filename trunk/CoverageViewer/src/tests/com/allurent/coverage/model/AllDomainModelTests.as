package tests.com.allurent.coverage.model
{
	import flexunit.framework.TestSuite;
	
	public class AllDomainModelTests extends TestSuite
	{
		public function AllDomainModelTests()
		{
			addTest( new TestSuite(PackageSearchTest));
			addTest( new TestSuite(ClassSearchTest));
		}

	}
}