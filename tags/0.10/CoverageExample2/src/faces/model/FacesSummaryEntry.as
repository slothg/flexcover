package faces.model
{
    import flash.events.EventDispatcher;
    
    [Bindable]
    public class FacesSummaryEntry extends EventDispatcher
    {
        public var countryCode:String;
        public var count:int;
        
        public function FacesSummaryEntry(countryCode:String, count:int):void
        {
            this.countryCode = countryCode;
            this.count = count;
        }
    }
}
