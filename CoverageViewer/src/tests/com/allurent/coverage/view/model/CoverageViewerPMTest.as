package tests.com.allurent.coverage.view.model
{
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.view.model.CoverageViewerPM;
	
	import flexunit.framework.TestCase;
	
	import mx.collections.HierarchicalCollectionView;
	import mx.collections.IHierarchicalCollectionView;

	public class CoverageViewerPMTest extends TestCase
	{
		private var model:CoverageViewerPM;
		private var branchCoverageModel : IHierarchicalCollectionView;
		private var lineCoverageModel : IHierarchicalCollectionView;
		
		override public function setUp():void
		{
			model = new CoverageViewerPM(Controller.instance);		
		}
		
		public function testInvalidCoverageMeasure():void
		{
			try
			{
				model.changeCoverageMeasure(-1);
				fail("expected error when invalid coverage measure given");
			}
			catch(e:Error)
			{
				
			}
		}
				
		public function testDefaultCoverageMeasure():void
		{
			model.changeCoverageMeasure(0);
			assertEquals("should propagate coverage measure to SearchPM", 
						0, 
						model.searchPM.currentCoverageMeasureIndex);	
		}
		
		public function testChangeOfCurrentCoverageModel():void
		{
			model.changeCoverageMeasure(1);
			assertEquals("should propagate coverage measure to SearchPM", 
						1, 
						model.searchPM.currentCoverageMeasureIndex);		
		}
	}
}