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
			//simulate Binding tags in each 
			branchCoverageModel = new HierarchicalCollectionView();
			lineCoverageModel = new HierarchicalCollectionView();			
		}
		
		public function testInitalizationOfCurrentCoverageModel():void
		{
			assertNull("currentCoverageModel not initialized", model.currentCoverageModel);
			model.changeCoverageMeasure(0);
			model.branchCoverageModel = branchCoverageModel;
			model.lineCoverageModel = lineCoverageModel;
			model.applyCurrentCoverageModel();
			assertNotNull("currentCoverageModel initialized", model.currentCoverageModel);
			assertEquals("currentCoverageModel should be branchCoverageModel", branchCoverageModel, model.currentCoverageModel);
		}
		
		public function testChangeOfCurrentCoverageModel():void
		{
			testInitalizationOfCurrentCoverageModel();
			model.changeCoverageMeasure(1);
			assertEquals("currentCoverageModel should be lineCoverageModel", lineCoverageModel, model.currentCoverageModel);			
		}		
	}
}