package com.allurent.coverage
{
	import com.allurent.coverage.model.IRecorder;
	import com.allurent.coverage.model.ProjectModel;
	import com.anywebcam.mock.Mock;
	
	import flash.events.Event;
	import flash.filesystem.File;

	public class ControllerMock implements IController
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
		
		public function ControllerMock(ignoreMissing:Boolean=true)
		{
			mock = new Mock(this, ignoreMissing);
		}
		
		public function setup():void
		{
			mock.setup();
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
	}
}