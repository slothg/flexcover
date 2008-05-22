package faces.service
{
    /**
     * A dummy class to illustrate the use of MXML to configure subsystems.
     */
    public class ServiceLocator
    {
        private var _services:Array;
     
        public function get services():Array
        {
            return _services;
        }
        
        public function set services(value:Array):void
        {
            _services = value;
        }
        
        public function findService(cls:Class):IService
        {
            for each (var service:IService in services)
            {
                if (service is cls)
                {
                    return service;
                }
            }
            return null;
        }
        
    }
}
