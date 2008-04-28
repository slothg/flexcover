package
{
    import pkg.InstrumentedClass;
    
    public function coverage(key:String):void
    {
        InstrumentedClass.log.push(key);
    }
}
