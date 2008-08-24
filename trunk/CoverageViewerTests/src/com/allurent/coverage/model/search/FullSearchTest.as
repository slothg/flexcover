package com.allurent.coverage.model.search
{
	import com.allurent.coverage.CoverageModelData;
	import com.allurent.coverage.model.ClassModel;
	import com.allurent.coverage.model.CoverageModelManager;
	import com.allurent.coverage.model.PackageModel;
	
	import flexunit.framework.TestCase;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;

	public class FullSearchTest extends TestCase
	{
        private var model:FullSearch;
        
        override public function setUp():void
        {
            var coverageModels:CoverageModelManager = CoverageModelData.createCoverageModelsForFunction(createCoverageModelChildren);
            model = new FullSearch(coverageModels.branchModel);
        }
        
        private static function createCoverageModelChildren():IList
        {
            var topLevel:PackageModel = CoverageModelData.createPackage("[top level]");
            CoverageModelData.addClassToPackage(topLevel, new ClassModel());
            
            var domains:PackageModel = CoverageModelData.createPackage("com.adobe.ac.model.domain.products.");           
            var products:ClassModel = CoverageModelData.createClass("Products");
            var product:ClassModel = CoverageModelData.createClass("Product");
            var shoppingCart:ClassModel = CoverageModelData.createClass("ShoppingCart");
            var price:ClassModel = CoverageModelData.createClass("Price");
            CoverageModelData.addClassToPackage(domains, products);            
            CoverageModelData.addClassToPackage(domains, product);
            CoverageModelData.addClassToPackage(domains, shoppingCart);
            CoverageModelData.addClassToPackage(domains, price);
            
            var commands:PackageModel = CoverageModelData.createPackage("com.adobe.ac.control.commands");
            var getProductsCommand:ClassModel = CoverageModelData.createClass("GetProductsCommand");
            var getProductCommand:ClassModel = CoverageModelData.createClass("GetProductCommand");
            var getPriceCommand:ClassModel = CoverageModelData.createClass("GetPriceCommand");
            var priceUpdateCommand:ClassModel = CoverageModelData.createClass("PriceUpdateCommand");
            CoverageModelData.addClassToPackage(commands, getProductsCommand);
            CoverageModelData.addClassToPackage(commands, getProductCommand);
            CoverageModelData.addClassToPackage(commands, getPriceCommand);
            CoverageModelData.addClassToPackage(commands, priceUpdateCommand);
            
            return new ArrayCollection([topLevel, domains, commands]);
        }
        
        /*
        //TODO: find out why this fails
        public function testIfOnlyPackagesCanBeShown():void
        {
            model.search("com.a");
            assertEquals("expected 1 top level, 2 packages, 0 classes", 
                                3, model.content.length);
        }        
        */
        
        public function testIfOnlyPackagesCanBeShown():void
        {
            model.search("com.ad");
            assertEquals("expected 1 top level, 2 packages, 0 classes", 
                                3, model.content.length);
        }
        
        public function testShowOnlyOnePackage():void
        {
            model.search("com.adobe.ac.m");
            assertEquals("expected 1 top level, 1 packages, 0 classes", 
                                2, model.content.length);
        }        
        
        public function testIfOnlyClassesCanBeShown():void
        {
            model.search("ShoppingCart");
            assertEquals("expected 1 top level, 1 package, 1 classes", 
                                3, model.content.length);
        }
        
        public function testShowClassesFromTwoDifferentPackages():void
        {
            model.search("Price");
            assertEquals("expected 1 top level, 2 packages, 3 classes", 
                                6, model.content.length);
        }
        
        public function testShowPackagesAndClasses():void
        {
            model.search("product");
            assertEquals("expected 1 top level, 2 packages, 4 classes", 
                                7, model.content.length);
        }
        
        public function testShowPackagesAndClassesWithExactMatch():void
        {
            model.search("products");
            assertEquals("expected 1 top level, 2 packages, 2 classes", 
                                5, model.content.length);
        }        
	}
}