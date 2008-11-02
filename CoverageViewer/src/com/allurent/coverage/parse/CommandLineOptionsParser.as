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
package com.allurent.coverage.parse
{
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.event.CoverageEvent;
	import com.allurent.coverage.model.ICoverageModel;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	
	[Event(name="coverageModelChange",
			type="com.allurent.coverage.event.CoverageEvent")]	
	public class CommandLineOptionsParser extends EventDispatcher
	{
		private var controller:Controller;
        
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
                    processOption(option, arg);
                    option = null;
                }
                else
                {
		        	var parser:FileParser = new FileParser(controller);
		        	parser.addEventListener(
		        					CoverageEvent.COVERAGE_MODEL_CHANGE, 
		        					dispatchEvent);
		        	parser.parse(new File(arg));
                }
            }

            if (option != null)
            {
                processOption(option, null);
            }            
            
            // After processing all options, load the models up from the project
            // and display the top-level report view.
            dispatchCoverageModelChange(controller.coverageModel);
            
            controller.communicator.attachConnection();
		}
        
        private function processOption(option:String, arg:String):void
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
                    controller.communicator.coverageDataConnectionName = arg;
                    break;
                    
                case "quit":
                    controller.close();
                    break;
                
                default:
                    Alert.show("Unknown option: " + option);
            }
        }

        private function dispatchCoverageModelChange(model:ICoverageModel):void
        {
            dispatchEvent(new CoverageEvent(
            						CoverageEvent.COVERAGE_MODEL_CHANGE, 
            						model));        	
        }
	}
}