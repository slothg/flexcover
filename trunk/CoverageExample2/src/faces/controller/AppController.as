package faces.controller
{
    import faces.command.ICommandContext;
    
    import faces.events.UIEvent;
    import faces.events.UIEventKind;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    import faces.model.AppModel;
    
    import mx.core.Container;
    
    import faces.service.ServiceLocator;
    import faces.events.AppStatus;
    import faces.command.StartupCommand;

    /**
     * Type of event that broadcasts some change in the application
     * control state.  The model tells the full story.
     */
    [Event(name="controlStateChange", type="flash.events.Event")]

    /** Application-level controller class. */
    
    public class AppController
        extends EventDispatcher
        implements ICommandContext
    {
        private var _parentContainer:Container;
        private var _model:AppModel;
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
        public function get model():AppModel
        {
            return _model;
        }

        public function set model(value:AppModel):void
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

        /**
         * Show error.
         */
        public function showError(errorMessage:String, fatal:Boolean):void
        {
            if (fatal)
            {
                _model.status = AppStatus.ERROR;
            }
            _model.errorMessage = errorMessage;
        }

        /**
         * Show "waiting" state.
         */
        public function showWait():void
        {
            _model.waitLevel += 1;
            dispatchEvent(new Event("controlStateChange"));
        }

        /**
         * Clear "waiting" state.
         */
        public function clearWait():void
        {
            _model.waitLevel -= 1;
            dispatchEvent(new Event("controlStateChange"));
        }

        /**
         * start up the application.
         */
        public function startUp(configFileName:String):void
        {
            new StartupCommand(this, _model, configFileName).execute();
        }

        /**
         * Delegate a UI event to a Command that executes it.
         */
        public function handleUiEvent(event:UIEvent):void
        {
            trace("AppController handling UI event kind: " + event.kind);
            
            switch (event.kind)
            {
            case UIEventKind.SHOW_WAIT:
                showWait();
                break;
                
            case UIEventKind.CLEAR_WAIT:
                clearWait();
                break;
                
            case UIEventKind.SHOW_ERROR:
                showError(String(event.payload), false);
                break;
            }
        }
    }
}
