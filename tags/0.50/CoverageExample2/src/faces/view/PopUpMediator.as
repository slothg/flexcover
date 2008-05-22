package faces.view
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import mx.core.Container;
    import mx.managers.PopUpManager;
    import faces.model.AppModel;
    import faces.events.AppStatus;

    public class PopUpMediator 
        extends EventDispatcher
    {
        public var model:AppModel;
        public var parentContainer:Container;

        private var _errorView:ErrorBox;
        private var _waitView:WaitView;

        public function handleEvent(event:Event):void
        {
            update();
        }

        public function update():void
        {
            if (model.errorMessage != null)
            {
                dismissWaitView();

                if (_errorView == null)
                {
                    _errorView = new ErrorBox;
                    PopUpManager.addPopUp(_errorView, parentContainer, true);
                    PopUpManager.centerPopUp(_errorView);
                    _errorView.addEventListener(MouseEvent.CLICK, handleErrorClick);
                }

                _errorView.message = model.errorMessage;
                _errorView.fatal = model.status == AppStatus.ERROR;
            }
            else if (model.waitLevel > 0)
            {
                dismissErrorView();

                if (_waitView == null)
                {
                    _waitView = new WaitView ();
                    PopUpManager.addPopUp(_waitView, parentContainer, true);
                    PopUpManager.centerPopUp(_waitView);
                }
            }
            else 
            {
                dismissErrorView();
                dismissWaitView();
            }
        }

        private function dismissErrorView():void
        {
            if (_errorView != null)
            {
                PopUpManager.removePopUp(_errorView);
                _errorView = null;
            }
        }

        private function dismissWaitView():void
        {
            if (_waitView != null)
            {
                PopUpManager.removePopUp(_waitView);
                _waitView = null;
            }
        }

        private function handleErrorClick(event:Event):void
        {
            model.errorMessage = null;
            update();
        }
    }
}
