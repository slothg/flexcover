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
	import com.anywebcam.mock.Mock;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;

	public class ControllerMock extends EventDispatcher implements IController
	{
        public var mock:Mock;
        
		public function get project():ProjectModel
		{
			return mock.project;
		}
		
		public function get recorder():IRecorder
		{
			return mock.recorder;
		}
		
		public function get currentStatusMessage():String
		{
			return mock.currentStatusMessage;
		}
		
		public function get isCoverageDataCleared():Boolean
		{
			return mock.isCoverageDataCleared;
		}
		
        public function set isCoverageDataCleared(value:Boolean):void
        {
            mock.isCoverageDataCleared = value;
        }		
		
		public function ControllerMock(ignoreMissing:Boolean=true)
		{
			mock = new Mock(this, ignoreMissing);
		}
		
        public function setup(coverageModel:ICoverageModel, 
                              recorder:IRecorder, 
                              communicator:ICoverageCommunicator):void
        {
        	mock.setup(coverageModel, recorder, communicator);
        }
		
		public function close():void
		{
			mock.close();
		}
		
		public function processCommandLineArguments(arguments:Array):void
		{
			mock.processCommandLineArguments(arguments);
		}
		
		public function processFileArgument(files:Array):void
		{
			mock.processFileArgument(files);
		}
		
		public function writeReport(file:File):void
		{
			mock.writeReport(file);
		}
		
		public function applyCoverageData():void
		{
			mock.applyCoverageData();
		}
		
        public function clearCoverageData():void
        {
            mock.clearCoverageData();
        }

        public function endCoverageRecording():void
        {
            mock.endCoverageRecording();
        }
        
		/*
        public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
        {
           mock.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        
        public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
        {
            mock.removeEventListener(type, listener, useCapture);
        }
        
        public function dispatchEvent(event:Event):Boolean
        {
            return mock.dispatchEvent(event);
        }
        
        public function hasEventListener(type:String):Boolean
        {
            return mock.hasEventListener(type);
        }
        
        public function willTrigger(type:String):Boolean
        {
            return mock.willTrigger(type);
        }
        */		
	}
}