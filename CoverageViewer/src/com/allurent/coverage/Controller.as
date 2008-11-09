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
 
//TODO: way too many responsiblities. Needs refactoring.
package com.allurent.coverage
{
    import com.allurent.coverage.event.CoverageEvent;
    import com.allurent.coverage.model.ICoverageModel;
    import com.allurent.coverage.model.application.IRecorder;
    import com.allurent.coverage.model.application.ProjectModel;
    import com.allurent.coverage.model.application.Recorder;
    import com.allurent.coverage.parse.CommandLineOptionsParser;
    import com.allurent.coverage.parse.CoverageReportParser;
    import com.allurent.coverage.parse.FileParser;
    import com.allurent.coverage.parse.MetadataParser;
    import com.allurent.coverage.parse.TraceLogParser;
    import com.allurent.coverage.service.CoverageCommunicator;
    import com.allurent.coverage.service.ICoverageCommunicator;
    
    import flash.desktop.NativeApplication;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    
    /** This event is dispatched when the coverage model is updated with new metadata. */
    [Event(name="coverageModelChange",
            type="com.allurent.coverage.event.CoverageEvent")]                       
    /** Recording of coverage data ended. Bubbled up from Recorder */
    [Event(name="recordingEnd",
            type="com.allurent.coverage.event.CoverageEvent")]    
    
    
    /**
     * Overall Controller for actions in the Coverage Viewer application. 
     * 
     */
    public class Controller extends EventDispatcher implements IController
    {
        [Bindable]
        public var project:ProjectModel;
        [Bindable]
        public var recorder:IRecorder;
        public var communicator:ICoverageCommunicator;
        
        [Bindable]
        public var coverageModel:ICoverageModel;
        [Bindable]
        public var isCoverageDataCleared:Boolean;
        
        [Bindable]
        public var currentStatusMessage:String;        
        
        /**
         * Flag indicating that application should exit when instrumented app is done.
         * and all pending data has been written.
         */ 
        public var autoExit:Boolean;
        
        /**
         * Output file to which coverage data should be written when application is done.
         */
        public var coverageOutputFile:File;        
        
        public function Controller(project:ProjectModel)
        {
        	currentStatusMessage = "";
        	isCoverageDataCleared = true;
        	
            this.project = project;
        }
        
        public function setup(coverageModel:ICoverageModel, 
                              recorder:IRecorder, 
                              communicator:ICoverageCommunicator):void
        {
            this.coverageModel = coverageModel;        
            this.recorder = recorder;
            this.recorder.addEventListener(CoverageEvent.RECORDING_END, handleRecorderEvents);
            this.recorder.addEventListener(CoverageEvent.PARSING_END, handleRecorderEvents);            
            
            this.communicator = communicator;
            this.communicator.addEventListener(CoverageCommunicator.COVERAGE_END_EVENT, 
                                               onCoverageEnd);                  	
        }
        
        public function processCommandLineArguments(arguments:Array):void
        {
            var parser:CommandLineOptionsParser = new CommandLineOptionsParser(this);            
            parser.addEventListener(CoverageEvent.COVERAGE_MODEL_CHANGE, dispatchEvent);            
            parser.parse(arguments);        	
        }
        
        public function processFileArgument(files:Array):void
        {
            var parser:FileParser = new FileParser(this);
            parser.addEventListener(
                            CoverageEvent.COVERAGE_MODEL_CHANGE, 
                            dispatchEvent);
            for each (var f:File in files)
            {
                parser.parse(f);
            }
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
            new CoverageReportParser(coverageModel, project).parseFile(report);
            isCoverageDataCleared = false;
            dispatchCoverageModelChangeEvent();
        }
        
        public function applyCoverageData():void
        {
        	recorder.applyCoverageData();
        }
        
        public function clearCoverageData():void
        {
            coverageModel.clearCoverageData();
            isCoverageDataCleared = true;
        }

        /**
         * Handle closure of the application. 
         * 
         */
        public function close():void
        {
            if (coverageOutputFile != null)
            {
                applyCoverageData();
                writeReport(coverageOutputFile);
            }
            NativeApplication.nativeApplication.exit();
        }
        
        /**
         * Write accumulated coverage data to an output file if specified. 
         */
        public function writeReport(f:File):void
        {
            var out:FileStream = new FileStream();
            out.open(f, FileMode.WRITE);
            out.writeUTFBytes(coverageModel.toXML().toXMLString());
            out.writeUTFBytes("\n");
            out.close();
        }
        
        private function onCoverageEnd(event:Event):void
        {
            if (coverageOutputFile != null)
            {
                applyCoverageData();
                writeReport(coverageOutputFile);
            }
            if (autoExit)
            {
                NativeApplication.nativeApplication.exit();
            }
        }        
        
        private function handleRecorderEvents(event:CoverageEvent):void
        {
        	if(event.type == CoverageEvent.PARSING_END && event.hasParsed)
        	{
        		isCoverageDataCleared = false;
        	}
            currentStatusMessage = Recorder(event.currentTarget).currentStatusMessage;
            dispatchEvent(event);
        }
        
        private function dispatchCoverageModelChangeEvent():void
        {
            dispatchEvent(new CoverageEvent(
            						CoverageEvent.COVERAGE_MODEL_CHANGE, 
            						coverageModel));
        }
    }
}