/* 
 * Copyright (c) 2008 Adobe Systems Incorporated.
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
package com.adobe.ac.util.service
{
	import flash.events.Event;
	import flash.events.FileListEvent;

	public class FileBrowserStub implements IFileBrowser
	{
		private var browseForOpenMultipleHandler:Function;
		private var browseForSaveHandler:Function;

		public function browseForOpenMultiple(title:String, typeFilter:Array=null):void
		{
			browseForOpenMultipleHandler(new FileListEvent(FileListEvent.SELECT_MULTIPLE));
		}
		
		public function browseForSave(title:String):void
		{
            browseForSaveHandler(new Event(Event.SELECT));		
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			if(type == FileListEvent.SELECT_MULTIPLE)
			{
				browseForOpenMultipleHandler = listener;
			}
            else if(type == Event.SELECT)
            {
                browseForSaveHandler = listener;
            }       			
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