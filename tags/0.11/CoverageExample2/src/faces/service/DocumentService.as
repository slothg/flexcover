package faces.service
{
    import faces.model.Face;
    
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.TimerEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.utils.Timer;
    
    import mx.rpc.IResponder;
    
    /**
     * A service implementation that pretends to contact a server-side web service
     * to search for names, but which actually reads a local XML file.
     */
    public class DocumentService implements IService
    {
        public var location:String;

        private static const DATA_FILE_NAME:String = "search.xml";

        public function init():void
        {
        }
        
        public function search(target:String, responder:IResponder):void
        {
            // HACK to simulate a real search!
            var urlLoader:URLLoader = new URLLoader();
            var successHandler:Function = function(e:Event):void { handleSearchComplete(urlLoader, target, responder); };

            urlLoader.addEventListener(Event.COMPLETE, successHandler);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
            urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError);
            var loadFunction:Function = function(e:Event):void { urlLoader.load(new URLRequest(DATA_FILE_NAME)) };
            var timer:Timer = new Timer(1000, 1);
            timer.addEventListener(TimerEvent.TIMER, loadFunction);
            timer.start();
        }

        private function handleSearchComplete(urlLoader:URLLoader, target:String, responder:IResponder):void
        {
            try
            {
                var xml:XML = new XML(urlLoader.data);
                responder.result(convertFilteredResults(target, xml));
            }
            catch (e:Error)
            {
                // XML Parse error, most likely.
                responder.fault(e.message);
            }
        }

        private function convertFilteredResults(target:String, xml:XML):Array
        {
            var facesArray:Array = new Array();

            if (xml != null)
            {
                for each (var faceElement:XML in xml.Faces.Face)
                {
                    if (faceElement.Surname.toString().toLowerCase().indexOf(target.toLowerCase()) >= 0)
                    {
                        var face:Face = new Face();
    
                        face.id = faceElement.@id;
                        face.source = "images/composers/" + faceElement.Source.toString();
                        face.firstName = faceElement.FirstName.toString();
                        face.surname = faceElement.Surname.toString();
                        face.countryCode = faceElement.Country.toString();
                        face.description = faceElement.Description.toString();
                        face.changeEnabled = true;
    
                        facesArray.push(face);
                    }
                }
            }
            
            return facesArray;
        }

        private function handleLoadError(event:ErrorEvent):void
        {
/*
            context.model.showError(event.text, false);
            context.model.clearWait();
            dispatchControlStateChange();
*/
        }
    }
}
