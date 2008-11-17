package faces.controller
{
    import faces.command.ICommandContext;
    import faces.command.RemoveCommand;
    import faces.command.SearchCommand;
    import faces.command.UpdateCommand;
    
    import mx.core.Container;
    import faces.model.Face;
    import faces.model.FacesModel;
    import faces.service.ServiceLocator;
    import faces.events.UIEvent;
    import faces.events.UIEventKind;

    public class FacesController
        implements ICommandContext
    {
        private var _parentContainer:Container;
        private var _model:FacesModel;
        private var _services:ServiceLocator;

        /**
         * ICommandContext interface method.
         */
        public function get parentContainer():Container
        {
            return _parentContainer;
        }

        public function set parentContainer(value:Container):void
        {
            _parentContainer = value;
        }

        /**
         * ICommandContext interface method.
         */
        public function get model():FacesModel
        {
            return _model;
        }

        public function set model(value:FacesModel):void
        {
            _model = value;
        }

        /**
         * ICommandContext interface method.
         */
        public function get services():ServiceLocator
        {
            return _services;
        }

        public function set services(value:ServiceLocator):void
        {
            _services = value;
        }

        private function clearFaces():void
        {
            this.model.clearFaces();
        }

        /**
         * Show error.
         */
        public function showError(errorMessage:String, fatal:Boolean):void
        {
            _parentContainer.dispatchEvent(new UIEvent(UIEventKind.SHOW_ERROR, errorMessage));
        }

        /**
         * Show "waiting" state.
         */
        public function showWait():void
        {
            _parentContainer.dispatchEvent(new UIEvent(UIEventKind.SHOW_WAIT));
        }

        /**
         * Clear "waiting" state.
         */
        public function clearWait():void
        {
            _parentContainer.dispatchEvent(new UIEvent(UIEventKind.CLEAR_WAIT));
        }

        /**
         * Delegate a UI event to a Command that executes it.
         */
        public function handleUiEvent(event:UIEvent):void
        {
            trace("FacesController handling UI event kind: " + event.kind);
            
            switch (event.kind)
            {
            // Remote operations requiring service-layer interaction
            case UIEventKind.SEARCH:
                new SearchCommand(this, _model, String(event.payload)).execute();
                break;
            case UIEventKind.REMOVE:
                new RemoveCommand(this, _model, Face(event.payload)).execute();
                break;
            case UIEventKind.UPDATE:
                new UpdateCommand(this, _model, event.payload).execute();
                break;

            // Local operations within the controller
            case UIEventKind.CLEAR:
                clearFaces();
                break;
                
            default:
                trace("FacesController did not handle " + event.kind);
                return;   // allow propagation
            }
            
            // The event was consumed
            event.stopPropagation();
        }
    }
}
