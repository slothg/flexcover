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
	public class ObserveValue extends Observer
	{
		private var isValueInitialized : Boolean = false;
		private var _handler : Function;
		private var _source : Object;
		private var _value : Object;
 		
		override public function get handler() : Function
		{
			return _handler;
		}
 	
		public function set handler( value : Function ) : void
		{
			_handler = value;
			if( value != null )
			{
				isHandlerInitialized = true;
				if( isHandlerInitialized && isSourceInitialized && isValueInitialized )
				{
					callHandler();
				}
			}
		}
  
		override public function get source() : Object
		{
			return _source;
		}
 	
		public function set source( value : Object ) : void
		{
			_source = value; 
			isSourceInitialized = true;    	
			if( isHandlerInitialized && isSourceInitialized && isValueInitialized )
			{
				callHandler();
			}
		}
  
		public function get value() : Object
		{
			return _value;
		}
 	
		public function set value( _value : Object ) : void
		{			
			this._value = _value;
			isValueInitialized = true;
			if( isHandlerInitialized && isSourceInitialized && isValueInitialized )
			{
				callHandler();
			}	
		} 
		
		override protected function callHandler() : void
		{
			if( source != value ) return;
			
			try
			{
				handler.call();
			}
			catch( e : Error )
			{
				delay( e );
			}
		}		
	}
}