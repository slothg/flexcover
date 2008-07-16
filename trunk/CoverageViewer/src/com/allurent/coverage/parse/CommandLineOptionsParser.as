package com.allurent.coverage.parse
{
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.event.CoverageModelEvent;
	import com.allurent.coverage.model.CoverageModel;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	
	[Event(name="coverageModelChange",
			type="com.allurent.coverage.event.CoverageModelEvent")]	
	public class CommandLineOptionsParser extends EventDispatcher
	{
		private var controller:Controller;		
        // Name of LocalConnection to use for receiving data
        private var connectionName:String = "_flexcover";
        	
		public function CommandLineOptionsParser(controller:Controller)
		{
			this.controller = controller;
		}		
		
        /**
         * Process command line options prior to full startup. 
         */		
		public function parse(args:Array):void
		{
            var option:String = null;
            for each (var arg:String in args)
            {
                if (arg.length > 0 && arg.charAt(0) == "-")
                {
                    // Got an option, chuck it into a variable to affect subsequent non-option args.
                    option = arg.substring(1);
                }
                else if (option != null)
                {
                    // All non-option strings are treated as arguments to be processed in light
                    // of the last option string that was seen.  There's no argument
                    // that is not associated with some option.
                    //
                    switch(option)
                    {
                        case "output":
                            controller.coverageOutputFile = new File(arg);
                            controller.autoExit = true;
                            break;
                            
                        case "coverage-metadata":
                            controller.loadMetadata(new File(arg));
                            break;
                            
                        case "trace-log":
                            controller.loadTraceLog(new File(arg));
                            break;
                            
                        case "source-path":
                            controller.project.sourcePath.addItem(new File(arg));
                            break;
                            
                        case "coverage-output":
                            // TODO: set up output filename for coverage data.
                            break;
                            
                        case "connection-name":
                            connectionName = arg;
                            break;
                        
                        default:
                            Alert.show("Unknown option: " + option);
                    }
                    option = null;
                }
                else
                {
		        	var parser:FileParser = new FileParser(controller);
		        	parser.addEventListener(
		        					CoverageModelEvent.COVERAGE_MODEL_CHANGE, 
		        					dispatchEvent);
		        	parser.parse(new File(arg));
                }
            }
            
            // After processing all options, load the models up from the project
            // and display the top-level report view.
            dispatchCoverageModelChange(controller.coverageModel);
            
            controller.attachConnection(connectionName);
		}
        
        private function dispatchCoverageModelChange(model:CoverageModel):void
        {
            dispatchEvent(new CoverageModelEvent(
            						CoverageModelEvent.COVERAGE_MODEL_CHANGE, 
            						model));        	
        }
	}
}