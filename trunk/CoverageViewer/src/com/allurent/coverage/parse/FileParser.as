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
package com.allurent.coverage.parse
{
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.event.CoverageEvent;
	import com.allurent.coverage.model.CoverageModel;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;

	[Event(name="coverageModelChange",
			type="com.allurent.coverage.event.CoverageEvent")]
	public class FileParser extends EventDispatcher
	{
		private var controller:Controller;

		public function FileParser(controller:Controller)
		{
			this.controller = controller;
		}
		
        public function parse(file:File):void
        {
        	if(file == null)
        	{
        		throw new ArgumentError("Cannot accept null");
        	}
            if (file.name.match(/\.cvm$/))
            {
                controller.loadMetadata(file);
                dispatchCoverageModelChange(controller.coverageModel);
            }
            else if (file.name.match(/\.cvr/))
            {
                controller.loadCoverageReport(file);
                dispatchCoverageModelChange(controller.coverageModel);
            }
        }
        
        private function dispatchCoverageModelChange(model:CoverageModel):void
        {
            dispatchEvent(new CoverageEvent(
            						CoverageEvent.COVERAGE_MODEL_CHANGE, 
            						model));        	
        }
	}
}