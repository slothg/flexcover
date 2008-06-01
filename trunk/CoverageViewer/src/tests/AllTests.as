package tests
{
	import flexunit.framework.TestSuite;
	
	import tests.com.allurent.coverage.view.model.AllPresentationModelTests;

	public class AllTests extends TestSuite
	{
		public function AllTests(param:Object=null)
		{
			super(param);
			addTest(new AllPresentationModelTests());		
		}
		
	}
}