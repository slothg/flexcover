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
	import com.allurent.coverage.model.ClassModel;
	import com.allurent.coverage.model.CoverageModel;
	import com.allurent.coverage.model.CoverageModelManager;
	import com.allurent.coverage.model.FunctionModel;
	import com.allurent.coverage.model.PackageModel;
	import com.allurent.coverage.model.SegmentModel;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	
	public class CoverageModelData
	{
        public static function createCoverageModels():CoverageModelManager
        {
            var coverageModel:CoverageModel = new CoverageModel();
            addChildren(coverageModel, createCoverageModelChildren());
            return new CoverageModelManager(coverageModel);
        }
		
		public static function createCoverageModel():CoverageModel
		{
			var coverageModel:CoverageModel = new CoverageModel();
			addChildren(coverageModel, createCoverageModelChildren());
			return coverageModel;
		}
		
		public static function createPackageModel():PackageModel
		{
			var acControls:PackageModel = createPackage("com.adobe.ac.controls");						
			var shoppingCart2:ClassModel = createClass("ShoppingCart");
			var shoppingCartElement:ClassModel = createClass("ShoppingCartElement");
			var product:ClassModel = createClass("Product");
			
			addClassToPackage(acControls, shoppingCart2);			
			addClassToPackage(acControls, shoppingCartElement);
			addClassToPackage(acControls, product);
			
			return acControls;
		}		
		
		public static function createCoverageModelWithMultipleClassesPerPackage():CoverageModel
		{
			var coverageModel:CoverageModel = new CoverageModel();
			
			var topLevel:PackageModel = createPackage("[top level]");
			addClassToPackage(topLevel, new ClassModel());
			
			var acUtil:PackageModel = createPackage("com.adobe.ac.util");			
			var shoppingCart:ClassModel = createClass("ShoppingCart");
			addClassToPackage(acUtil, shoppingCart);			
			
			var acControls:PackageModel = createPackageModel();
			
			addChildren(coverageModel, 
						new ArrayCollection([topLevel, acUtil, acControls]));
			
			return coverageModel;
		}
		
		private static function createCoverageModelChildren():IList
		{
			var topLevel:PackageModel = createPackage("[top level]");
			addClassToPackage(topLevel, new ClassModel());
			
			var acUtil:PackageModel = createPackage("com.adobe.ac.util");			
			var shoppingCart:ClassModel = createClass("ShoppingCart");
			addClassToPackage(acUtil, shoppingCart);			
			
			var acControls:PackageModel = createPackage("com.adobe.ac.controls");
			var shoppingCartElement:ClassModel = createClass("ShoppingCartElement");
			addClassToPackage(acControls, shoppingCartElement);
			
			return new ArrayCollection([topLevel, acUtil, acControls]);
		}
		
		private static function addChildren(coverageModel:CoverageModel, collection:IList):void
		{
			for each(var child:SegmentModel in collection)
			{
				coverageModel.addChild(child);
			}
		}
		
		private static function addClassToPackage(packageModel:PackageModel, 
												classModel:ClassModel):void
		{
			classModel.parent = packageModel;
			if(packageModel.isEmpty())
			{				
				packageModel.children = new ArrayCollection([classModel]);
			}
			else
			{
				packageModel.children.addItem(classModel);
			}
		}
		
		private static function createPackage(name:String):PackageModel
		{
			var packageModel:PackageModel = new PackageModel();
			packageModel.name = name;
			return packageModel;
		}
		
		private static function createClass(name:String):ClassModel
		{
			var classModel:ClassModel = new ClassModel();
			classModel.name = name;
			classModel.children = new ArrayCollection([new FunctionModel()]);
			return classModel;
		}
		
	}
}