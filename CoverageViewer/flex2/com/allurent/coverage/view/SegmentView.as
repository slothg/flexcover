package com.allurent.coverage.view
{
    import com.allurent.coverage.Controller;
    import com.allurent.coverage.model.ClassModel;
    import com.allurent.coverage.model.CoverageData;
    import com.allurent.coverage.model.FunctionModel;
    import com.allurent.coverage.model.SegmentModel;
    
    import flash.events.Event;
    
    import mx.collections.ArrayCollection;
    import mx.containers.VBox;
    import mx.controls.AdvancedDataGrid;
    import mx.events.FlexEvent;

    public class SegmentView extends VBox
    {   
        [Bindable]
        public var controller:Controller;

        [Bindable]
        public var coverageGrid:AdvancedDataGrid;
        
        private var _segmentModel:SegmentModel;
        private var _gridComplete:Boolean;
        
        [Bindable]
        public function get segmentModel():SegmentModel
        {
            return _segmentModel;
        } 
        
        public function set segmentModel(s:SegmentModel):void
        {
            _segmentModel = s;
            if (coverageGrid == null)
            {
                addEventListener(FlexEvent.CREATION_COMPLETE, handleCreationComplete);
                return;
            }
            initializeGrid();
        }
        
        private function handleCreationComplete(e:Event):void
        {
            initializeGrid();
        }
        
        private function initializeGrid():void
        {
            coverageGrid.dataProvider = new CoverageData(_segmentModel);
            coverageGrid.validateNow();
            coverageGrid.expandItem(_segmentModel, true);
        }
        
        public function showSource(selection:Object):void
        {
            if (selection is ClassModel)
            {
                SourceView.show(controller.project, ClassModel(selection));
            }
        }
    }
}