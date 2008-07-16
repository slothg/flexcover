package com.adobe.ac.util
{
   public interface ITimerUtil
   {
      function delay( time : Number, callback : Function ) : void;
      function clear() : void;
   }
}