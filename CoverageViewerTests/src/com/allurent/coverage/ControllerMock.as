package com.allurent.coverage
{
	import com.allurent.coverage.model.IRecorder;
	import com.allurent.coverage.model.ProjectModel;
	
	import flash.events.Event;
	import flash.filesystem.File;

	public class ControllerMock implements IController
	{
		public var isClearCoverageDataCalled:Boolean;
		public var isWriteReportCalled:Boolean;

		public function get project():ProjectModel
		{
			return null;
		}
		
		public function get recorder():IRecorder
		{
			return null;
		}
		
		public function get currentStatusMessage():String
		{
			return null;
		}
		
		public function get isCoverageDataCleared():Boolean
		{
			return false;
		}
		
		public function setup():void
		{
		}
		
		public function close():void
		{
		}
		
		public function processCommandLineArguments(arguments:Array):void
		{
		}
		
		public function processFileArgument(files:Array):void
		{
		}
		
		public function writeReport(f:File):void
		{
			isWriteReportCalled = true;
		}
		
		public function applyCoverageData():void
		{
		}
		
		public function clearCoverageData():void
		{
			isClearCoverageDataCalled = true;
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return false;
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return false;
		}
		
		public function willTrigger(type:String):Boolean
		{
			return false;
		}
		
	}
}