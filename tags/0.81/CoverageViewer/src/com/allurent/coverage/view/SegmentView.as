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
    import com.allurent.coverage.event.BrowserItemEvent;
    import com.allurent.coverage.model.SegmentModel;
    
    import mx.collections.IHierarchicalCollectionView;
    import mx.containers.VBox;
    import mx.controls.AdvancedDataGrid;
    import mx.core.IFactory;
    
    [Event(name="select", type="com.allurent.coverage.event.BrowserItemEvent")]
    public class SegmentView extends VBox
    {
		[Bindable]
		public var headerText:String;		
		[Bindable]
		public var renderer:IFactory;
		[Bindable]
		public var coverageDataField:String;   	
		[Bindable]
		public var uncoveredDataField:String;        
        
        [Bindable]
        public var coverageGrid:AdvancedDataGrid;
        
        private var _dataProvider:IHierarchicalCollectionView;
               
        [Bindable]
        public function get dataProvider():IHierarchicalCollectionView
        {
            return _dataProvider;
        }
        
        public function set dataProvider(value:IHierarchicalCollectionView):void
        {            
            if (coverageGrid != null && value != null)
            {
                _dataProvider = value;
                initializeGrid();
            }
        }
        
        private var _enabled:Boolean;
        [Bindable]
        public function get isEnabled():Boolean
        {
            return _enabled;
        }        
        public function set isEnabled(value:Boolean):void
        {
            _enabled = value;
        }

        public function initializeGrid():void
        {
            coverageGrid.dataProvider = dataProvider;
            _dataProvider.showRoot = true;
        }
        
        public function selectItem(selection:Object):void
        {
            dispatchEvent(new BrowserItemEvent(SegmentModel(selection)));
        }
    }
}