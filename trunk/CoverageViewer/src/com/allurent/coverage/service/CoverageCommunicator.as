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
package com.allurent.coverage.service
{
	import com.adobe.ac.util.service.IReceivingLocalConnection;
	import com.adobe.ac.util.service.ISendingLocalConnection;
	import com.adobe.ac.util.service.LocalConnectionWrapper;
	import com.allurent.coverage.event.CoverageEvent;
	import com.allurent.coverage.model.IRecorder;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	
    /** This event is dispatched when a coverageEnd even is received from the sender.*/
    [Event(name="coverageEnd",
            type="flash.event.Event")]
    public class CoverageCommunicator extends EventDispatcher implements ICoverageCommunicator
	{
        public static const COVERAGE_END_EVENT:String = "coverageEnd";		
	    
        // default connection name for receiving coverage data.
        private static const DEFAULT_COVERAGE_DATA_CONNECTION_NAME:String = "_flexcover";		
        // default connection name to ack received coverage data.
        private static const DEFAULT_ACK_CONNECTION_NAME:String = "_flexcover_ack";        
        // handler function name on sending end of LocalConnection 
        //to receive ack and send more.
        private static const ACK_HANDLER:String = "coverageReceived";
        				
        // Name of LocalConnection to use for receiving data
        private var _coverageDataConnectionName:String;		
		public function set coverageDataConnectionName(value:String):void
		{
	       _coverageDataConnectionName = value;
		}
		
        // LocalConnection open for receiving coverage data from live instrumented apps
        private var coverageDataConnection:IReceivingLocalConnection; 
        
        // LocalConnections open for acknowleding received data from live instrumented apps
        private var ackConnections:Dictionary;
		private var ackConnectionCounter:int;
		private var currentAckConnection:int;
		
        private var recorder:IRecorder;
        
		private var isTooBusyToReceiveMore:Boolean;
		
	    public function CoverageCommunicator(recorder:IRecorder)
		{
	       this.recorder = recorder;
           this.recorder.addEventListener(CoverageEvent.RECORDING_END, onRecordingEnd);
           this.recorder.addEventListener(CoverageEvent.PARSING_END, onParsingEnd);	       
           
           _coverageDataConnectionName = DEFAULT_COVERAGE_DATA_CONNECTION_NAME;
           
           ackConnections = new Dictionary();
		}
		
        /**
         * Set up the LocalConnection that listens for incoming coverage data from an instrumented program.
         * @param connectionName the name to use for the connection.
         */
        public function attachConnection(connectionName:String=null):void
        {
        	if(connectionName == null)
        	{
        	   connectionName = _coverageDataConnectionName;
        	}
        	
            if (coverageDataConnection != null)
            {
                // Don't set this up multiple times.
                return;
            }
            
            // Set up our LocalConnection.  Note that the Controller handles
            trace("attachConnection coverageDataConnection: " + connectionName);
            coverageDataConnection = createCoverageDataConnection();
            coverageDataConnection.allowDomain("*");
            coverageDataConnection.client = this;
            try
            {
                coverageDataConnection.connect(connectionName);        
            }
            catch (error:Error)
            {
                if (error.errorID == 2082)
                {
                    Alert.show("Another program has already opened a LocalConnection with id '"
                                + connectionName + "'.  No coverage data will be recorded.",
                                "Coverage Recording Error");
                }
                else
                {
                    Alert.show(error.message, "Coverage Recording Error");
                }
                coverageDataConnection == null;
            }
        }
        
        /**
         * Handle a map of coverage keys and execution counts received over our LocalConnection
         * from an instrumented application.
         *  
         * @param keyMap a map whose keys are coverage keys (see CoverageElement) and whose values
         * are incremental execution counts for those same keys since the last transmission from
         * the instrumented app.
         */
        public function coverageData(keyMap:Object):void
        {
        	//traceKeys(keyMap); 
        	
            if(keyMap == null)
            {
                trace("++++++++++CoverageCommunicator.coverageData ");
                sendRegistration();
            }
            else
            {
                //var byteArray:ByteArray = new ByteArray();
                //byteArray.writeObject(keyMap);
                //trace("---------CoverageCommunicator.coverageData " + (byteArray.length / 1024));
                //traceKeys(keyMap);
                
	            recorder.record(keyMap);
	            
	            if(!isTooBusyToReceiveMore)
	            {
	                //sendACK(keyMap.ackConnectionName);
	                sendACK(rotateConnection());
	            }                  	
            }
        }
        
        /**
         * Handler called by instrumented program when coverage ends. 
         */
        public function coverageEnd():void
        {
            dispatchEvent(new Event(COVERAGE_END_EVENT));
        }
                
        protected function createCoverageDataConnection():IReceivingLocalConnection
        {
            return new LocalConnectionWrapper();
        }        
        
        protected function createAckConnection():ISendingLocalConnection
        {
            return new LocalConnectionWrapper();
        }    
        
        private function rotateConnection():String
        {
        	currentAckConnection++;
        	if(currentAckConnection > ackConnectionCounter)
        	{
        		currentAckConnection = 1;
        	}
        	var name:String = getACKConnectionName(currentAckConnection);
        	
        	trace("rotateConnection " + name);
        	return name;
        }

        private function onRecordingEnd(event:Event):void
        {
           isTooBusyToReceiveMore = true;
        }
        
        private function onParsingEnd(event:Event):void
        {
            isTooBusyToReceiveMore = false;
            sendACK(rotateConnection());
        }
        
        private function sendRegistration():void
        {
            var name:String = getACKConnectionName(++ackConnectionCounter);            
            trace("sendRegistration name " + name);
            
            var ackConnection:ISendingLocalConnection = initializeAckConnection();
        	registerAckConnection(name, ackConnection);
            
            trace("sendRegistration ackConnection " + ackConnection);
            sendACK(name);
        }
        
        private function registerAckConnection(name:String, ackConnection:ISendingLocalConnection):void
        {
            ackConnections[name] = ackConnection;   	
        }
        
        private function getACKConnectionName(index:int):String
        {
            return DEFAULT_ACK_CONNECTION_NAME + index;
        }    
        
        private function sendACK(ackConnectionName:String):void
        {
            try
            {
                //send ack of received message
                var ackConnection:ISendingLocalConnection = ISendingLocalConnection(ackConnections[ackConnectionName]);
                ackConnection.send(ackConnectionName, ACK_HANDLER);
            }
            catch (error:Error)
            {
                Alert.show(error.message, "Coverage Recording Acknowledgement Error");
            }
        }
 
        private function traceKeys(map:Object):void
        {
            for (var key:String in map)
            {
                trace("traceKeys: " + key);
            }           
        }
        
        private function initializeAckConnection():ISendingLocalConnection
        {
            var ackConnection:ISendingLocalConnection = createAckConnection();            
            ackConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, handleConnectionError);
            ackConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleConnectionError);
            ackConnection.addEventListener(StatusEvent.STATUS, handleConnectionStatus);
            return ackConnection;
        }
        
        private function handleConnectionError(e:ErrorEvent):void
        {
            trace("CoverageCommunicator.handleConnectionError: " + e.text);
            Alert.show(e.type + " " + e.text, "Coverage Recording Acknowledgement Error");
        }
        
        private function handleConnectionStatus(e:StatusEvent):void
        {
            if (e.level == "error")
            {
                trace("CoverageCommunicator.handleConnectionStatus: level error, code " + e.code);
            }
            else if (e.level == "status")
            {
                trace("CoverageCommunicator.handleConnectionStatus: level status, code " + e.code);
            }
        }
	}
}