package com.allurent.coverage
{
	import com.allurent.coverage.model.IRecorder;
	import com.allurent.coverage.model.ProjectModel;
	
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
        
        function setup():void
        function close():void;
        
        function processCommandLineArguments(arguments:Array):void
        function processFileArgument(files:Array):void;
        function writeReport(file:File):void;
        
        function applyCoverageData():void;
        function clearCoverageData():void;        
	}
}