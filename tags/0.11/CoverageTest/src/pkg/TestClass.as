package pkg
{
    public class TestClass
    {
        [Bindable]
        public var bindableVar:uint = 0;

        private static var counter:uint = 0;
        
        public function TestClass()
        {
            trace("constructor");
            bindableVar++;
        }
        
        public function testFunction(arg:Number):void
        {
            trace("testFunction");
            if (arg > 0)
            {
                trace("in if{}");
            }
            else
            {
                trace("in else{}");
            }
            for (var i:Number = 0; i < arg; i++)
            {
                trace("in loop");
            }
            switch(arg)
            {
            case 123:
                trace("arg == 123");
                break;
            }
            // TODO for branch testing:
            // include switch() plus ?:, || and &&
        }
        
        public static function staticFunction():void
        {
            trace("staticFunction");            
        }
    }
}
