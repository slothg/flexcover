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
package com.allurent.coverage
{
	import flash.filesystem.File;
	
	import flexunit.framework.EventfulTestCase;
	
	public class ControllerTest extends EventfulTestCase
	{
		private var model:Controller;
		
		override public function setUp():void
		{
			model = new Controller();
		}
        
        public function testIfParsingStartsOnFileDragDrop():void
        { 
            //in the real world we would pass one or more File types.
            //Here, we test if the expected error has been thrown on the 
            //underlying parser. This tells us that the parser has been invoked.          
            
            var dropSource:Array = new Array(null);            
            try
            {
                model.processFileArgument(dropSource);
                fail("parser is expected to throw a runtime for a null argument");
            }
            catch(error:ArgumentError)
            {
                
            }
        }
        
        public function testLoadProject():void
        {
            try
            {
                model.loadProject(new File());
                fail("controller is expected to throw a runtime for invalid File");
            }
            catch(error:Error)
            {
                
            }
        }
        
        public function testClearCoverageData():void
        {
        	assertTrue("expected coverage data cleared at startup", model.isCoverageDataCleared);
        	
            //a loadCoverageReport would set it to false
            model.isCoverageDataCleared = false;
            
            model.clearCoverageData();
            assertTrue("expected coverage data cleared", model.isCoverageDataCleared);
        }   
	}
}