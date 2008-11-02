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
package com.allurent.coverage.model.search
{
	import com.allurent.coverage.CoverageModelData;
	import com.allurent.coverage.model.application.CoverageModelManager;
	
	import flexunit.framework.TestCase;
	
	public class PackageSearchTest extends TestCase
	{
		private var model:PackageSearch;
		
		override public function setUp():void
		{
            var coverageModels:CoverageModelManager = CoverageModelData.createCoverageModels();
            model = new PackageSearch(coverageModels.branchModel);			
		}
		
		public function testSearchForUniquePackageName():void
		{
			model.search("com.adobe.ac.util");
			assertEquals("expected 1 top level item, 1 package, 1 class", 
										3, model.content.length);
		}
		
		public function testSearchForNonUniquePackageName():void
		{
			model.search("c");
			assertEquals("expected 1 top level, 2 packages which both include one class", 
								5, model.content.length);
		}
		
		public function testIfOnlyPackagesCanBeShown():void
		{
			model.showDetail = false;
			model.search("c");
			assertEquals("expected 1 top level, 2 packages", 
								3, model.content.length);
		}
		
		public function testIfPackagesAndClassesCanBeShown():void
		{
			model.showDetail = true;
			model.search("c");
			assertEquals("expected 1 top level, 2 packages which both include one class", 
								5, model.content.length);
		}
	}
}