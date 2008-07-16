package com.adobe.ac.util
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   /**
   * One TimerUtil instance will only hold one active Timer at a time.
   */
   public class TimerUtil implements ITimerUtil
   {
      private var timer : Timer;
      private var callback : Function;
      
      public function TimerUtil()
      {
         timer = new Timer( 0 );
      }
      
      public function delay( time : Number, callback : Function ) : void
      {
         if( timer.running )
         {
            timer.stop();
            timer.removeEventListener( TimerEvent.TIMER_COMPLETE, onTimeout );
         }
         this.callback = callback;
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
         callback();
      }
   }
}