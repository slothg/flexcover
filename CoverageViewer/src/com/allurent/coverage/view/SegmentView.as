/* 
 * Copyright (c) 2008 Allurent, Inc.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished
 * to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
 * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package com.allurent.coverage.view
{
    import com.allurent.coverage.Controller;
    import com.allurent.coverage.event.SourceViewEvent;
    import com.allurent.coverage.model.CoverageData;
    import com.allurent.coverage.model.SegmentModel;
    
    import flash.events.Event;
    
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
            dispatchEvent(new SourceViewEvent(SourceViewEvent.VIEW_CLASS, selection as SegmentModel));
        }
    }
}