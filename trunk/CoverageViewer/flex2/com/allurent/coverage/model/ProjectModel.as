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
    import flash.filesystem.File;
    
    import mx.collections.ArrayCollection;
    
    /**
     * Model representing an ItDepends project, which is a set of one or more link reports, SWFX
     * documents with offsets, source path entries, catalog names and a main class name. 
     * @author joeb
     * 
     */
    [Bindable]
    public class ProjectModel
    {
        public var metadataFiles:ArrayCollection = new ArrayCollection();
        public var sourcePath:ArrayCollection = new ArrayCollection();
        public var excludeKeyRegexp:RegExp = /_bindingExprs@/;
        
        /**
         * Parse some XML into this project model.
         */        
        public function fromXML(xml:XML):void
        {
            for each (var metadata:XML in xml.metadata.file)
            {
                metadataFiles.addItem(metadata.text().toString());
            }
            for each (var dir:XML in xml.sourcePath.directory)
            {
                sourcePath.addItem(new File(dir.text().toString()));
            }
        }
        
        /**
         * Convert this project model into XML to be saved as a project definition. 
         */
        public function toXML():XML
        {
            var project:XML = <project/>;

            var metadataNode:XML = <metadata/>;
            for each (var file:String in metadataFiles)
            {
                metadataNode.appendChild(<file>{file}</file>);
            }
            project.appendChild(metadataNode);
            
            var sourcePathNode:XML = <sourcePath/>;
            for each (var dir:File in sourcePath)
            {
                sourcePathNode.appendChild(<directory>{dir.nativePath}</directory>);
            }
            project.appendChild(sourcePathNode);

            return project;
        }
        
        /**
         * Get the File for a source filename by searching in the set of source paths
         * for this ProjectModel. 
         */
        public function findSourceFile(filename:String):File
        {
            for each (var path:File in sourcePath)
            {
                var f:File = path.resolvePath(filename);
                if (f.exists)
                {
                    return f;
                }
            }
            return null;
        }
        
        /**
         * Obtain a filename for some source file corresponding to a Class.  Look for both
         * MXML and AS definitions.  Returns null if no file could be found.
         *  
         */

        public function findClass(c:ClassModel):File
        {
            var f:File;
            
            // First try an explicit filename if one is known for this class.
            if (c.pathname != null)
            {
                f = new File(c.pathname);
                if (f.exists)
                {
                    return f;
                }
            }
            
            // That didn't work, so search the source path list for AS and MXML files.
            var name:String = c.qualifiedName.replace(/\./g, File.separator);
            f = findSourceFile(name + ".as");
            if (f != null)
            {
                return f;
            }
            return findSourceFile(name + ".mxml");
        }
    }
}
