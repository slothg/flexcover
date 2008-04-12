package faces.model
{
    import flash.events.EventDispatcher;
    
    import mx.collections.ArrayCollection;
    import mx.collections.IList;
    import mx.events.CollectionEvent;

    /** Adapter-pattern class that adapts a FacesModel into a summarized list of
     *  name/count pairs (FacesSummaryEntry instances).
     */
    public class FacesSummaryAdapter extends EventDispatcher
    {
        [Bindable]
        public var summaryProvider:IList = new ArrayCollection();
        
        private var _facesModel:FacesModel;

        [Bindable]
        public function get facesModel():FacesModel
        {
            return _facesModel;
        }
        
        public function set facesModel(provider:FacesModel):void
        {
            if (_facesModel != null)
            {
                _facesModel.facesProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleFacesChange);
            }
            _facesModel = provider;
            if (_facesModel != null)
            {
                _facesModel.facesProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleFacesChange);
                computeSummary();
            }
        }
        
        private function handleFacesChange(e:CollectionEvent):void
        {
            // TODO: incremental change handling based on contents of CollectionEvent
            // Also note that any changes in individuals' last names would affect summary.
            computeSummary();
        }

        public function findEntryByCountryCode(countryCode:String):FacesSummaryEntry
        {
            for each (var entry:FacesSummaryEntry in summaryProvider)
            {
                if (entry.countryCode == countryCode)
                {
                    return entry;
                }
            }
            return null;
        }
        
        private function computeSummary():void
        {
            summaryProvider.removeAll();
            for each (var f:Face in facesModel.facesProvider)
            {
                // TODO: optimize performance with dictionary of names
                var entry:FacesSummaryEntry = findEntryByCountryCode(f.countryCode);
                if (entry == null)
                {
                    entry = new FacesSummaryEntry(f.countryCode, 0);
                    summaryProvider.addItem(entry);
                }
                entry.count++;
            }
        }
    }
}
