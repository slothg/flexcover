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
    import flash.events.EventDispatcher;
    
    /**
     * A ClassModel represents a Class whose coverage can be monitored. 
     * @author joeb
     */
    [Bindable]
    public class ClassModel extends SegmentModel
    {
        /** Map from all line numbers in the source to individual LineModels, which are grandchildren. */
        public var lineModelMap:Object = {};
        
        /** Map from all line numbers in the transformed source to arrays of BranchModels associated with that line. */
        public var branchModelMap:Object = {};
        
        /** Pathname of the source file associated with this ClassModel, if gleaned from the metadata. */
        public var pathname:String;
        
        /** Pathname of the transformed source file associated with this ClassModel, if gleaned from the metadata. */
        public var transformedPathname:String;
        
        /**
         * Construct a new ClassModel. 
         */
        public function ClassModel()
        {
        }
        
        public function addElementModel(m:ElementModel):void
        {
            if (m is LineModel)
            {
                lineModelMap[m.name] = m;
            }
            else if (m is BranchModel)
            {
                var bm:BranchModel = m as BranchModel;
                var lineEntry:Array = branchModelMap[bm.line]; 
                if (lineEntry == null)
                {
                    lineEntry = [];
                    branchModelMap[bm.line] = lineEntry;
                }
                lineEntry.push(bm);
            }
        }
        
        override public function createChild(element:CoverageElement):SegmentModel
        {
            return new FunctionModel();
        }
        
        override public function createChildFromXml(childXml:XML):SegmentModel
        {
            return new FunctionModel();
        }
        
        public function get packageName():String
        {
            return parent.name;
        }
        
        /**
         * The fully qualified name of this Class with package prefix and "." delimiters. 
         */
        public function get qualifiedName():String
        {
            return ((packageName == "") ? "" : (packageName + ".")) + name;
        }
        
        override protected function createXmlElement():XML
        {
            return <class/>;
        }
        
        override protected function parseXmlElement(xml:XML):void
        {
            super.parseXmlElement(xml);
            pathname = xml.@pathname;
            transformedPathname = xml.@transformedPathname;
        }

        override protected function populateXmlElement(xml:XML):void
        {
            super.populateXmlElement(xml);
            xml.@pathname = pathname;
            xml.@transformedPathname = transformedPathname;
        }        
    }
}
