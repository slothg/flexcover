package faces.command
{
    import flash.events.*;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import mx.rpc.Responder;
    import faces.model.FacesModel;
    import faces.service.DocumentService;

    /** Command to search for Faces matching a name. */
    
    public class SearchCommand extends Command
    {
        private var _term:String;
        private var _model:FacesModel;
        
        public function SearchCommand (context:ICommandContext,
                                       model:FacesModel,
                                       term:String)
        {
            super(context);
            _model = model;
            _term = term;
        }

        /** Execute this command by initiating a search via DocumentService. */
        override public function execute():void
        {
            context.showWait();

            var responder:Responder = new Responder(searchResult, searchFault);
            DocumentService(context.services.findService(DocumentService)).search(_term, responder);
        }

        /** Handle successful search results. */
        private function searchResult(data:Object):void
        {
            var results:Array = data as Array;
            if (results == null || results.length == 0)
            {
                // The Command, as a delegate of the Controller, is responsible
                // for determining how to deal with an empty result.
                context.showError("No results were returned.", false);
            }
            else
            {
                // Apply non-empty search results to the model.
                _model.applySearchResults(results);
            }
            context.clearWait();
        }

        private function searchFault(info:Object):void
        {
            context.showError(info.toString(), false);
            context.clearWait();
        }
    }
}
