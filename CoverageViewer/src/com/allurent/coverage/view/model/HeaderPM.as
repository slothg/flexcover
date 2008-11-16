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
package com.allurent.coverage.view.model
{
	import com.adobe.ac.util.IOneTimeInterval;
	import com.adobe.ac.util.service.IFileBrowser;
	import com.allurent.coverage.IController;
	import com.allurent.coverage.event.HeavyOperationEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;

    /** Parsing of coverage data (i.e. cvm, cvr files) starts */
    [Event(name="heavyOperationEvent",
            type="com.allurent.coverage.event.HeavyOperationEvent")]            
	public class HeaderPM extends EventDispatcher
	{
        [Bindable]
        public var controller:IController;
        [Bindable]
        public var searchPM:SearchPM;        
        [Bindable]
        public var enabled:Boolean;          
        
		private var searchDelay:IOneTimeInterval;
		private var fileBrowser:IFileBrowser;
		
		public function HeaderPM(controller:IController, fileBrowser:IFileBrowser)
		{
			this.controller = controller;	
			this.fileBrowser = fileBrowser;
		    
			searchPM = new SearchPM();
		}
		
		public function setSearchDelay(searchDelay:IOneTimeInterval):void
		{
			this.searchDelay = searchDelay
		}
		
        public function search(searchInput:String):void
        {
            searchDelay.delay(500, onSearch, searchInput);
        }
        
        public function refreshCoverageData():void
        {
            controller.endCoverageRecording();
        }
        
        public function clearCoverageData():void
        {
            controller.clearCoverageData();
        }
        
        public function canClearCoverageData(enabled:Boolean, 
                                            isCoverageDataCleared:Boolean):Boolean
        {
            return (enabled && !isCoverageDataCleared);
        }		
		
        public function openInput():void
        {
            fileBrowser.addEventListener(FileListEvent.SELECT_MULTIPLE, handleInputFilesSelected);
            var filter0:FileFilter = new FileFilter("All Files", "*.*");
            var filter1:FileFilter = new FileFilter("Coverage Metadata (.cvm)", "*.cvm");
            var filter2:FileFilter = new FileFilter("Coverage Report (.cvr)", "*.cvr");
            fileBrowser.browseForOpenMultiple("Open File(s)", [filter0, filter1, filter2]);
        }
        
        public function saveOutput():void
        {
            fileBrowser.addEventListener(Event.SELECT, handleOutputFileSelected);
            fileBrowser.browseForSave("Save XML Coverage Report");
        }
        
        private function onSearch(searchInput:String):void
        {
            searchPM.search(searchInput);
        }
        
        private function handleInputFilesSelected(event:FileListEvent):void
        {
            dispatchEvent(new HeavyOperationEvent(controller.processFileArgument, 
                                                  [event.files]));            
        }
        
        private function handleOutputFileSelected(event:Event):void
        {
            var file:File = File(event.target);
            controller.writeReport(file);
        }       
	}
}