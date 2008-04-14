package faces.command
{
    import faces.model.Face;
    import faces.model.FacesModel;
    
    /** Command subclass to remove a Face from a model. */
    public class RemoveCommand extends Command
    {
        private var _face:Face;
        private var _model:FacesModel;

        public function RemoveCommand (context:ICommandContext, model:FacesModel, face:Face)
        {
            super(context);
            _model = model;
            _face = face;
        }

        override public function execute():void
        {
            // Disable any further interaction with this object.
            _model.setFaceChangeEnabled(_face.id, false);

            // Remove the object from the model "optimistically."
            _model.removeFace(_face.id);

            // In a real scenario, a service call would be involved here,
            // and we would have to deal with failure to remove.
        }
    }
}
