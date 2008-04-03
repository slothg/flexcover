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
    import com.allurent.coverage.model.CoverageElement;
    import com.allurent.coverage.model.CoverageModel;
    import com.allurent.coverage.model.ProjectModel;
    import com.allurent.coverage.parse.MetadataParser;
    
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.net.LocalConnection;
    
    import mx.controls.Alert;
    
    /**
     * Overall Controller for actions in the Coverage Viewer application. 
     * 
     */
    public class Controller
    {
        [Bindable]
        public var project:ProjectModel = new ProjectModel();
        
        [Bindable]
        public var coverageModel:CoverageModel = new CoverageModel();
        
        // LocalConnection open for receiving coverage data from live instrumented apps
        private var conn:LocalConnection;
        
        /**
         * Load an XML project definition file.
         *  
         * @param file the project file to be loaded.
         */
        public function loadProject(file:File):void
        {
            var input:FileStream = new FileStream();
            input.open(file, FileMode.READ);
            var fileContents:String = input.readUTFBytes(input.bytesAvailable);
            input.close();
            
            project = new ProjectModel();
            project.fromXML(new XML(fileContents));
            loadProjectContents();
        }
        
        /**
         * Load a new coverage model from the currently active project definition. 
         * Note that this definition need not have been read from a project file, but may
         * have been constructed directly from command line options.
         */
        public function loadProjectContents():void
        {
            for each (var metadataFile:String in project.metadataFiles)
            {
                new MetadataParser(coverageModel, project).parseFile(new File(metadataFile));
            }
        }
        
        /**
         * Handle a map of coverage keys and execution counts received over our LocalConnection
         * from an instrumented application.
         *  
         * @param keyMap a map whose keys are coverage keys (see CoverageElement) and whose values
         * are incremental execution counts for those same keys since the last transmission from
         * the instrumented app.
         */
        public function coverageData(keyMap:Object):void
        {
            for (var key:String in keyMap)
            {
                var element:CoverageElement = CoverageElement.fromString(key);
                if (element != null)
                {
                    var count:uint = keyMap[key];
                    coverageModel.recordCoverageElement(element, count);
                }
            } 
        }

        public function close():void
        {
        }

        /**
         * Set up the LocalConnection that listens for incoming coverage data from an instrumented program.
         * @param connectionName the name to use for the connection.
         */
        public function attachConnection(connectionName:String):void
        {
            // Set up our LocalConnection.  Note that the Controller handles
            conn = new LocalConnection();
            conn.allowDomain("*");
            conn.client = this;
            try
            {
                conn.connect(connectionName);        
            }
            catch (error:ArgumentError)
            {
                Alert.show(error.message);
            }
        }
    }
}
