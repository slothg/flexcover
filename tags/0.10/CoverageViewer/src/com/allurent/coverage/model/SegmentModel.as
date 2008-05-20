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
    public class SegmentModel extends EventDispatcher
    {
        /** Number of individual lines that are direct or indirect descendants of this one. */
        [Bindable]
        public var numLines:Number = 0;
        
        /** Number of covered lines at/below this segment. */
        [Bindable]
        public var numCovered:Number = 0;

        /** Internal name. */
        [Bindable]
        public var name:String;
        
        /** child SegmentModels of this model. */
        [Bindable]
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
        
        /**
         * Factory method to create a child of this SegmentModel.  Overridden by the various 
         * model subclasses to ensure that their children are of the correct type.
         */
        public function createChild():SegmentModel
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
         * Resolve a child element by its name
         *  
         * @param pathElement a key for the child model element
         * @return the resolved element, or null if not found.
         */
        public function resolvePathComponent(pathElement:String):SegmentModel
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
        public function resolvePath(path:Array, create:Boolean = false):SegmentModel
        {
            var index:uint = 0;
            var model:SegmentModel = this;
            var isNew:Boolean = false;
            
            while (index < path.length)
            {
                var resolvedChild:SegmentModel = model.resolvePathComponent(path[index])
                if (resolvedChild == null)
                {
                    if (!create)
                    {
                        return null;
                    }
                    resolvedChild = model.createChild();  // concrete class may vary
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
                model.addLines(1);
            }
            return model;
        }

        /**
         * The total coverage ratio for this segment.
         */
        [Bindable("coverageChange")]
        public function get coverage():Number
        {
            if (numLines == 0)
            {
                return 0;
            }
            return numCovered / numLines;
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
         * Add a coverage count to this model, and by implication to all of its ancestors.
         * The coverage count applies to lines at/below this model.
         */
        public function addCoverage(n:uint):void
        {
            numCovered += n;
            dispatchEvent(new Event(COVERAGE_CHANGE));
            
            if (parent != null)
            {
                parent.addCoverage(n);
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
                var childName:String = createChild().createXmlElement().name().toString();
                for each (var childXml:XML in xml.elements(childName))
                {
                    var model:SegmentModel = createChild();
                    model.name = childXml.@name;
                    addChild(model); 
                    model.fromXML(childXml);
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
            xml.@coverage = coverage.toPrecision(4);
            xml.@coveredLines = numCovered;
            xml.@lines = numLines;
        }
    }
}