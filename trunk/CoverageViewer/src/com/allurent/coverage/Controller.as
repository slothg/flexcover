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
    import com.adobe.ac.util.IOneTimeInterval;
    import com.allurent.coverage.event.CoverageEvent;
    import com.allurent.coverage.model.CoverageElement;
    import com.allurent.coverage.model.CoverageElementContainer;
    import com.allurent.coverage.model.CoverageModel;
    import com.allurent.coverage.model.ElementModel;
    import com.allurent.coverage.model.ProjectModel;
    import com.allurent.coverage.parse.CoverageReportParser;
    import com.allurent.coverage.parse.MetadataParser;
    import com.allurent.coverage.parse.TraceLogParser;
    
    import flash.desktop.NativeApplication;
    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.net.LocalConnection;
    
    import mx.controls.Alert;
    
    /** This event is dispatched when the coverage model is updated with new metadata. */
    [Event(name="coverageModelChange",
            type="com.allurent.coverage.event.CoverageEvent")]
    /** Recording of coverage data started. */
    [Event(name="recordingStart",
            type="com.allurent.coverage.event.CoverageEvent")]
    /** Recording of coverage data ended. */
    [Event(name="recordingEnd",
            type="com.allurent.coverage.event.CoverageEvent")]
    /** Applying recorded coverage data to coverage model starts. */
    [Event(name="parsingStart",
            type="com.allurent.coverage.event.CoverageEvent")]
    /** Applying recorded coverage data to coverage model ends. */
    [Event(name="parsingEnd",
            type="com.allurent.coverage.event.CoverageEvent")]                            
    /**
     * Overall Controller for actions in the Coverage Viewer application. 
     * 
     */
    public class Controller extends EventDispatcher
    {
        [Bindable]
        public var project:ProjectModel;
        
        [Bindable]
        public var coverageModel:CoverageModel;
        [Bindable]
        public var isRecording:Boolean;
        [Bindable]
        public var isCoverageDataCleared:Boolean;        
        [Bindable]
        public var currentRecording:String;
                        
        /**
         * Flag indicating that application should exit when instrumented app is done.
         * and all pending data has been written.
         */ 
        public var autoExit:Boolean;
        
        /**
         * Flag indicating that coverage data should only be recorded internally for
         * coverage elements possessing loaded metadata from compilation.
         */
        public var constrainToModel:Boolean;
        
        /**
         * Output file to which coverage data should be written when application is done.
         */
        public var coverageOutputFile:File;
        
        private var coverageElementsContainer:Array;
        
        // LocalConnection open for receiving coverage data from live instrumented apps
        private var conn:LocalConnection;
        
        private var timer:IOneTimeInterval;
        
        public function Controller(timer:IOneTimeInterval)
        {
        	this.timer = timer;
        	project = new ProjectModel();
        	coverageModel = new CoverageModel();
        	currentRecording = "";
        	isCoverageDataCleared = true;
        	constrainToModel = true;
        	coverageElementsContainer = new Array()
        }
        
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
                loadMetadata(new File(metadataFile));
            }

            for each (var traceLog:String in project.traceLogs)
            {
                loadTraceLog(new File(traceLog));
            }
        }

        /**
         * Load a metadata file into the project. 
         */
        public function loadMetadata(metadataFile:File):void
        {
            new MetadataParser(coverageModel, project).parseFile(metadataFile);
            dispatchCoverageModelChangeEvent();
        }  

        /**
         * Load a trace log file into the project. 
         */
        public function loadTraceLog(traceLog:File):void
        {
            new TraceLogParser(coverageModel, project).parseFile(traceLog);
        }
        
        /**
         * Load a coverage report into the project. 
         */
        public function loadCoverageReport(report:File):void
        {
            var newCoverageModel:CoverageModel = new CoverageModel();
            new CoverageReportParser(newCoverageModel, project).parseFile(report);
            coverageModel = newCoverageModel;
            isCoverageDataCleared = false;
            dispatchCoverageModelChangeEvent();
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
        	var isRecording:Boolean = false;
        	
            for (var key:String in keyMap)
            {
            	isRecording = true;
                var element:CoverageElement = CoverageElement.fromString(key);
                if (element != null)
                {
                    var count:uint = keyMap[key];
                    currentRecording = element.packageName + "." + element.className;
                    
                    coverageElementsContainer.push(
                        new CoverageElementContainer(
                            ElementModel(coverageModel.resolveCoverageElement(element, !constrainToModel)), 
                            count));                     
                }
                timer.delay(4000, handleRecordingTimeout);
            }
            
            if(isRecording && !this.isRecording)
            {
            	startCoverageRecording();
            }
            else if(!isRecording && this.isRecording)
            {
            	endCoverageRecording();
            }
        }
        
        private function startCoverageRecording():void
        {
            dispatchEvent(new CoverageEvent(CoverageEvent.RECORDING_START));
            this.isRecording = true;        	
        }
        
        private function endCoverageRecording():void
        {
	        this.isRecording = false;
	        currentRecording = "";
	        timer.clear();
	        dispatchEvent(new CoverageEvent(CoverageEvent.RECORDING_END));        	
        }
        
        private function handleRecordingTimeout():void
        {
        	endCoverageRecording();
        }
        
        public function applyCoverageData():void
        {
        	dispatchEvent(new CoverageEvent(CoverageEvent.PARSING_START));        	
        	var container:Array = coverageElementsContainer;
        	var numberOfContainers:int = container.length;
        	for(var i:int; i < numberOfContainers; i++)
        	{
        		var item:CoverageElementContainer = CoverageElementContainer(container[i]);
                coverageModel.addExecutionCount(item.element, item.count);
        	}
        	
            if(numberOfContainers > 0)
            {
                isCoverageDataCleared = false;
            }        	
        	
        	coverageElementsContainer = new Array();
        	dispatchEvent(new CoverageEvent(CoverageEvent.PARSING_END));
        }
        
        public function clearCoverageData():void
        {
            coverageModel.clearCoverageData();
            isCoverageDataCleared = true;
        }

        /**
         * Handler called by instrumented program when coverage ends. 
         */
        public function coverageEnd():void
        {
            if (coverageOutputFile != null)
            {
                writeReport(coverageOutputFile);
            }
            if (autoExit)
            {
                NativeApplication.nativeApplication.exit();
            }
        }

        /**
         * Handle closure of the application. 
         * 
         */
        public function close():void
        {
            if (coverageOutputFile != null)
            {
                writeReport(coverageOutputFile);
            }
            NativeApplication.nativeApplication.exit();
        }

        /**
         * Set up the LocalConnection that listens for incoming coverage data from an instrumented program.
         * @param connectionName the name to use for the connection.
         */
        public function attachConnection(connectionName:String):void
        {
            if (conn != null)
            {
                // Don't set this up multiple times.
                return;
            }
            
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
                if (error.errorID == 2082)
                {
                    Alert.show("Another program has already opened a LocalConnection with id '"
                                + connectionName + "'.  No coverage data will be recorded.",
                                "Coverage Recording Error");
                }
                else
                {
                    Alert.show(error.message, "Coverage Recording Error");
                }
                conn == null;
            }
        }
        
        /**
         * Write accumulated coverage data to an output file if specified. 
         */
        public function writeReport(f:File):void
        {
            var out:FileStream = new FileStream();
            out.open(f, FileMode.WRITE);
            out.writeUTFBytes(coverageModel.toXML().toXMLString());
            out.close();
        }
        
        private function dispatchCoverageModelChangeEvent():void
        {
            dispatchEvent(new CoverageEvent(
            						CoverageEvent.COVERAGE_MODEL_CHANGE, 
            						coverageModel));
        }
    }
}