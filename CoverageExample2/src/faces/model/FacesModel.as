package faces.model
{
    import mx.collections.ArrayCollection;
    import mx.collections.ICollectionView;
    import mx.collections.IList;
    import flash.events.EventDispatcher;

    /** FacesModel exposes a list of Faces along with various helper methods
     *  that can be called by Commands to update the model.
     */
    public class FacesModel extends EventDispatcher
    {
        [Bindable]
        public var facesProvider:IList = new ArrayCollection();

        /**
         * Clear the view of faces.
         */
        public function clearFaces():void
        {
            facesProvider.removeAll();
        }

        /**
         * Apply raw search results.
         */
        public function applySearchResults(results:Array):void
        { 
            for each (var face:Face in results)
            {
                for each (var existingFace:Face in facesProvider)
                {
                    if (existingFace.id == face.id)
                    {
                        // do not add duplicate faces
                        face = null;
                        break;
                    }
                }
                if (face != null)
                {
                    facesProvider.addItem(face);
                }
            }
        }


        /**
         * Disable changes to a Face temporarily.
         */
        public function setFaceChangeEnabled(targetId:String, changeEnabled:Boolean):void
        {
            findFace(targetId).changeEnabled = changeEnabled;
        }

        /**
         * Update a Face description.
         */
        public function updateFaceDescription(targetId:String, description:String):void
        {
            findFace(targetId).description = description;
        }

        /**
         * Remove the identified Face object from the display model.
         */
        public function removeFace(targetId:String):void
        {
            facesProvider.removeItemAt(findFaceIndex(targetId));
        }

        /**
         * Find the Face instance in the current model that has the
         * target id, and return a reference to the found instance. 
         * Throw an Error if the search fails.
         */
        private function findFace(targetId:String):Face
        {
            return facesProvider.getItemAt(findFaceIndex(targetId)) as Face;
        }

        /**
         * Find the Face instance in the current model that has the
         * target id, and return its index.
         * Throw an Error if the search fails.
         */
        private function findFaceIndex(targetId:String):int
        {
            for (var i:int = 0; i < facesProvider.length; ++i)
            {
                if (facesProvider.getItemAt(i).id == targetId)
                {
                    return i;
                }
            }

            throw new Error(targetId + ": face not found");
        }
    }
}
