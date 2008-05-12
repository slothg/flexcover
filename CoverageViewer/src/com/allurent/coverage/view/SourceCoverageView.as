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
        public var project:ProjectModel;
        public var classModel:ClassModel;
        public var lines:Array;

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
        }
        
        public function show(project:ProjectModel, c:ClassModel):void
        {
            this.project = project;
            classModel = c;

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

            var html:XML =
                <html>
                    <head>
                       <style type="text/css">{STYLES.join(" ")}</style>
                    </head>
                    <body>[BODY]</body>
                </html>;

            lines = fileContents.split("\n");
            
            var newLines:Array = [];
            for (var i:int = 1; i <= lines.length; i++)
            {
                newLines.push('<tr id="line' + i + '">' + getLineHtml(i) + '</tr>');
            }

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
            
            var sourceText:String = '<table cellspacing="0" cellpadding="0" class="src">'
                    + newLines.join("\n") + '</table>';

            htmlText = html.toXMLString().replace("[BODY]", sourceText);
        }
        
        private static const NO_ELEMENTS:int = 0;
        private static const UNCOVERED_ELEMENTS:int = 1;
        private static const ALL_ELEMENTS_COVERED:int = 2;
        
        private function getLineHtml(lineNum:uint):String
        {
            var lineState:int = NO_ELEMENTS;
            
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

            var branchModelsByOffset:Object = {};
            for each (var bm1:BranchModel in classModel.branchModelMap[lineNum])
            {
                var offset:int = (bm1.column < 0) ? -1 : Math.max(0, bm1.column - 2);
                var offsetEntry:Array = branchModelsByOffset[offset];
                if (offsetEntry == null)
                {
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
                    break;

                default:
                    line += ch;
                }
            }           
            line += getBranchHtml(branchModelsByOffset, -1);

            var sourceTag:String = '<pre>';

            var countElement:String;
            switch (lineState)
            {
            case NO_ELEMENTS:
                countElement = '<td class="data">';
                break;
            case ALL_ELEMENTS_COVERED:
                countElement = '<td class="goodCount">'; 
                break;
            case UNCOVERED_ELEMENTS:
                countElement = '<td class="badCount">'; 
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

        private function handleLineCoverageChange(e:Event):void
        {
            var lineModel:LineModel = e.target as LineModel;
            var lineNum:uint = parseInt(lineModel.name);
            var element:Object = htmlLoader.window.document.getElementById(lineModel.elementId);
            if (element != null)
            {
                element.innerHTML = getLineHtml(lineNum);
            }
        }
        
        private function handleBranchCoverageChange(e:Event):void
        {
            var branchModel:BranchModel = e.target as BranchModel;
            var element:Object = htmlLoader.window.document.getElementById(branchModel.elementId);
            if (element != null)
            {
                element.innerHTML = getLineHtml(branchModel.line);
            }
        }
        
        private function onCreationComplete():void
        {
        }
    }
}