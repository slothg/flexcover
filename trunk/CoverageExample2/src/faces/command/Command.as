package faces.command
{
    /** simple Command superclass offering access to command's context. */

    public class Command
    {
        public var context:ICommandContext;

        public function Command (context:ICommandContext)
        {
            this.context = context;
        }

        public function execute():void
        {
        }
    }
}
