package faces.model
{
    /**
     * Model for a face view.
     */
    public class Face
    {
        public var id:String;

        [Bindable]
        public var source:String;

        [Bindable]
        public var firstName:String;

        [Bindable]
        public var surname:String;

        [Bindable]
        public var countryCode:String;
        
        [Bindable]
        public var description:String;

        [Bindable]
        public var changeEnabled:Boolean;
        
        // Not bindable, but we're not changing any properties in this read-only model
        public function get name():String
        {
            return firstName + " " + surname;
        }
    }
}
