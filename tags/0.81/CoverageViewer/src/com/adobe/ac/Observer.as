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
package com.adobe.ac
{
	import mx.core.Application;
	import mx.core.UIComponent;
   
	public class Observer 
	{
		protected var isHandlerInitialized : Boolean = false;
		protected var isSourceInitialized : Boolean = false;
		
		public function get handler() : Function
		{
			return null;
		}
  
		public function get source() : Object
		{
			return null;
		}
		
		public function execute( method : Function, ...params : Array ) : Object
		{
			var returnValue : Object;
			try
			{
				returnValue = method.apply( null, params );
			}
			catch( e : Error )
			{
				delay( e );
			}
			return returnValue;
		}
			
		protected function callHandler() : void
		{
			try
			{
				handler.call( null, source );
			}
			catch( e : Error )
			{
				delay( e );
			}
		}
   
		protected function delay( e : Error ) : void
		{
			UIComponent( Application.application ).callLater( throwException, [ e ] );
		}
   
		private function throwException( e : Error ) : void
		{
			throw e;
		}
	}
}