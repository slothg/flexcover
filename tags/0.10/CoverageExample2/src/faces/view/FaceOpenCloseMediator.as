package faces.view
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    import mx.core.Container;
    import mx.events.FlexEvent;

    /**
     * Manage the opening and closing of Face views.
     *
     * An illustration of the Mediator pattern.
     */
    public class FaceOpenCloseMediator
        extends EventDispatcher
    {
        /**
         * The component that plays the role of parent container
         * in this interaction.
         */
        public var parentContainer:Container;

        [Bindable]
        /**
         * Bindable property that is true while some client view is open. 
         */
        public var open:Boolean = false;

        // Hold on to the last small view and the last expanded view.
        // There can be only one view open at a time.
        //
        private var _smallView:Container;
        private var _expandedView:Container;

        /**
         * Mediate the process of "opening" a SmallFaceView.
         */
        public function handleOpenEvent(event:Event):void
        {
            open = true;

            // Create an expanded view to overlay the original.
            _expandedView = new ExpandedFaceView;

            // Copy properties from the original.
            _smallView = Container(event.target);
            _expandedView.data = _smallView.data;
            _expandedView.x = _smallView.x;
            _expandedView.y = _smallView.y;

            // Show the view.
            parentContainer.addChild(_expandedView);
            _expandedView.addEventListener(FlexEvent.CREATION_COMPLETE, handleCompleteEvent);

            // Listen for close events from the expanded view.
            _expandedView.addEventListener("close", handleCloseEvent);
         }

        public function handleCompleteEvent(event:Event):void
        {
            _expandedView.currentState = ExpandedFaceView.FULL_STATE;
        }
        
        /**
         * Mediate the process of "closing" a Face view.
         */
        public function handleCloseEvent(event:Event):void
        {
            var expandedView:ExpandedFaceView = ExpandedFaceView(event.target);
            expandedView.currentState = ExpandedFaceView.SHRUNKEN_STATE;
            _expandedView.addEventListener("transitionDone", handleTermination);
        }

        private function handleTermination(event:Event):void
        {
            closeAll();
        }

        /**
         * Force all open views closed.  There can be only one, currently.
         */
        public function closeAll():void
        {
            if (open)
            {
                parentContainer.removeChild(_expandedView);
                _smallView = null;
                _expandedView = null;
                open = false;
            }
        }
    }
}
