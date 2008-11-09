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
package com.allurent.coverage.model
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    import mx.collections.ArrayCollection;
    
    [Event(name="coverageChange",type="flash.events.Event")]
    
    /**
     * Abstract class representing some segment or cross section of a SWF-based application.
     * For coverage this means the entire app, a package, a class, a function or an individual line.
     * Models are hooked up in a tree structure with a fixed number of levels.
     *  
     * @author joeb
     */
    public class SegmentModel extends EventDispatcher implements ISegmentModel
    {
        /** Number of individual lines that are direct or indirect descendants of this one. */
        public var numLines:Number = 0;
        
        /** Number of covered lines at/below this segment. */
        [Bindable]
        public var coveredLines:Number = 0;

        /** Number of individual branches that are direct or indirect descendants of this one. */
        public var numBranches:Number = 0;
        
        /** Number of covered branches at/below this segment. */
        [Bindable]
        public var coveredBranches:Number = 0;

        /** Internal name. */
        public var name:String;
        
        /** child SegmentModels of this model. */
        public var children:ArrayCollection = null;
        
        /** The parent SegmentModel of this model. */
        public var parent:SegmentModel = null;
        
        // Event type dispatched when the coverage stats for this model changes.
        public static const COVERAGE_CHANGE:String = "coverageChange";
        
        /** map from names to child elements. */
        protected var childMap:Object = {};
        
        
        /**
         * Create a new SegmentModel. 
         */
        public function SegmentModel()
        {
        }
        
        public function isEmpty():Boolean
        {
        	if(children==null) return true;
        	return (children.length < 1);
        }
                
        /**
         * Factory method to create a child of this SegmentModel.  Overridden by the various 
         * model subclasses to ensure that their children are of the correct type.
         */
        public function createChild(element:CoverageElement):SegmentModel
        {
            return new SegmentModel();
        }
        
        /**
         * Factory method to create a child of this SegmentModel.  Overridden by the various 
         * model subclasses to ensure that their children are of the correct type.
         */
        public function createChildFromXml(childXml:XML):SegmentModel
        {
            return new SegmentModel();
        }
        
        /**
         * Get the display name of this model; patched up for some model types to paper over 
         * things like blank names, etc.
         */
        public function get displayName():String
        {
            return name;
        }
        
        /**
         * Add a child SegmentModel to this model, maintaining the integrity of the overall
         * data structure.
         *  
         * @param child SegmentModel child to be added.
         */
        public function addChild(child:SegmentModel):void
        {
            if (children == null)
            {
                // Lazily creating the children property ensures that leaf nodes
                // look like leaves in the tree.
                //
                children = new ArrayCollection();
            }
            
            // Our children need to know about us.
            child.parent = this;
            
            // Do an insertion sort here to put the child at the appropriate spot in the list
            // which is annoying, but if we use Sort() to sort the collection, that interferes
            // with AdvancedDataGrid's desire to impose its own sorting on the data.  Could maintain
            // in an array I suppose.  And for efficiency, should be a binary search of course.
            //
            var inserted:Boolean = false;
            for (var i:int = 0; i < children.length; i++)
            {
                if (child.name.toLowerCase() < SegmentModel(children[i]).name.toLowerCase())
                {
                    children.addItemAt(child, i);
                    inserted = true;
                    break;
                }
            }
            if (!inserted)
            {
                children.addItem(child);
            }

            // Maintain bookkeeping to look up a child by its canonical name.
            childMap[child.name] = child;
        }
        
        /**
         * Remove all child elements
         */
        public function clear():void
        {
            children = null;
        }
        
        /**
         * Initialize this model once it has been attached to the coverage model tree. 
         */
        public function initialize():void
        {
        }
        
        /**
         * Resolve a child element by its name
         *  
         * @param pathElement a key for the child model element
         * @return the resolved element, or null if not found.
         */
        public function resolvePathComponent(element:CoverageElement, pathElement:String):SegmentModel
        {
            return childMap[pathElement] as SegmentModel;
        }
        
        /**
         * Resolve a "path"-like array of keys, starting at the current model.
         *  
         * @param path an Array of keys; the first key applies to this model, the second
         * to the model resolved by the first key, and so on.
         * 
         * @param create Boolean indicating whether models should be created as they are
         * resolved at each level of the tree of models.
         *   
         * @return the resolved SegmentModel, or null if it could not be found.
         * 
         */
        public function resolveCoverageElement(element:CoverageElement, create:Boolean = false):SegmentModel
        {
            var index:uint = 0;
            var model:SegmentModel = this;
            var isNew:Boolean = false;
            var path:Array = element.path;
            
            while (index < path.length)
            {
                var resolvedChild:SegmentModel = model.resolvePathComponent(element, path[index])
                if (resolvedChild == null)
                {
                    if (!create)
                    {
                        return null;
                    }
                    resolvedChild = model.createChild(element);  // concrete class may vary
                    resolvedChild.name = path[index];
                    isNew = true;
                    model.addChild(resolvedChild);
                }
                model = resolvedChild;
                index++;
            }
            
            if (isNew)
            {
                // If the model at the end of the path is new, bump its element count
                // (which also increments the element count of each of its ancestors).
                //
                model.initialize();
            }
            return model;
        }

        /**
         * The total line coverage ratio for this segment.
         */
        [Bindable("coverageChange")]
        public function get lineCoverage():Number
        {
            if (numLines == 0)
            {
                return 0;
            }
            return coveredLines / numLines;
        }
        
        /**
         * The number of uncovered lines.
         */
        [Bindable("coverageChange")]
        public function get uncoveredLines():Number
        {
            return numLines - coveredLines;
        }
        
        /**
         * The total line coverage ratio for this segment.
         */
        [Bindable("coverageChange")]
        public function get branchCoverage():Number
        {
            if (numBranches == 0)
            {
                return 0;
            }
            return coveredBranches / numBranches;
        }
        
        /**
         * The number of uncovered branches.
         */
        [Bindable("coverageChange")]
        public function get uncoveredBranches():Number
        {
            return numBranches - coveredBranches;
        }
        
        /**
         * Add some number of lines at or below this model, and by implication 
         * to all of its ancestors.
         */
        public function addLines(n:uint):void
        {
            numLines += n;
            dispatchEvent(new Event(COVERAGE_CHANGE));
            
            if (parent != null)
            {
                parent.addLines(n);
            }
        }
        
        /**
         * Add some number of branches at or below this model, and by implication 
         * to all of its ancestors.
         */
        public function addBranches(n:uint):void
        {
            numBranches += n;
            dispatchEvent(new Event(COVERAGE_CHANGE));
            
            if (parent != null)
            {
                parent.addBranches(n);
            }
        }
        
        /**
         * Add a coverage count to this model, and by implication to all of its ancestors.
         * The coverage count applies to lines at/below this model.
         */
        public function addLineCoverage(n:uint):void
        {
            coveredLines += n;
            dispatchEvent(new Event(COVERAGE_CHANGE));
            
            if (parent != null)
            {
                parent.addLineCoverage(n);
            }
        }
        
        /**
         * Add a coverage count to this model, and by implication to all of its ancestors.
         * The coverage count applies to branches at/below this model.
         */
        public function addBranchCoverage(n:uint):void
        {
            coveredBranches += n;
            dispatchEvent(new Event(COVERAGE_CHANGE));
            
            if (parent != null)
            {
                parent.addBranchCoverage(n);
            }
        }
        
        public function clearCoverageData():void
        {
            coveredBranches = coveredLines = 0;
            for each (var child:SegmentModel in children)
            {
                child.clearCoverageData();
            }
        }
        
        public function toXML():XML
        {
            var element:XML = createXmlElement();
            populateXmlElement(element);
            for each (var child:SegmentModel in children)
            {
                element.appendChild(child.toXML());
            }
            return element;
        }

        public function fromXML(xml:XML):void
        {
            parseXmlElement(xml);
            if (xml.children().length() > 0)
            {
                for each (var childXml:XML in xml.children())
                {
                   // see if there is a model matching this child XML element
                   var model:SegmentModel = childMap[childXml.@name];
                   if (model == null)
                   {
                       // there isn't, so make one...
                       model = createChildFromXml(childXml);
                       if (model == null)
                       {
                           // could not make child element from XML spec
                           continue;
                       }
                       // add new child to this model and initialize it
                       model.name = childXml.@name;
                       addChild(model);
                       model.fromXML(childXml);
                       model.initialize();
                   }
                   else
                   {
                       // We do not initialize the child model here, because it would redundantly count branches
                       // and lines.
                       //
                       model.fromXML(childXml);
                   }
                }
            }
        }

        protected function createXmlElement():XML
        {
            throw new Error("createXmlElement must be overridden.");
        }
        
        protected function parseXmlElement(xml:XML):void
        {
        }

        protected function populateXmlElement(xml:XML):void
        {
            xml.@name = name;
            xml.@lineCoverage = lineCoverage.toPrecision(4);
            xml.@coveredLines = coveredLines;
            xml.@lines = numLines;
            xml.@branchCoverage = branchCoverage.toPrecision(4);
            xml.@coveredBranches = coveredBranches;
            xml.@branches = numBranches;
        }
    }
}
