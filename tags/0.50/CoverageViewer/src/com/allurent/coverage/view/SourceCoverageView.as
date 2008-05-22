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
 package com.allurent.coverage.view
 {
    import com.allurent.coverage.model.BranchModel;
    import com.allurent.coverage.model.ClassModel;
    import com.allurent.coverage.model.ElementModel;
    import com.allurent.coverage.model.LineModel;
    import com.allurent.coverage.model.ProjectModel;
    
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    
    import mx.controls.HTML;
    
    public class SourceCoverageView extends HTML
    {
        [Bindable]
        public var project:ProjectModel;

        [Bindable]
        public var classModel:ClassModel;
        
        /** Array of source lines in this view */
        [Bindable]
        public var lines:Array= [];
        
        /**
         * Array of 2-element arrays representing top/bottom Y coordinates of coverage gaps,
         * normalized to a scale at which the height of the entire HTML source view is 1.
         */
        [Bindable]
        public var gapOffsets:Array = [];
        
        /** Object whose keys are line numbers with coverage gaps */
        private var _gapSet:Object = {};

        /** Line number to which this view should be scrolled. */
        private var _scrollLine:int = 0;

        // line states
        private static const NO_ELEMENTS:int = 0;
        private static const UNCOVERED_ELEMENTS:int = 1;
        private static const ALL_ELEMENTS_COVERED:int = 2;
        
        private static const STYLES:Array = [
            "pre {",
            "    background: #ffffff;",
            "    margin-top: 0px;",
            "    margin-bottom: 0px;",
            "}",
            "table {",
            "    border: #dcdcdc 1px solid;",
            "}",
            "td.data {",
            "    background: #f0f0f0;",
            "    border-top: #dcdcdc 1px solid;",
            "    border-right: #dcdcdc 1px solid;",
            "    font-size: 12px;",
            "    padding-right: 3px;",
            "    text-align: right;",
            "}",
            "td.goodCount {",
            "    background: #c0f0c0;",
            "    border-top: #dcdcdc 1px solid;",
            "    border-right: #dcdcdc 1px solid;",
            "    font-size: 12px;",
            "    padding-right: 3px;",
            "    text-align: right;",
            "}",
            "td.badCount {",
            "    background: #f0c0c0;",
            "    border-top: #dcdcdc 1px solid;",
            "    border-right: #dcdcdc 1px solid;",
            "    font-size: 12px;",
            "    padding-right: 3px;",
            "    text-align: right;",
            "}",
            ".goodBranch {",
            "    color: #009900;",
            "    font-weight: bold;",
            "}",
            ".badBranch {",
            "    color: #FF0000;",
            "    font-weight: bold;",
            "}",
            "pre.badSrc {",
            "    background: #f0c0c0;",
            "    margin-top: 0px;",
            "    margin-bottom: 0px;",
            "}"
        ];
            
        public function SourceCoverageView()
        {
            addEventListener(Event.COMPLETE, handleComplete);
        }
        
        /**
         * Display the source for a specific class in some project. 
         */
        public function show(project:ProjectModel, c:ClassModel):void
        {
            this.project = project;
            classModel = c;

            // Find the source file and suck it in.
            var f:File = project.findClass(c);
            var fileContents:String;
            if (f != null)
            {
                var input:FileStream = new FileStream();
                input.open(f, FileMode.READ);
                fileContents = input.readUTFBytes(input.bytesAvailable);
                input.close();
            }
            else
            {
                fileContents = "[source file not found]";
            }

            // Create an HTML wrapper that we will plug the body into.
            var html:XML =
                <html>
                    <head>
                       <style type="text/css">{STYLES.join(" ")}</style>
                    </head>
                    <body>[BODY]</body>
                </html>;

            // Generate the HTML source line by source line, working from a split-out
            // set of lines in the file.  Note that lines[] is zero-based while line numbers
            // in the model are one-based.
            // 
            lines = fileContents.split("\n");
            var newLines:Array = [];
            for (var i:int = 1; i <= lines.length; i++)
            {
                newLines.push('<tr id="line' + i + '">' + getLineHtml(i) + '</tr>');
            }

            // Now set up event listeners on all the element models for this source file, so we can
            // update based on their execution counts.
            //
            for each (var lm:LineModel in classModel.lineModelMap)
            {
                lm.addEventListener(ElementModel.EXECUTION_COUNT_CHANGE, handleLineCoverageChange,
                                    false, 0, true);
            }
            for each (var bml:Array in classModel.branchModelMap)
            {
                for each (var bm:BranchModel in bml)
                {
                    bm.addEventListener(ElementModel.EXECUTION_COUNT_CHANGE, handleBranchCoverageChange,
                                        false, 0, true);
                }
            }
            
            // wrap the whole thing in a happy table tag and stick it into the DOM.
            var sourceText:String = '<table cellspacing="0" cellpadding="0" class="src">'
                    + newLines.join("\n") + '</table>';

            htmlText = html.toXMLString().replace("[BODY]", sourceText);
        }
        
        /**
         * Scroll the source view to a specific line.  This has to be done in a deferrable manner
         * because the source might not actually be fully loaded yet at the time that this is called.
         *  
         * @param lineNum a one-based line number in the source
         */
        public function scrollToLine(lineNum:uint):void
        {
            _scrollLine = lineNum;
            adjustScrollLine();
        }
        
        /**
         * Adjust the scroll position of the window to reflect the scroll destination line. 
         * 
         */
        private function adjustScrollLine():void
        {
            var lineElement:Object = htmlLoader.window.document.getElementById("line" + _scrollLine);
            if (lineElement != null)
            {
                htmlLoader.window.scrollTo(0, lineElement.offsetTop);
            }
            else
            {
                htmlLoader.window.scrollTo(0, 0);
            }
        }
        
        /**
         * Generate the HTML for a single source line.  As a side effect, this also updates
         * the _gapSet property to reflect whether the line has a coverage gap.
         *  
         * @param lineNum a one-based line number in the source
         * @return the HTML to be displayed for that line
         * 
         */
        private function getLineHtml(lineNum:uint):String
        {
            var lineState:int = NO_ELEMENTS;
            
            // Process any LineModel for this line
            //
            var lineModel:LineModel = classModel.lineModelMap[lineNum];
            if (lineModel != null)
            {
                if (lineModel.executionCount == 0)
                {
                    // this is what we get as soon as we encounter an uncovered element
                    lineState = UNCOVERED_ELEMENTS; 
                }
                else if (lineState == NO_ELEMENTS)
                {
                    // but if the execution count is nonzero, the state can
                    // go from NO_ELEMENTS to ALL_ELEMENTS_COVERED.
                    lineState = ALL_ELEMENTS_COVERED;
                }
            }

            // Process all BranchModels for this line, organizing them in the
            // branchModelsByOffset map whose keys are column numbers OR the
            // special key -1, signifying the end of the source line.
            //
            var branchModelsByOffset:Object = {};
            for each (var bm1:BranchModel in classModel.branchModelMap[lineNum])
            {
                // Calculate a column offset based on the BranchModel, correcting for the
                // off-by-2 weirdness in the compiler.  Note that the offset may be -1 for
                // MXML files because we don't have a meaningful column number in that case.
                //
                var offset:int = (bm1.column < 0) ? -1 : Math.max(0, bm1.column - 2);
                var offsetEntry:Array = branchModelsByOffset[offset];
                if (offsetEntry == null)
                {
                    // This is the first BranchModel for this column offset, so create
                    // the entry in the map.
                    offsetEntry = [];
                    branchModelsByOffset[offset] = offsetEntry;
                }
                offsetEntry.push(bm1);
                offsetEntry.sortOn("sortKey", Array.NUMERIC);
                if (bm1.executionCount == 0)
                {
                    // this is what we get as soon as we encounter an uncovered element
                    lineState = UNCOVERED_ELEMENTS; 
                }
                else if (lineState == NO_ELEMENTS)
                {
                    // but if the execution count is nonzero, the state can
                    // go from NO_ELEMENTS to ALL_ELEMENTS_COVERED.
                    lineState = ALL_ELEMENTS_COVERED;
                }
            }

            // Generate the line character by character, slotting in any branch-related
            // information at the appropriate column.
            //
            var originalLine:String = lines[lineNum - 1];
            var line:String = "";
            for (var i:int = 0; i < originalLine.length; i++)
            {
                line += getBranchHtml(branchModelsByOffset, i);

                var ch:String = originalLine.charAt(i);
                switch (ch)
                {
                case "&":
                    line += "&amp;";
                    break;

                case "<":
                    line += "&lt;";
                    break;

                case ">":
                    line += "&gt;";
                    break;

                case "\r":
                case "\n":
                    // we want to strip these characters out, they cause trouble
                    // in a preformatted span.
                    break;

                default:
                    line += ch;
                }
            }           
            line += getBranchHtml(branchModelsByOffset, -1);

            // Now generate the outer elements around the line HTML including the execution count.
            //
            var sourceTag:String = '<pre>';

            var countElement:String;
            switch (lineState)
            {
            case NO_ELEMENTS:
                countElement = '<td class="data">';
                break;
                
            case ALL_ELEMENTS_COVERED:
                countElement = '<td class="goodCount">';
                delete _gapSet[lineNum];
                break;
                
            case UNCOVERED_ELEMENTS:
                countElement = '<td class="badCount">'; 
                _gapSet[lineNum] = lineNum;
                break;
            }
            countElement += "&nbsp;";

            if (lineModel != null)
            {
                countElement += lineModel.executionCount;
            }
            else
            {
                countElement += "&nbsp;&nbsp;&nbsp;";
            }
            
            countElement += '</td>';

            return '<td class="data">&nbsp;' + (lineNum++) + '</td>'
                   + countElement
                   + '<td>' + sourceTag + line + '</pre></td>';
        }

        /**
         * Generate the HTML that represents the state of a branch element. 
         * @param branchModelsByOffset a map of BranchModel objects organized by
         *   column offset
         * @param i a column offset within the line, or -1
         * @return 
         * 
         */
        private function getBranchHtml(branchModelsByOffset:Object, i:int):String
        {
            var line:String = ""
            if (i in branchModelsByOffset)
            {
                var bmList:Array = branchModelsByOffset[i];
                for each (var bm2:BranchModel in bmList)
                {
                    line += '<span id="' + bm2.elementId + '"><sup class="'
                            + ((bm2.executionCount > 0) ? "goodBranch" : "badBranch")
                            + '">' + bm2.symbol + bm2.executionCount + '</sup></span>';
                }
            }
            return line;
        }        

        /**
         * Build the array of gap offsets for display elsewhere and set the gapOffsets property
         * with that array, which will trigger a PropertyChangeEvent.
         */
        private function buildGapOffsets():void
        {
            // First get a nice sorted list of all the lines with gaps.
            var gapLines:Array = [];
            for (var i:String in _gapSet)
            {
                gapLines.push(parseInt(i));
            }
            gapLines.sort(Array.NUMERIC);
            
            // Now walk through that list and build the gap offsets by looking up the relevant
            // line's DOM element and examining its normalized Y position within the HTML canvas.
            // Each gap represents a run of successive lines with coverage gaps.
            //
            var offsets:Array = [];
            var lastGap:Array = null;
            var lastGapLine:int = -1;
            for each (var lineNum:int in gapLines)
            {
                var lineElement:Object = htmlLoader.window.document.getElementById("line" + lineNum);

                if (lineNum == lastGapLine + 1)
                {
                    // This gap line immediately follows the previous one, so extend the run of gaps.
                    lastGap[1] = (lineElement.offsetTop + lineElement.offsetHeight) / htmlLoader.contentHeight;
                }
                else
                {
                    // We found a new starting line for some run of gaps, so push any run that we've been
                    // accumulating.
                    if (lastGap != null)
                    {
                        offsets.push(lastGap);
                    }
                    lastGap = [lineElement.offsetTop / htmlLoader.contentHeight,
                               (lineElement.offsetTop + lineElement.offsetHeight) / htmlLoader.contentHeight];
                }
                lastGapLine = lineNum;
            }
            
            if (lastGap != null)
            {
                offsets.push(lastGap);
            }
            
            gapOffsets = offsets;
        }
        
        private function handleLineCoverageChange(e:Event):void
        {
            var lineModel:LineModel = e.target as LineModel;
            var lineNum:uint = parseInt(lineModel.name);
            var element:Object = htmlLoader.window.document.getElementById(lineModel.elementId);
            if (element != null)
            {
                element.innerHTML = getLineHtml(lineNum);
            }
            buildGapOffsets();
        }
        
        private function handleBranchCoverageChange(e:Event):void
        {
            var branchModel:BranchModel = e.target as BranchModel;
            var element:Object = htmlLoader.window.document.getElementById(branchModel.elementId);
            if (element != null)
            {
                element.innerHTML = getLineHtml(branchModel.line);
            }
            buildGapOffsets();
        }
        
        private function handleComplete(e:Event):void
        {
            adjustScrollLine();
            buildGapOffsets();
        }
        
        private function onCreationComplete():void
        {
        }
    }
}