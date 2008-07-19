/* 
 * Copyright (c) 2008 Allurent, Inc.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished
 * to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
 * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package com.allurent.coverage.model.search
{
	import com.allurent.coverage.model.PackageModel;
	
	import mx.collections.IHierarchicalCollectionView;
	
	public class PackageSearch extends AbstractSearch
	{
		public function PackageSearch(content:IHierarchicalCollectionView)
		{
			super(content);
			showDetail = true;
		}
		
		override protected function find(packageModel:PackageModel):Boolean
		{
			return findPackage(packageModel);
		}
		
		private function findPackage(packageModel:PackageModel):Boolean
		{
			var found:Boolean = findString(packageModel.displayName);
			if(found)
			{
				if(showDetail)
				{
					openNodes.push(packageModel);
				}			 	
			}
			return found;		
		}
	}
}