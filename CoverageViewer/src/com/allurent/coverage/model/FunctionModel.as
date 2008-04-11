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
    import mx.collections.ArrayCollection;
    
    /**
     * Model for a single function in the application.
     */
    [Bindable]
    public class FunctionModel extends SegmentModel
    {
        /**
         * Construct a new FunctionModel. 
         */
        public function FunctionModel()
        {
        }
        
        override public function addChild(child:SegmentModel):void
        {
            super.addChild(child);
            classModel.lineModelMap[child.name] = child;
        }
        
        public function get classModel():ClassModel
        {
            return ClassModel(parent);
        } 

        public function get coverageModel():CoverageModel
        {
            var p:SegmentModel = parent;
            while (p != null)
            {
                if (p is CoverageModel)
                {
                    return CoverageModel(p);
                }
                p = p.parent;
            }
            return null;
        } 

        override public function createChild():SegmentModel
        {
            return new LineModel();
        }
        
        override protected function createXmlElement():XML
        {
            return <function/>;
        }
    }
}
