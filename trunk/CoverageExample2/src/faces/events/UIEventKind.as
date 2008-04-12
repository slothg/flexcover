package faces.events
{
    /**
     * Event kind enumeration.  For each kind, the meaning of the
     * command and the payload type are documented here.
     */
    public class UIEventKind
    {
        /**
         * Start the application.
         * The payload is a String, the URL of the configuration file.
         */
        public static const STARTUP:String = "startup";

        /**
         * Search for faces.
         * The payload is a String, the search terms.
         */
        public static const SEARCH:String = "search";

        /**
         * Clear faces.
         * Payload is null.
         */
        public static const CLEAR:String = "clear";

        /**
         * Remove a face.
         * Payload is a reference to a Face object in the model.
         */
        public static const REMOVE:String = "remove";

        /**
         * Edit a face.
         * Payload is a reference to a Face object in the model.
         */
        public static const EDIT:String = "edit";

        /**
         * Update a face.
         * Payload is a Face object.  Its id must match the id of a face
         * in the current model.
         */
        public static const UPDATE:String = "update";
        
        /**
         * Communicate an error message.
         */
        public static const SHOW_ERROR:String = "showError";
        
        /**
         * Initiate a wait state.
         */
        public static const SHOW_WAIT:String = "showWait";
        
        /**
         * Terminate a wait state.
         */
        public static const CLEAR_WAIT:String = "clearWait";
    }
}
