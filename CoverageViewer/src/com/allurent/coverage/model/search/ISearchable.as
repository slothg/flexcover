package com.allurent.coverage.model.search
{
	import mx.collections.IHierarchicalCollectionView;

	[Bindable]
	public interface ISearchable
	{
		function get content():IHierarchicalCollectionView;
		function set content(value:IHierarchicalCollectionView):void;
		function get currentSearchInput():String;
		function set currentSearchInput(value:String):void;
		function get showDetail():Boolean;
		function set showDetail(value:Boolean):void;		
		function search(searchInput:String):String;
	}
}