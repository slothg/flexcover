package pkg {

    public class InstrumentedClass
    {
        [Bindable]
        public var bindableProperty:String = "foo";

        public static var log:Array /* of String */ = [];  

        public var functionProperty:Function = function():void {
            log.push("function property");
        };
        
        public function InstrumentedClass()
        {
           var f:Function = function():void {
               log.push("inner 1");
           };
           f();
        }
        
        public static function staticFunction():void
        {
            log.push("static function");
        }

        public function get xxx():Number
        {
            return 123;
        }
        
        public function set xxx(n:Number):void
        {
            log.push("xxx setter");
        }

        public function branchTest(n:uint, k:uint):void
        {
            if (n == 0)
            {
                log.push("n=0");
            }
            if (n == 1 || (n == 2 && k == 3))
            {
                log.push("n=1 or (n=2 and k=3)");
            }

            var s:String = (n == 0) ? "aaa" : "bbb";
            if (n == 2)
            {
                s = "ccc";
            }

            switch (s)
            {
                case "aaa":
                    log.push("s=aaa");
                    break;
                case "bbb":
                    log.push("s=bbb");
                    break;
                default:
                    log.push("default");
                    break;
            }

            for (var i:int = 0; i < n; i++)
            {
                log.push("for loop start");
                if (i == 1)
                {
                    continue;
                }
                log.push("for loop end: " + i);
            }

            var j:uint = n;
            while (j > 0)
            {
                log.push("while loop start: " + j);
                if (j == 3)
                {
                    break;
                }
                j--;
                log.push("while loop end");
            }
            log.push("after while");
            do
            {
                log.push("do loop: " + k);
                if (k == 3)
                {
                    break;
                }
                log.push("do loop end");
            } while (k-- > 0);
            log.push("after do");
        }
    }
}
