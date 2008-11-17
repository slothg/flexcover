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
package com.adobe.ac.util
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	* One OneTimeInterval instance will only hold one active Timer at a time.
	*/
	public class OneTimeInterval implements IOneTimeInterval
	{
		private var timer : Timer;
		private var callback : Function;
		private var parameters : Array;
	    
		public function OneTimeInterval()
		{
            timer = new Timer( 0 );
		}
		
		public function delay( time : Number, 
		                      callback : Function, 
		                      ... rest ) : void
		{
			if( timer.running )
			{
				timer.stop();
				timer.removeEventListener( TimerEvent.TIMER_COMPLETE, onTimeout );
			}
			this.callback = callback;
			this.parameters = rest;
			startTimer( time );
		}
		  
		public function clear() : void
		{
			timer.stop();
			timer.removeEventListener( TimerEvent.TIMER_COMPLETE, onTimeout );         
		}
		  
		private function startTimer( time : Number ) : void
		{
			timer = new Timer( time, 1 );
			timer.addEventListener( TimerEvent.TIMER_COMPLETE, onTimeout );
			timer.start();
		}
		  
		private function onTimeout( event : TimerEvent ) : void
		{
			clear();
			callback.apply( this, parameters );
		}
	}
}