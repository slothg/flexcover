package faces.command
{
    import flash.events.*;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import mx.collections.ArrayCollection;
    import flash.utils.Timer;
    import faces.model.AppModel;

    /**
     * The startup command, which reads a configuration file that is used to
     * initialize the application at a global level.
     */
    public class StartupCommand extends Command
    {
        private var _configFileName:String;
        private var _model:AppModel;

        public function StartupCommand (context:ICommandContext,
                                        model:AppModel,
                                        configFileName:String)
        {
            super(context);
            _model = model;
            _configFileName = configFileName;
        }

        override public function execute():void
        {
            context.showWait();
            var timer:Timer = new Timer(1000, 1);
            timer.addEventListener(TimerEvent.TIMER, function(e:Event):void { loadConfig(); });
            timer.start();
        }

        private function loadConfig():void
        {
            var urlLoader:URLLoader = new URLLoader();
            urlLoader.addEventListener(Event.COMPLETE, handleLoadComplete);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
            urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError);
            urlLoader.load(new URLRequest(_configFileName));
        }

        private function handleLoadComplete(event:Event):void
        {
            try
            {
                _model.applyConfig(new XML(URLLoader(event.target).data));
            }
            catch (e:Error)
            {
                // XML Parse error, most likely.
                context.showError(e.message, true);
            }

            context.clearWait();
        }

        private function handleLoadError(event:ErrorEvent):void
        {
            context.showError(event.text, true);
            context.clearWait();
        }
    }
}
