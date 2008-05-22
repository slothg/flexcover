package faces.events
{
    import flash.events.Event;

    /**
     * A generic UI event type.  For Implicit Invocation illustration.
     */
    public class UIEvent extends Event
    {
        /**
         * Generic event type identifier.
         */
        public static const EVENT_TYPE:String = "uiEvent";
        
        /**
         * Event type discriminator.
         */
        public var kind:String;

        /**
         * Payload data (may be null). Payload type is based on kind.
         * Listener is responsible for casting to correct type.
         */
        public var payload:Object;
        
        /**
         * Constructor.
         */
        public function UIEvent(kind:String, payload:Object = null)
        {
            super(EVENT_TYPE, true/* bubbles */);
            this.kind = kind;
            this.payload = payload;
        }

        /**
         * Required by flash.events.Event.
         */
        override public function clone():Event
        {
            return new UIEvent(kind, payload);
        }
    }
}
