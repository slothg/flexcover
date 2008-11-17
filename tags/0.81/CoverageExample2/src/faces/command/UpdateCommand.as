package faces.command
{
    import flash.events.Event;
    import flash.events.ErrorEvent;
    import flash.utils.Timer;
    import faces.model.FacesModel;

    /** Command to update the data for a Face. */
    public class UpdateCommand extends Command
    {
        private var _data:Object;
        private var _model:FacesModel;

        public function UpdateCommand (context:ICommandContext, model:FacesModel, data:Object)
        {
            super(context);
            this._model = model;
            this._data = data;
        }

        override public function execute():void
        {
            _model.setFaceChangeEnabled(_data.id, false);

            // Simulate a service call!
            var timer:Timer = new Timer(2500, 1);
            timer.addEventListener("timer", handleUpdateComplete);
            timer.start();
        }

        private function handleUpdateComplete(event:Event):void
        {
            _model.setFaceChangeEnabled(_data.id, true);
            _model.updateFaceDescription(_data.id, _data.description);
        }

        private function handleUpdateError(event:ErrorEvent):void
        {
            _model.setFaceChangeEnabled(_data.id, true);
            context.showError(event.text, false);
        }
    }
}
