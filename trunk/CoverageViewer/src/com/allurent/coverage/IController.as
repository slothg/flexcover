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
	import com.allurent.coverage.model.ICoverageModel;
	import com.allurent.coverage.model.application.IRecorder;
	import com.allurent.coverage.model.application.ProjectModel;
	import com.allurent.coverage.service.ICoverageCommunicator;
	
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	
	public interface IController extends IEventDispatcher
	{
		[Bindable("propertyChange")]
        function get project():ProjectModel;

        [Bindable("propertyChange")]
        function get recorder():IRecorder;
        [Bindable("propertyChange")]
        function get currentStatusMessage():String;
        [Bindable("propertyChange")]
        function get isCoverageDataCleared():Boolean;        
        function set isCoverageDataCleared(value:Boolean):void;
        
        function setup(coverageModel:ICoverageModel, 
                       recorder:IRecorder, 
                       communicator:ICoverageCommunicator):void
        
        function close():void;
        
        function processCommandLineArguments(arguments:Array):void
        function processFileArgument(files:Array):void;
        function writeReport(file:File):void;
        
        function applyCoverageData():void;
        function clearCoverageData():void;  
        function endCoverageRecording():void;      
	}
}