package tests.com.allurent.coverage.view.model
{
	import com.allurent.coverage.event.BrowserItemEvent;
	import com.allurent.coverage.model.ClassModel;
	import com.allurent.coverage.model.FunctionModel;
	import com.allurent.coverage.model.PackageModel;
	import com.allurent.coverage.model.ProjectModel;
	import com.allurent.coverage.view.model.ContentPM;
	
	import flexunit.framework.TestCase;
	
	import mx.collections.IHierarchicalCollectionView;
	
	import tests.com.allurent.coverage.CoverageModelData;

	public class ContentPMTest extends TestCase
	{
		private var model:ContentPM;
		
		override public function setUp():void
		{
			model = new ContentPM(new ProjectModel());
		}
		
		public function testDisplayEmtpyViewByDefault():void
		{
			assertEquals("expected empty view", 
							ContentPM.EMPTY_VIEW, 
							model.currentIndex );
		}
		
		public function testDisplaySourceCodeViewOnClassModelEvent():void
		{
			var segmentModel:ClassModel = new ClassModel();
			var event:BrowserItemEvent = new BrowserItemEvent(segmentModel);
			
			model.handleContentChange(event);
				
			assertEquals("expected SOURCE_CODE_VIEW", 
							ContentPM.SOURCE_CODE_VIEW, 
							model.currentIndex );
		}
		
		public function testDisplaySourceCodeViewOnFunctionModelEvent():void
		{
			var segmentModel:FunctionModel = new FunctionModel();
			segmentModel.parent = new ClassModel();
			var event:BrowserItemEvent = new BrowserItemEvent(segmentModel);
			
			model.handleContentChange(event);
			
			assertEquals("expected SOURCE_CODE_VIEW", 
							ContentPM.SOURCE_CODE_VIEW, 
							model.currentIndex );
		}
						
		public function testDisplayPackageViewOnPackageModelEvent():void
		{
			var segmentModel:PackageModel = CoverageModelData.createPackageModel();
			var event:BrowserItemEvent = new BrowserItemEvent(segmentModel);
			
			model.handleContentChange(event);
			
			assertEquals("expected PACKAGE_VIEW", 
							ContentPM.PACKAGE_VIEW, 
							model.currentIndex );
							
			assertTrue("expected dataProvider compatible to ADG", 
							model.dataProvider is IHierarchicalCollectionView );							
		}
	}
}