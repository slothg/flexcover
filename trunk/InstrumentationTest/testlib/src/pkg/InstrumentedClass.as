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

            for (var i:int = 0; i < 10; i++)
            {
                if (i == 5)
                {
                    continue;
                }
                log.push("for loop: " + i);
            }

            var j:uint = n;
            while (j > 0)
            {
                log.push("while loop: " + j);
                if (j == 3)
                {
                    break;
                }
                j--;
            }

            do
            {
                log.push("do loop: " + k);
                if (k == 3)
                {
                    break;
                }
            } while (k > 0);
        }
    }
}
