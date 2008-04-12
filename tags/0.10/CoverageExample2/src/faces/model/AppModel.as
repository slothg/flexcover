package faces.model
{
    import faces.events.AppStatus;

    /** Application-wide display model */
    
    public class AppModel
    {
        [Bindable]
        public var status:String;

        [Bindable]
        public var errorMessage:String;

        [Bindable]
        public var waitLevel:int = 0;

        [Bindable]
        public var title:String;
        
        private var countryNames:Object = {};

        /**
         * Accept configuration data.
         */
        public function applyConfig(xml:XML):void
        {
            this.title = xml.Title.toString();
            this.status = AppStatus.LOGGED_IN;    // unrealistic side effect
            
            for each (var country:XML in xml.CountryCodes.Country)
            {
                countryNames[country.@code] = country.@name.toString();
            }
        }
        
        /**
         * Get the country name for a given country code.
         *  
         * @param countryCode an ISO country code
         * @return a displayable country name. 
         */
        public function getCountryName(countryCode:String):String
        {
            return countryNames[countryCode];
        }
    }
}
