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
package tests.com.allurent.coverage.model.search
{
	import com.allurent.coverage.model.CoverageModel;
	import com.allurent.coverage.model.search.ClassSearch;
	
	import flexunit.framework.TestCase;
	
	import tests.com.allurent.coverage.CoverageModelData;
	
	public class ClassSearchTest extends TestCase
	{
		private var model:ClassSearch;
		
		override public function setUp():void
		{
			var coverageModel:CoverageModel = CoverageModelData.createCoverageModel();
			model = new ClassSearch(coverageModel);
		}
		
		public function testSearchTwiceOnDifferentPackagesAndResetOutput():void
		{		
			model.search("ShoppingCartElement");
			assertEquals("expected 1 top level, 1 package, 1 class", 
								3, model.content.length);
			model.search("ShoppingCart");
			assertEquals("expected 1 top level, 2 packages, 2 classes", 
								5, model.content.length);		
		}
		
		public function testSearchTwiceOnSamePackage():void
		{
			var coverageModel:CoverageModel = CoverageModelData.createCoverageModelWithMultipleClassesPerPackage();
			model = new ClassSearch(coverageModel);
			model.search("Product");
			assertEquals("expected 1 top level, 1 package, 1 class", 
								3, model.content.length);
			model.search("Product");
			assertEquals("expected 1 top level, 1 package, 1 class", 
								3, model.content.length);			
		}
		
		public function testSearchAndResetOutput():void
		{
			var coverageModel:CoverageModel = CoverageModelData.createCoverageModelWithMultipleClassesPerPackage();
			model = new ClassSearch(coverageModel);
			model.search("Product");
			assertEquals("expected 1 top level, 1 package, 1 class", 
								3, model.content.length);							
			model.search("");
			assertEquals("expected 1 top level, 2 package, 4 classes", 
								7, model.content.length);			
		}
		
		public function testIfNonMatchingClassesAreFilteredOut():void
		{
			var coverageModel:CoverageModel = CoverageModelData.createCoverageModelWithMultipleClassesPerPackage();
			model = new ClassSearch(coverageModel);			
			model.search("Product");
			assertEquals("expected 1 top level, 1 package, 1 class", 
								3, model.content.length);
		}
		
		public function testIfNonMatchingClassesAreFilteredOutProgressively():void
		{
			var coverageModel:CoverageModel = CoverageModelData.createCoverageModelWithMultipleClassesPerPackage();
			model = new ClassSearch(coverageModel);
			model.search("Produc");
			assertEquals("match but too short, expected 1 top level, 1 package, 1 class", 
								3, model.content.length);
											
			model.search("Product");		
			assertEquals("exact match, expected 1 top level, 1 package, 1 class", 
								3, model.content.length);			
			
			model.search("Productx");
			assertEquals("too much, expected 1 top level", 
								1, model.content.length);
			
			model.search("Product");
			assertEquals("back to exact match, expected 1 top level, 1 package, 1 class", 
								3, model.content.length);													
		}
		
		public function testIfNonMatchingClassesAreFilteredOutProgressively2():void
		{
			var coverageModel:CoverageModel = CoverageModelData.createCoverageModelWithMultipleClassesPerPackage();
			model = new ClassSearch(coverageModel);			
			model.search("Productx");
			assertEquals("not matching, expected 1 top level", 
								1, model.content.length);
			model.search("Product");
			assertEquals("exact match, expected 1 top level, 1 package, 1 class", 
								3, model.content.length);
			model.search("Produc");
			assertEquals("too short, expected 1 top level, 1 package, 1 class", 
								3, model.content.length);
			model.search("Product");
			assertEquals("again exact match, expected 1 top level, 1 package, 1 class", 
								3, model.content.length);								
		}
		
		public function testIfShorterButMatchingClassesAreFilteredOut():void
		{
			var coverageModel:CoverageModel = CoverageModelData.createCoverageModelWithMultipleClassesPerPackage();
			model = new ClassSearch(coverageModel);			
			model.search("ShoppingCartElement");
			assertEquals("expected 1 top level, 1 package, 1 class", 
								3, model.content.length);
		}
		
		public function testShowTwoClassesOfDifferentPackagePlusOneThatMatchesPartly():void
		{
			var coverageModel:CoverageModel = CoverageModelData.createCoverageModelWithMultipleClassesPerPackage();
			model = new ClassSearch(coverageModel);			
			model.search("ShoppingCart");
			assertEquals("expected 1 top level, 2 packages, 3 classes", 
								6, model.content.length);
		}

		public function testAcceptWildcardCharacterSearch():void
		{
			model.search(".*Cart");
			assertEquals("expected 1 top level, 2 packages, 2 classes", 
								5, model.content.length);
		}
		
		public function testAcceptWildcardCharacterSearchWithWildcardEnding():void
		{
			model.search(".*Cart.*");
			assertEquals("expected 1 top level, 2 packages, 2 classes", 
								5, model.content.length);
		}
		
		public function testAcceptWildcardCharacterSearchWithFixedEnd():void
		{
			model.search(".*Cart$");
			assertEquals("expected 1 top level, 1 package, 1 classe", 
								3, model.content.length);
		}	
				
		public function testIfOnlyClassesCanBeShown():void
		{
			model.search("S");
			assertEquals("expected 1 top level, 2 packages, 2 classes", 
								5, model.content.length);
		}
		
		public function testIfClassesAndMembersCanBeShown():void
		{
			model.showDetail = true;
			model.search("S");
			assertEquals("expected 1 top level, 2 packages, 2 classes, 2 members", 
								7, model.content.length);
		}
		
		public function testSearchForUniqueClassName():void
		{
			model.showDetail = true;
			model.search("ShoppingCartElement");
			assertEquals("expected 1 top level, 1 package, 1 class, 1 function", 
								4, model.content.length);
		}
		
		public function testSearchForNonUniqueClassName():void
		{
			model.showDetail = true;
			model.search("S");
			assertEquals("expected 1 top level, 2 packages, 2 classes, 2 members", 
								7, model.content.length);
		}
	}
}