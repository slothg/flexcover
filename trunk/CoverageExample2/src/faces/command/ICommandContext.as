package faces.command
{
    import flash.events.IEventDispatcher;
    import mx.core.Container;
    import faces.service.ServiceLocator;

    /** Command context with access to application-wide properties and functions */
    
    public interface ICommandContext
    {
        /** Indicate that the application should enter a wait state. */
        function showWait():void;
        
        /** Leave any wait state that was entered earlier. */
        function clearWait():void;
        
        /** Show an error message. */
        function showError(errorMessage:String, fatal:Boolean):void;
        
        /** Obtain a reference to the global service locator. */
        function get services():ServiceLocator;
    }
}
