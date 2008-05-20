package
{
    import pkg.InstrumentedClass;
    import com.allurent.coverage.runtime.AbstractCoverageAgent;

    public class InstrumentationTestAgent extends AbstractCoverageAgent
    {
        override public function recordCoverage(key:String):void
        {
            InstrumentedClass.log.push(key);
        }
    }
}
