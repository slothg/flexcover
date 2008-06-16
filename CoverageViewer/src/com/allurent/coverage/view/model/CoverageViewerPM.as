package com.allurent.coverage.view.model
{
	import com.allurent.coverage.Controller;
	import com.allurent.coverage.model.CoverageModel;
	
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	
	import mx.collections.IHierarchicalCollectionView;
	import mx.controls.Alert;
	
	public class CoverageViewerPM
	{
		private static const COVERAGE_MEASURE_BRANCH:int = 0;
		private static const COVERAGE_MEASURE_LINE:int = 1;			
		
        [Bindable]
        public var searchPM:SearchPM;	
        // Top level Controller for the CoverageViewer application
        [Bindable]
        public var controller:Controller;        
        [Bindable]
        public var coverageModel:CoverageModel;    
		
		
		[Bindable]
		public var branchCoverageModel:IHierarchicalCollectionView;
		[Bindable]
		public var lineCoverageModel:IHierarchicalCollectionView;
		
		
		private var _currentCoverageModel:IHierarchicalCollectionView;
		public function get currentCoverageModel():IHierarchicalCollectionView
		{
			return _currentCoverageModel;
		}
		public function set currentCoverageModel(value:IHierarchicalCollectionView):void
		{
			_currentCoverageModel = value;
			searchPM.currentCoverageModel = value;
		}
		
		private var currentCoverageMeasureIndex:int;
		
        // Name of LocalConnection to use for receiving data
        private var connectionName:String = "_flexcover";  		
		
		public function CoverageViewerPM(controller:Controller)
		{
            this.controller = controller
            searchPM = new SearchPM();
            currentCoverageMeasureIndex = CoverageViewerPM.COVERAGE_MEASURE_BRANCH;
		}
		
        public function inputFileSelected(e:Event):void
        {
            processFileArgument(e.target as File);
        }
        
        public function outputFileSelected(e:Event):void
        {
            var file:File = File(e.target);
            controller.writeReport(file);
        }
        		
        public function handleDragDrop(e:NativeDragEvent):void
        {
            if (hasValidDragInFormat(e))
            {
                var files:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
                for each (var f:File in files)
                {
                    processFileArgument(f);
                }
            }
        }
        
        public function hasValidDragInFormat(e:NativeDragEvent):Boolean
        {
        	return e.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT);
        }
        
        /**
         * When the main app window closes, exit the application after first cleaning up.
         *  
         */
        public function onClose():void
        {
            controller.close();
        }    
		
        /**
         * When we get our invoke event, process options.  Only then can we attach
         * the LocalConnection (since this is option-dependent). 
         */
        public function handleInvoke(e:InvokeEvent):void
        {
            processOptions(e.arguments);
            controller.attachConnection(connectionName);
        }
		
        /**
         * Process command line options prior to full startup. 
         */
        public function processOptions(args:Array):void
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
                    processFileArgument(new File(arg));
                }
            }
            
            // After processing all options, load the models up from the project
            // and display the top-level report view.
            //
            coverageModel = controller.coverageModel;     
        }

        private function processFileArgument(f:File):void
        {
            if (f.name.match(/\.cvm$/))
            {
                controller.loadMetadata(f);
            }
            else if (f.name.match(/\.cvr/))
            {
                controller.loadCoverageReport(f);
                coverageModel = controller.coverageModel;
            }
        }		
		
		public function changeCoverageMeasure(index:int):void
		{
			if(currentCoverageMeasureIndex == CoverageViewerPM.COVERAGE_MEASURE_BRANCH)
			{
				currentCoverageMeasureIndex = index;
			}
			else if(currentCoverageMeasureIndex == CoverageViewerPM.COVERAGE_MEASURE_LINE)
			{
				currentCoverageMeasureIndex = index;
			}
			else
			{
				throw new Error("Invalid Coverage Measure");
			}
			applyCurrentCoverageModel();		
		}
		
		public function applyCurrentCoverageModel():void
		{
			if(currentCoverageMeasureIndex == CoverageViewerPM.COVERAGE_MEASURE_BRANCH)
			{
				currentCoverageModel = branchCoverageModel;
			}
			else if(currentCoverageMeasureIndex == CoverageViewerPM.COVERAGE_MEASURE_LINE)
			{
				currentCoverageModel = lineCoverageModel;
			}
		}		
	}
}