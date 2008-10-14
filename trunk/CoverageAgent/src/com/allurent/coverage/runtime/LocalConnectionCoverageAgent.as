package com.allurent.coverage.runtime
{
    import com.adobe.ac.util.service.IReceivingLocalConnection;
    import com.adobe.ac.util.service.ISendingLocalConnection;
    import com.adobe.ac.util.service.LocalConnectionWrapper;
    
    import flash.events.AsyncErrorEvent;
    import flash.events.ErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.StatusEvent;
    import flash.utils.ByteArray;
    
    /**
     * This class provides overall coverage recording support for an instrumented application
     * using a LocalConnection and its built-in serialization support for objects.
     */
    public class LocalConnectionCoverageAgent extends AbstractCoverageAgent
    {
        // default connection name
        private static const DEFAULT_CONNECTION_NAME:String = "_flexcover";
        // default connection name to ack received coverage data.
        private static const DEFAULT_ACK_CONNECTION_NAME:String = "_flexcover_ack";
        
        // handler function names on client end of LocalConnection
        private static const DATA_HANDLER:String = "coverageData";
        private static const EXIT_HANDLER:String = "coverageEnd";
        
        // Maximum total key length allowed before forced LC send packet
        private static const MAX_SEND_LENGTH:uint = 10000;
        
        /**
         * Obtain a flag indicating whether there are any outstanding send or exit operations. 
         */
        override public function get operationsPending():Boolean
        {
            return (pendingWrites > 0);
        }        
        
        /**
         * LocalConnection name to be used by coverage recording.  Must be modified
         * prior to first coverage output.
         */
        public var coverageDataConnectionName:String;        
        
        // LocalConnection used for writing coverage data
        private var coverageDataConnection:ISendingLocalConnection;
  
        // LocalConnection open for acknowleding received data from live instrumented apps
        private var ackConnection:IReceivingLocalConnection;        
        // LocalConnection name to receive ack and send more. We receive this from the viewer as
        //we want to support multiple agents serving one viewer.
        private var ackConnectionName:String;
        private var ackConnectionCounter:int;
        
        // counter of pending writes to local connection, important
        // in exiting the application only after all coverage data has been written
        private var pendingWrites:int = 0;
        
        //Array of coverage maps that need to be transfered to the coverage monitor. 
        //One hacky approach to ensure LocalConnetion doesn't crash due to too much data traffic.
        private var pendingMaps:Array = new Array();
        private var noPendingMaps:Boolean;            
        private var hasRegistrationBeenSent:Boolean; 
        
        /**
         * Create a LocalConnectionCoverageAgent.
         * 
         * @param connectionName the name of the LocalConnection to be used.
         * 
         */
        public function LocalConnectionCoverageAgent(connectionName:String = null)
        {
            this.coverageDataConnectionName = (connectionName != null)
                ? connectionName
                : DEFAULT_CONNECTION_NAME;
        }
        
        /**
         * Flush all outstanding coverage data to this agent's destination.
         */
        override public function initializeAgent():void
        {
            coverageDataConnection = createCoverageDataConnection();
            coverageDataConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, handleConnectionError);
            coverageDataConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleConnectionError);
            coverageDataConnection.addEventListener(StatusEvent.STATUS, handleConnectionStatus);
            
            if(!hasRegistrationBeenSent)
            {
               sendRegistration();                 
            }
        }

        /**
         * Send a map of coverage keys and execution counts to this agent's destination.
         * @param map an Object whose keys are coverage elements and values are execution counts.
         */
        override public function sendCoverageMap(map:Object):void
        {
            // Repeatedly accumulate MAX_SEND_LENGTH worth of coverage key/value
            // pairs in tempMap, sending over the LocalConnection as this limit
            // is reached.  This is a crude attempt to avoid exceeding the data size limit
            // inherent in LocalConnection.
            var i:uint = 0;            
            var tempMap:Object = {};
            var foundSomething:Boolean;
            for (var key:String in map)
            {
            	foundSomething = true;
                tempMap[key] = map[key];
                
                if ((i += key.length) > MAX_SEND_LENGTH)
                {
                    addPendingMapAndAttempSend(tempMap);
                    tempMap = {};
                    i = 0;
                }
            }
            
            // We might have some keys left over that didn't hit the max limit.
            if(foundSomething)
            {
                addPendingMapAndAttempSend(tempMap);
            }
        }
        
        /**
         * Request the destination of this agent to terminate its execution. 
         */
        override public function requestExit():void
        {
            coverageDataConnection.send(coverageDataConnectionName, EXIT_HANDLER);
            pendingWrites++;
        }        
        
        public function coverageReceived():void
        {
            //trace("LocalConnectionCoverageAgent.coverageReceived");
            send();
        }
        
        protected function createCoverageDataConnection():ISendingLocalConnection
        {
            return new LocalConnectionWrapper();
        }
        
        protected function createAckConnection():IReceivingLocalConnection
        {
            return new LocalConnectionWrapper();
        }        
        
        private function addPendingMapAndAttempSend(map:Object):void
        {
            pendingMaps.push(map);
            pendingWrites++;
            send();	
        }
        
        private function traceKeys(map:Object):void
        {
            for (var key:String in map)
            {
                trace("LocalConnectionCoverageAgent.traceKeys: " + key);
            }        	
        }
        
        private function getACKConnectionName():String
        {
            ackConnectionCounter++;
            return DEFAULT_ACK_CONNECTION_NAME + ackConnectionCounter;
        }
                
        /**
         * Set up the LocalConnection that listens for the ack of received coverage data 
         * from an instrumented program. This will tell the sender to send more if required.
         */
        private function initializeACKConnection():void
        {
            if (ackConnection != null)
            {
                // Don't set this up multiple times.
                return;
            }
            
            trace("LocalConnectionCoverageAgent.initializeACKConnection: ackConnectionName " + ackConnectionName); 
            
            // Set up our LocalConnection.  Note that the Controller handles
            ackConnection = createAckConnection();
            ackConnection.allowDomain("*");
            ackConnection.client = this;
            
            try
            {
                var name:String = getACKConnectionName();
                ackConnection.connect(name);
            }
            catch (error:ArgumentError)
            {
                if (error.errorID == 2082)
                {
                    trace("LocalConnectionCoverageAgent - Coverage Registration Error. Another program has already opened a LocalConnection with id '"
                                + name + "'. Try another connection name...");
                                
                                
                    ackConnection = null;
                    initializeACKConnection();         
                }
                else
                { 
                    trace("LocalConnectionCoverageAgent - Coverage Registration Error. " + error.message);
                    ackConnection = null;
                }
            }
            this.ackConnectionName = ackConnectionName;
        }
        
        private function send():void
        {
           if(pendingMaps.length > 0)
           {
             sendMaps(pendingMaps);      
           }
           else
           {
             trace("LocalConnectionCoverageAgent.sendMaps: Nothing to send ");             
           }
        }
        
        private function sendMaps(maps:Array):void
        {
            var map:Object = maps.shift();
            traceKeys(map);
            trace("LocalConnectionCoverageAgent.sendMaps: Left to send " + pendingMaps.length);
            attemptLCSend(map);
        }
        
        private function sendRegistration():void
        {
        	initializeACKConnection();
            coverageDataConnection.send(coverageDataConnectionName, DATA_HANDLER, null);
            hasRegistrationBeenSent = true;
        }
        
        private function attemptLCSend(map:Object):void
        {
	        try
	        {
                coverageDataConnection.send(coverageDataConnectionName, DATA_HANDLER, map);
                pendingWrites--;
	        }
	        catch (error:Error)
	        {
	        	pendingWrites++;
	            if (error.errorID == 2084)
	            {
	                var byteArray:ByteArray = new ByteArray();
	                byteArray.writeObject(map);
	                var kb:Number = byteArray.length / 1024;                
	                trace("LocalConnectionCoverageAgent - Coverage Recording Error. " + error.message + " Was: " + kb);
	                
	                splitSendRequests(map, kb);                 
	            }
	            else
	            {
	                trace("LocalConnectionCoverageAgent - Coverage Recording Error. " + error.message);
	            }
	        }	
        }
        
        private function splitSendRequests(map:Object, kb:Number):void
        {
        	//limit would be 40, not 20 kb but let's be carefull.
            var sendRequests:Number = Math.ceil(kb / 20);
            var mapLengthPerRequest:int = getMapLength(map) / sendRequests;           
            trace("LocalConnectionCoverageAgent.splitSendRequests sendRequests " + sendRequests )
            trace("LocalConnectionCoverageAgent.splitSendRequests mapLengthPerRequest " + mapLengthPerRequest )
            
            var i:int = 0;
            var tempMap:Object = {};
            var foundSomething:Boolean;
            for (var key:String in map)
            {
                i++;
                foundSomething = true;
                if(i < mapLengthPerRequest)
                {
                    tempMap[key] = map[key];
                }
                else
                {
                    trace("LocalConnectionCoverageAgent.splitSendRequests splitSendRequests " + i );
                    //attemptLCSend(tempMap);                    
                    addPendingMapAndAttempSend(tempMap);
                    
                    tempMap = {};
                    i = 0;           
                }
            }
            
            if(foundSomething)
            {
            	trace("LocalConnectionCoverageAgent.splitSendRequests foundSomething " + i );
                addPendingMapAndAttempSend(tempMap);
            }
        }
        
        private function getMapLength(map:Object):int
        {
            var i:int = 0;
            for (var key:String in map)
            {
                i++;
            }
            trace("LocalConnectionCoverageAgent.getMapLength " + i)
            return i;           
        }             
        
        private function handleConnectionError(e:ErrorEvent):void
        {
            trace(e.text);
        }
        
        private function handleConnectionStatus(e:StatusEvent):void
        {
            if (e.level == "error")
            {
                // Something went awry.
                // TODO: This may write more data to the log than was actually lost,
                //    but the assumption for now is that the LC either works all the time or
                //    fails all the time.
                //
                broken = true;
            }
            trace("handleConnectionStatus pendingWrites " + pendingWrites );
            checkForExit();
        }
    }
}
